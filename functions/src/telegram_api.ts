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

export async function sendToAll(message: string, options: any = {}) {
  const rawIds = telegramChatIds.value().split(',');
  const ids = rawIds
    .map(id => id.trim())
    .filter(id => id.length > 0);

  if (ids.length === 0) {
    throw new Error('TELEGRAM_CHAT_ID is not configured — no recipients to notify');
  }

  const telegram = getBot();

  const results = await Promise.allSettled(
    ids.map(id => {
      return telegram.sendMessage(id, message, {
        parse_mode: 'MarkdownV2',
        ...options
      });
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
export function escapeMd(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!])/g, '\\$1');
}
