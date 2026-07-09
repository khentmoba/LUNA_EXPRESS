"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBot = getBot;
exports.sendToAll = sendToAll;
exports.escapeMd = escapeMd;
const node_telegram_bot_api_1 = __importDefault(require("node-telegram-bot-api"));
const index_1 = require("./index");
const firebase_functions_1 = require("firebase-functions");
let bot;
function getBot() {
    if (!bot) {
        bot = new node_telegram_bot_api_1.default(index_1.telegramToken.value(), { polling: false });
    }
    return bot;
}
async function sendToAll(message, options = {}) {
    const rawIds = index_1.telegramChatIds.value().split(',');
    const ids = rawIds
        .map(id => id.trim())
        .filter(id => id.length > 0);
    if (ids.length === 0) {
        throw new Error('TELEGRAM_CHAT_ID is not configured — no recipients to notify');
    }
    const telegram = getBot();
    const results = await Promise.allSettled(ids.map(id => {
        return telegram.sendMessage(id, message, {
            parse_mode: 'MarkdownV2',
            ...options
        });
    }));
    const failures = results.filter(r => r.status === 'rejected');
    if (failures.length > 0) {
        firebase_functions_1.logger.error(`sendToAll: ${failures.length} of ${ids.length} messages failed`, failures.map((r, i) => ({
            chatId: ids[i],
            error: r.reason?.message || 'unknown'
        })));
    }
    if (failures.length === ids.length) {
        throw new Error(`All ${ids.length} Telegram messages failed`);
    }
    return results;
}
// Utility to escape MarkdownV2 special characters
function escapeMd(text) {
    return text.replace(/([_*\[\]()~`>#+\-=|{}.!])/g, '\\$1');
}
//# sourceMappingURL=telegram_api.js.map