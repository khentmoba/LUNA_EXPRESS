const { describe, test } = require('node:test');
const assert = require('node:assert/strict');
const { escapeMd } = require('../lib/telegram_api');
const { itemLines, formatOrderNotification } = require('../lib/orders/send_notification');

// Comprehensive MarkdownV2 validator that simulates Telegram Bot API's entity parser
function validateMarkdownV2(text) {
  const errors = [];
  const reserved = new Set(['_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!']);
  
  let i = 0;
  const stack = [];
  
  while (i < text.length) {
    const char = text[i];
    
    if (char === '\\') {
      // Escaped character - skip next character
      i += 2;
      continue;
    }
    
    if (text.startsWith('```', i)) {
      const end = text.indexOf('```', i + 3);
      if (end === -1) {
        errors.push(`Unclosed code block at index ${i}`);
        break;
      }
      i = end + 3;
      continue;
    }
    
    if (char === '`') {
      const end = text.indexOf('`', i + 1);
      if (end === -1) {
        errors.push(`Unclosed inline code at index ${i}`);
        break;
      }
      i = end + 1;
      continue;
    }
    
    if (char === '[') {
      let j = i + 1;
      let depth = 1;
      while (j < text.length) {
        if (text[j] === '\\') { j += 2; continue; }
        if (text[j] === '[') depth++;
        if (text[j] === ']') {
          depth--;
          if (depth === 0) break;
        }
        j++;
      }
      if (depth !== 0 || text[j + 1] !== '(') {
        errors.push(`Character '[' is reserved and must be escaped at offset ${i}`);
        i++;
        continue;
      }
      let k = j + 2;
      while (k < text.length) {
        if (text[k] === '\\') { k += 2; continue; }
        if (text[k] === ')') break;
        k++;
      }
      if (k >= text.length || text[k] !== ')') {
        errors.push(`Unclosed link URL at offset ${j + 1}`);
        i = j + 1;
        continue;
      }
      const linkTextErrors = validateMarkdownV2(text.slice(i + 1, j));
      errors.push(...linkTextErrors);
      i = k + 1;
      continue;
    }
    
    if (char === '*' || char === '_' || char === '~' || text.startsWith('||', i)) {
      const tag = text.startsWith('||', i) ? '||' : char;
      const tagLen = tag.length;
      if (stack.length > 0 && stack[stack.length - 1].tag === tag) {
        stack.pop();
      } else {
        stack.push({ tag, index: i });
      }
      i += tagLen;
      continue;
    }
    
    if (reserved.has(char)) {
      errors.push(`Character '${char}' is reserved and must be escaped at offset ${i} (context: "${text.slice(Math.max(0, i - 15), Math.min(text.length, i + 15))}")`);
    }
    
    i++;
  }
  
  while (stack.length > 0) {
    const unclosed = stack.pop();
    errors.push(`Unclosed entity '${unclosed.tag}' starting at offset ${unclosed.index}`);
  }
  
  return errors;
}

describe('Telegram MarkdownV2 escaping and order notifications', () => {
  test('escapeMd escapes all Telegram MarkdownV2 reserved characters', () => {
    const allReserved = '_*[]()~`>#+-=|{}.!\\';
    const escaped = escapeMd(allReserved);
    for (const ch of allReserved) {
      assert.ok(escaped.includes('\\' + ch), `Expected \\${ch} in escaped output`);
    }
  });

  test('escapeMd handles numbers, null, and undefined without throwing', () => {
    assert.equal(escapeMd(null), '');
    assert.equal(escapeMd(undefined), '');
    assert.equal(escapeMd(12345), '12345');
    assert.equal(escapeMd(99.5), '99\\.5');
  });

  test('item line with variant must have escaped parentheses in MarkdownV2', () => {
    assert.equal(typeof itemLines, 'function', 'itemLines should be exported function');
    const itemWithVariant = { name: 'French Fries', variant: 'Cheese', price: 50, quantity: 2 };
    const line = itemLines([itemWithVariant]);
    const errors = validateMarkdownV2(line);
    assert.deepEqual(errors, [], `itemLines produced invalid MarkdownV2: ${errors.join(', ')}`);
    assert.ok(line.includes('\\(Cheese\\)'), `Expected escaped parentheses \\(Cheese\\), but got: ${line}`);
  });

  test('full order notification messages must be valid MarkdownV2', () => {
    assert.equal(typeof formatOrderNotification, 'function', 'formatOrderNotification should be exported function');
    const testCases = [
      {
        desc: 'Delivery with variants and map coordinates',
        data: {
          orderNumber: 'LU-10001',
          customerName: 'Juan Dela Cruz',
          customerAddress: 'Purok 1, Brgy. Libertad, Butuan City',
          customerPhone: '09123456789',
          items: [
            { name: 'French Fries', variant: 'Cheese', price: 50, quantity: 1 },
            { name: 'Coolers', variant: 'Purple Taro', price: 39, quantity: 2 },
          ],
          total: 178,
          timeStr: '2026-09-28  14:30',
          orderType: 'Delivery',
          deliveryFee: 50,
          paymentMethod: 'Cash',
          paymentStatus: 'NOT PAID',
          lat: 8.95,
          lng: 125.53,
        },
      },
      {
        desc: 'Pickup order with GCash awaiting payment',
        data: {
          orderNumber: 'LU-10002',
          customerName: 'Maria Santos',
          customerPhone: '09987654321',
          items: [
            { name: 'Shawarma Wrap', variant: 'Buy 1 Take 1', price: 99, quantity: 1 },
          ],
          total: 99,
          timeStr: '2026-09-28  15:00',
          orderType: 'Pickup',
          deliveryFee: 0,
          paymentMethod: 'GCash',
          paymentStatus: 'AWAITING_PAYMENT',
        },
      },
      {
        desc: 'Walk-in order with variant and paid status',
        data: {
          orderNumber: 'LU-10003',
          customerName: 'Walk-in Customer',
          customerPhone: 'N/A',
          items: [
            { name: 'Burger', variant: 'Solo', price: 60, quantity: 1 },
          ],
          total: 60,
          timeStr: '2026-09-28  15:15',
          orderType: 'Walk-In',
          paymentMethod: 'Cash',
          paymentStatus: 'PAID',
        },
      },
    ];

    for (const tc of testCases) {
      const msg = formatOrderNotification(tc.data);
      const errors = validateMarkdownV2(msg);
      assert.deepEqual(errors, [], `${tc.desc} failed MarkdownV2 validation:\n${errors.join('\n')}\n\nMessage:\n${msg}`);
    }
  });

  test('stripMarkdownV2 removes backslash escapes cleanly for plain-text fallback', () => {
    const { stripMarkdownV2 } = require('../lib/telegram_api');
    assert.equal(typeof stripMarkdownV2, 'function', 'stripMarkdownV2 should be exported function');
    const escaped = '🔔 *NEW ORDER — LU\\-12345*\n  • 1x French Fries \\(Cheese\\) — ₱50\n✅ _Please prepare this order\\!_';
    const stripped = stripMarkdownV2(escaped);
    assert.ok(!stripped.includes('\\-'), 'Expected \\- to become -');
    assert.ok(!stripped.includes('\\('), 'Expected \\( to become (');
    assert.ok(!stripped.includes('\\)'), 'Expected \\) to become )');
    assert.ok(!stripped.includes('\\!'), 'Expected \\! to become !');
    assert.equal(stripped, '🔔 *NEW ORDER — LU-12345*\n  • 1x French Fries (Cheese) — ₱50\n✅ _Please prepare this order!_');
  });

  test('sendToAll falls back to plain text when Telegram rejects entity parsing', async () => {
    process.env.TELEGRAM_CHAT_ID = '111,222';
    const { sendToAll, setBot } = require('../lib/telegram_api');

    const sentCalls = [];
    const mockBot = {
      sendMessage: async (chatId, text, opts) => {
        sentCalls.push({ chatId, text, opts });
        if (opts.parse_mode === 'MarkdownV2') {
          // Simulate Telegram 400 Bad Request entity parsing error
          const err = new Error("ETELEGRAM: 400 Bad Request: can't parse entities: Character '(' is reserved");
          err.response = { body: { description: "Bad Request: can't parse entities: Character '(' is reserved" } };
          throw err;
        }
        return { message_id: 1, chat: { id: chatId } };
      },
    };

    setBot(mockBot);

    const testMsg = '🔔 *NEW ORDER — LU\\-12345*\n  • 1x French Fries \\(Cheese\\) — ₱50';
    const results = await sendToAll(testMsg);

    // Both chats should have succeeded via the plain-text fallback
    assert.equal(results.length, 2);
    assert.equal(results[0].status, 'fulfilled');
    assert.equal(results[1].status, 'fulfilled');

    // Each chat should have had 1 failed MarkdownV2 attempt and 1 successful plain-text fallback attempt
    assert.equal(sentCalls.length, 4);
    const mdCalls = sentCalls.filter(c => c.opts.parse_mode === 'MarkdownV2');
    const fallbackCalls = sentCalls.filter(c => c.opts.parse_mode === undefined);
    assert.equal(mdCalls.length, 2);
    assert.equal(fallbackCalls.length, 2);
    assert.equal(fallbackCalls[0].text, '🔔 *NEW ORDER — LU-12345*\n  • 1x French Fries (Cheese) — ₱50');
  });
});
