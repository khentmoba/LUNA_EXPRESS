const { describe, test } = require('node:test');
const assert = require('node:assert/strict');
const { hashPassword, verifyPassword } = require('../lib/util/security');

describe('staff auth: scrypt PIN and password verification', () => {
  test('hashes and verifies a 4-digit PIN', () => {
    const pin = '1234';
    const hash = hashPassword(pin);
    assert.ok(hash.startsWith('scrypt$'), 'Hash should be formatted as scrypt');
    assert.equal(verifyPassword(pin, hash), 'ok');
    assert.equal(verifyPassword('0000', hash), 'bad');
  });

  test('hashes and verifies a staff password', () => {
    const pw = 'superSecretStaffPass123';
    const hash = hashPassword(pw);
    assert.equal(verifyPassword(pw, hash), 'ok');
    assert.equal(verifyPassword('wrongPassword', hash), 'bad');
  });

  test('timing-safe comparison rejects tampered hash', () => {
    const hash = hashPassword('1234');
    const tampered = hash.slice(0, -4) + '0000';
    assert.equal(verifyPassword('1234', tampered), 'bad');
  });
});
