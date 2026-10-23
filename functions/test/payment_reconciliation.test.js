const test = require('node:test');
const assert = require('node:assert');

const { resolveOrderDocId } = require('../lib/payments/webhook');

// A paid session must land on the order document the kiosk wrote. PayMongo
// echoes our metadata back on the webhook, so the document id travels there
// while reference_number stays the human-facing order number.
test('prefers the order document id from metadata', () => {
  assert.strictEqual(
    resolveOrderDocId({
      reference_number: 'LU-260102-030405',
      metadata: { order_doc_id: 'aB3xY9zKq1LmN2pQr4St' },
    }),
    'aB3xY9zKq1LmN2pQr4St',
  );
});

test('falls back to reference_number for sessions created before this change', () => {
  assert.strictEqual(
    resolveOrderDocId({ reference_number: 'LU-48213' }),
    'LU-48213',
  );
});

test('ignores metadata that is not a plain document id', () => {
  assert.strictEqual(
    resolveOrderDocId({
      reference_number: 'LU-48213',
      metadata: { order_doc_id: 'orders/../../admin' },
    }),
    'LU-48213',
  );
});

test('returns null when the payload has no usable id', () => {
  assert.strictEqual(resolveOrderDocId({}), null);
  assert.strictEqual(resolveOrderDocId(null), null);
  assert.strictEqual(resolveOrderDocId({ reference_number: 42 }), null);
  assert.strictEqual(
    resolveOrderDocId({ metadata: { order_doc_id: 'has spaces' } }),
    null,
  );
});
