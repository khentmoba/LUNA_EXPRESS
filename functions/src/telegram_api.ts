import TelegramBot from 'node-telegram-bot-api';
import { telegramToken, telegramChatIds } from './index';

let bot: TelegramBot;

export function getBot() {
  if (!bot) {
    bot = new TelegramBot(telegramToken.value(), { polling: false });
  }
  return bot;
}

export async function sendToAll(message: string, options: any = {}) {
  const ids = telegramChatIds.value().split(',');
  const telegram = getBot();
  
  const promises = ids.map(id => {
    return telegram.sendMessage(id.trim(), message, {
      parse_mode: 'MarkdownV2',
      ...options
    });
  });

  return Promise.all(promises);
}

// Utility to escape MarkdownV2 special characters
export function escapeMd(text: string): string {
  return text.replace(/([_*\[\]()~`>#+\-=|{}.!])/g, '\\$1');
}
