// Firestore security rules regression tests. Run with: npm run test:rules
// (executes against the Firestore emulator; never touches production).
const { describe, test, before, after, beforeEach } = require('node:test');
const { readFileSync } = require('node:fs');
const { resolve } = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  collection,
  addDoc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  deleteDoc,
} = require('firebase/firestore');

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error('Run via `npm run test:rules` (needs the Firestore emulator).');
}

let testEnv;
before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'lunaexpress-test',
    firestore: { rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8') },
  });
});
after(() => testEnv.cleanup());
beforeEach(() => testEnv.clearFirestore());

const anon = () => testEnv.unauthenticatedContext().firestore();
const user = (uid, claims = {}) => testEnv.authenticatedContext(uid, claims).firestore();
const seed = (path, data) =>
  testEnv.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

const order = (over = {}) => ({
  customerName: 'Ana',
  items: [{ name: 'Shawarma Wrap', price: 99, quantity: 1 }],
  totalAmount: 99,
  ...over,
});

const errand = (over = {}) => ({
  customerName: 'Ana',
  customerPhone: '09181234567',
  phoneHash: 'h',
  pinHash: 'p',
  message: 'buy milk',
  status: 'available',
  ...over,
});

describe('orders: kiosk can only create (validated)', () => {
  test('anon can create a valid order', async () => {
    await assertSucceeds(addDoc(collection(anon(), 'orders'), order()));
  });
  test('create rejects missing/junk/oversized fields', async () => {
    const { customerName: _d, ...noName } = order();
    await assertFails(addDoc(collection(anon(), 'orders'), noName));
    await assertFails(addDoc(collection(anon(), 'orders'), order({ items: [] })));
    await assertFails(addDoc(collection(anon(), 'orders'), order({ totalAmount: -5 })));
    await assertFails(addDoc(collection(anon(), 'orders'), order({ injected: true })));
  });
  test('nobody can read/update/delete via client', async () => {
    await seed('orders/o1', order());
    const ref = doc(anon(), 'orders/o1');
    await assertFails(getDoc(ref));
    await assertFails(updateDoc(ref, { totalAmount: 1 }));
    await assertFails(deleteDoc(ref));
    await assertFails(getDoc(doc(user('u1', { role: 'staff' }), 'orders/o1')));
  });
});

describe('config: public read-only', () => {
  test('anon can read, cannot write', async () => {
    await seed('config/app', { open: true });
    await assertSucceeds(getDoc(doc(anon(), 'config/app')));
    await assertFails(setDoc(doc(anon(), 'config/hack'), { open: false }));
    await assertFails(updateDoc(doc(anon(), 'config/app'), { open: false }));
  });
});

describe('staff_accounts + login_attempts: server only', () => {
  test('everyone denied, even staff', async () => {
    await seed('staff_accounts/boss', { pin: 'x' });
    await assertFails(getDoc(doc(anon(), 'staff_accounts/boss')));
    await assertFails(getDoc(doc(user('u1', { role: 'staff' }), 'staff_accounts/boss')));
    await assertFails(setDoc(doc(anon(), 'login_attempts/k'), { fails: 1 }));
    await assertFails(getDoc(doc(user('u1'), 'login_attempts/k')));
  });
});

describe('pasugo_errands: bulletin board + status machine', () => {
  test('anyone can list/get available; accepted hidden from anon', async () => {
    await seed('pasugo_errands/e1', errand());
    await seed('pasugo_errands/e2', errand({ status: 'accepted' }));
    await assertSucceeds(getDocs(collection(anon(), 'pasugo_errands')));
    await assertSucceeds(getDoc(doc(anon(), 'pasugo_errands/e1')));
    await assertFails(getDoc(doc(anon(), 'pasugo_errands/e2')));
  });
  test('create requires valid fields + available status', async () => {
    await assertSucceeds(addDoc(collection(anon(), 'pasugo_errands'), errand()));
    const { message: _dropped, ...missingMessage } = errand();
    await assertFails(addDoc(collection(anon(), 'pasugo_errands'), missingMessage));
    await assertFails(addDoc(collection(anon(), 'pasugo_errands'), errand({ status: 'accepted' })));
    await assertFails(addDoc(collection(anon(), 'pasugo_errands'), errand({ customerPhone: '123' })));
    await assertFails(addDoc(collection(anon(), 'pasugo_errands'), errand({ role: 'admin' })));
  });
  test('cancel: phone must still match, nothing else may change', async () => {
    await seed('pasugo_errands/e1', errand());
    await seed('pasugo_errands/e2', errand());
    await assertSucceeds(updateDoc(doc(anon(), 'pasugo_errands/e1'), { status: 'cancelled' }));
    await assertFails(
      updateDoc(doc(anon(), 'pasugo_errands/e2'), { status: 'cancelled', customerPhone: 'other' }),
    );
  });
  test('accept: approved riders only; anon cannot', async () => {
    await seed('pasugo_errands/e1', errand());
    await seed('pasugo_errands/e2', errand());
    await assertFails(updateDoc(doc(anon(), 'pasugo_errands/e1'), { status: 'accepted' }));
    await assertSucceeds(
      updateDoc(doc(user('r1', { riderStatus: 'approved' }), 'pasugo_errands/e2'), { status: 'accepted' }),
    );
  });
  test('complete: accepted→completed by rider; other edges denied', async () => {
    await seed('pasugo_errands/e1', errand({ status: 'accepted' }));
    await seed('pasugo_errands/e2', errand({ status: 'accepted' }));
    await assertSucceeds(
      updateDoc(doc(user('r1', { riderStatus: 'approved' }), 'pasugo_errands/e1'), { status: 'completed' }),
    );
    await assertFails(updateDoc(doc(anon(), 'pasugo_errands/e2'), { status: 'completed' }));
    await assertFails(deleteDoc(doc(anon(), 'pasugo_errands/e2')));
  });
});

describe('riders: no privilege self-escalation', () => {
  test('read: self and roles pass, others fail', async () => {
    await seed('riders/r1', { name: 'R' });
    await assertFails(getDoc(doc(anon(), 'riders/r1')));
    await assertSucceeds(getDoc(doc(user('r1'), 'riders/r1')));
    await assertFails(getDoc(doc(user('other'), 'riders/r1')));
    await assertSucceeds(getDoc(doc(user('x', { role: 'admin' }), 'riders/r1')));
  });
  test('create: self only, fixed pending/active values', async () => {
    const valid = { name: 'R', phone: '0918', status: 'pending', isActive: true };
    await assertFails(setDoc(doc(anon(), 'riders/r2'), valid));
    await assertSucceeds(setDoc(doc(user('r2'), 'riders/r2'), valid));
    await assertFails(setDoc(doc(user('r2'), 'riders/r3'), valid));
    await assertFails(setDoc(doc(user('r2'), 'riders/r2'), { ...valid, status: 'approved' }));
    await assertFails(setDoc(doc(user('r2'), 'riders/r2'), { ...valid, role: 'admin' }));
  });
  test('update: self cannot touch privilege fields; admin can; delete: nobody', async () => {
    await seed('riders/r1', { name: 'R', status: 'pending', isActive: true });
    await assertSucceeds(updateDoc(doc(user('r1'), 'riders/r1'), { name: 'R2' }));
    await assertFails(updateDoc(doc(user('r1'), 'riders/r1'), { status: 'approved' }));
    await assertFails(updateDoc(doc(user('r1'), 'riders/r1'), { isActive: false }));
    await assertSucceeds(updateDoc(doc(user('x', { role: 'admin' }), 'riders/r1'), { status: 'approved' }));
    await assertFails(deleteDoc(doc(user('r1'), 'riders/r1')));
    await assertFails(deleteDoc(doc(user('x', { role: 'admin' }), 'riders/r1')));
  });
});

describe('pasugo_sessions: rider + staff only', () => {
  const valid = { errandId: 'e1', riderId: 'rider1', customerPhone: '0918', status: 'active', acceptedAt: 'now' };
  test('read/update: rider and staff pass, strangers fail', async () => {
    await seed('pasugo_sessions/s1', valid);
    await assertFails(getDoc(doc(anon(), 'pasugo_sessions/s1')));
    await assertSucceeds(getDoc(doc(user('rider1'), 'pasugo_sessions/s1')));
    await assertFails(getDoc(doc(user('stranger'), 'pasugo_sessions/s1')));
    await assertSucceeds(getDoc(doc(user('x', { role: 'staff' }), 'pasugo_sessions/s1')));
    await assertSucceeds(updateDoc(doc(user('rider1'), 'pasugo_sessions/s1'), { status: 'completed' }));
    await assertFails(updateDoc(doc(user('stranger'), 'pasugo_sessions/s1'), { status: 'completed' }));
    await assertFails(updateDoc(doc(user('rider1'), 'pasugo_sessions/s1'), { riderId: 'stranger' }));
  });
  test('create: approved riders only, own riderId, strict fields', async () => {
    await assertSucceeds(
      addDoc(collection(user('rider1', { riderStatus: 'approved' }), 'pasugo_sessions'), valid),
    );
    await assertFails(addDoc(collection(user('r2'), 'pasugo_sessions'), valid));
    await assertFails(addDoc(collection(anon(), 'pasugo_sessions'), valid));
    await assertFails(
      addDoc(collection(user('rider1', { riderStatus: 'approved' }), 'pasugo_sessions'),
        { ...valid, riderId: 'someone-else' }),
    );
  });
});

describe('session messages: participants only', () => {
  const msgs = (db, s) => collection(doc(db, `pasugo_sessions/${s}`), 'messages');
  const msg = { sender: 'rider', text: 'hi', timestamp: 'now' };
  test('create only when session active + authed + valid shape', async () => {
    await seed('pasugo_sessions/s1', { riderId: 'rider1', status: 'active' });
    await seed('pasugo_sessions/s2', { riderId: 'rider1', status: 'closed' });
    await assertSucceeds(addDoc(msgs(user('rider1'), 's1'), msg));
    await assertFails(addDoc(msgs(user('rider1'), 's2'), msg));
    await assertFails(addDoc(msgs(anon(), 's1'), msg));
    await assertFails(addDoc(msgs(user('rider1'), 's1'), { text: 'no sender' }));
    await assertFails(addDoc(msgs(user('rider1'), 's1'), { ...msg, text: '' }));
  });
  test('read: rider + staff only; nobody can edit/delete', async () => {
    await seed('pasugo_sessions/s1', { riderId: 'rider1', status: 'active' });
    await seed('pasugo_sessions/s1/messages/m1', msg);
    await assertSucceeds(getDoc(doc(user('rider1'), 'pasugo_sessions/s1/messages/m1')));
    await assertSucceeds(getDoc(doc(user('x', { role: 'staff' }), 'pasugo_sessions/s1/messages/m1')));
    await assertFails(getDoc(doc(user('stranger'), 'pasugo_sessions/s1/messages/m1')));
    await assertFails(getDoc(doc(anon(), 'pasugo_sessions/s1/messages/m1')));
    await assertFails(updateDoc(doc(user('rider1'), 'pasugo_sessions/s1/messages/m1'), { text: 'x' }));
    await assertFails(deleteDoc(doc(user('rider1'), 'pasugo_sessions/s1/messages/m1')));
  });
});

describe('default deny', () => {
  test('unknown collections denied', async () => {
    await assertFails(getDoc(doc(anon(), 'whatever/w1')));
    await assertFails(setDoc(doc(anon(), 'whatever/w1'), { a: 1 }));
  });
});
