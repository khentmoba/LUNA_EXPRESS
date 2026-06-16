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
let bot;
function getBot() {
    if (!bot) {
        bot = new node_telegram_bot_api_1.default(index_1.telegramToken.value(), { polling: false });
    }
    return bot;
}
async function sendToAll(message, options = {}) {
    const ids = index_1.telegramChatIds.value().split(',');
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
function escapeMd(text) {
    return text.replace(/([_*\[\]()~`>#+\-=|{}.!])/g, '\\$1');
}
//# sourceMappingURL=telegram_api.js.map