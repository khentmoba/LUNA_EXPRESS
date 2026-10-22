import TelegramBot from 'node-telegram-bot-api';
import { telegramToken, telegramChatIds } from './index';
import { logger } from 'firebase-functions';

let bot: TelegramBot;

export function getBot() {
  if (!bot) {
    bot = new TelegramBot(telegramToken.value(), { polling: false });
  }
  return bot;
}

export function setBot(customBot: any) {
  bot = customBot;
}

export async function sendToAll(message: string, options: any = {}) {
  const rawIds = telegramChatIds.value().split(',');
  const ids = rawIds
    .map(id => id.trim())
    .filter(id => id.length > 0);

  if (ids.length === 0) {
    throw new Error('TELEGRAM_CHAT_ID is not configured — no recipients to notify');
  }

  const telegram = getBot();
  const sendOpts = {
    parse_mode: 'MarkdownV2',
    ...options,
  };

  const results = await Promise.allSettled(
    ids.map(async id => {
      try {
        return await telegram.sendMessage(id, message, sendOpts);
      } catch (err: any) {
        const isParseError =
          sendOpts.parse_mode &&
          (err?.message?.includes("can't parse entities") ||
           err?.response?.body?.description?.includes("can't parse entities") ||
           err?.message?.includes('400'));
        if (isParseError) {
          logger.warn(`sendToAll: MarkdownV2 parsing failed for chat ${id}; falling back to plain text`, {
            error: err?.message,
            chatId: id,
          });
          const { parse_mode: _, ...plainOpts } = sendOpts;
          return await telegram.sendMessage(id, stripMarkdownV2(message), plainOpts);
        }
        throw err;
      }
    })
  );

  const failures = results.filter(r => r.status === 'rejected');
  if (failures.length > 0) {
    logger.error(
      `sendToAll: ${failures.length} of ${ids.length} messages failed`,
      failures.map((r, i) => ({
        chatId: ids[i],
        error: (r as PromiseRejectedResult).reason?.message || 'unknown'
      }))
    );
  }

  if (failures.length === ids.length) {
    throw new Error(`All ${ids.length} Telegram messages failed`);
  }

  return results;
}

// Utility to escape MarkdownV2 special characters
export function escapeMd(text: string | number | null | undefined): string {
  return String(text ?? '').replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, '\\$1');
}

/** Strips backslash escapes for falling back to plain-text delivery. */
export function stripMarkdownV2(text: string): string {
  return text.replace(/\\([_*\[\]()~`>#+\-=|{}.!\\])/g, '$1');
}
