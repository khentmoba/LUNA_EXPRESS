import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { logger } from 'firebase-functions';
import * as crypto from 'crypto';
import {
  cleanStr, checkRateLimit, recordLoginFailure, clearLoginAttempts,
  hashPassword, verifyPassword,
} from '../util/security';

const GENERIC_FAIL = 'Invalid username or password';

export const verifyStaff = onCall(async (request) => {
  // #14 validate all input (length-capped, type-checked)
  const username = cleanStr(request.data?.username, 64, 'username').toLowerCase();
  const password = cleanStr(request.data?.password, 128, 'password');
  if (!/^[a-z0-9._-]{2,64}$/.test(username)) throw new HttpsError('invalid-argument', GENERIC_FAIL);

  // #11 rate limit login (lockout after 5 failures)
  await checkRateLimit(`staff:${username}`);
  const fail = async () => {
    await recordLoginFailure(`staff:${username}`);
    return { success: false, message: GENERIC_FAIL };
  };

  const db = getFirestore();

  // First-run seed: random per-deploy passwords (logged ONCE — rotate after).
  // Never seed well-known defaults; they end up in git/history forever.
  if ((await db.collection('staff_accounts').limit(1).get()).empty) {
    const mk = () => crypto.randomBytes(9).toString('base64url');
    const seeds = [
      { username: 'admin', role: 'admin' },
      { username: 'staff1', role: 'staff' },
    ];
    const batch = db.batch();
    for (const s of seeds) {
      const pw = mk();
      batch.set(db.collection('staff_accounts').doc(s.username), {
        username: s.username, role: s.role,
        passwordHash: hashPassword(pw), createdAt: new Date(),
      });
      logger.warn(`SEEDED staff account ${s.username} password: ${pw} — CHANGE AFTER FIRST LOGIN`);
    }
    await batch.commit();
  }

  const staffRef = db.collection('staff_accounts').doc(username);
  const doc = await staffRef.get();
  if (!doc.exists) {
    logger.info('Staff login failed: unknown user');
    return fail();
  }

  const data = doc.data()!;
  if (!data.passwordHash) {
    logger.error('Staff account missing passwordHash');
    throw new HttpsError('internal', 'Server misconfigured');
  }

  const result = verifyPassword(password, data.passwordHash);
  if (result === 'bad') {
    logger.info('Staff login failed: bad password');
    return fail();
  }

  // Auto-upgrade legacy sha256 hashes to scrypt (#10)
  if (result === 'ok-legacy') {
    await staffRef.update({ passwordHash: hashPassword(password) });
    logger.info('Upgraded legacy staff password hash to scrypt');
  }

  await clearLoginAttempts(`staff:${username}`);
  await staffRef.update({ lastLoginAt: FieldValue.serverTimestamp() }).catch(() => {});

  // #6 + #9: issue a real Firebase session (custom token with staff claim)
  // instead of a bare {success:true} the client could forge.
  const role = data.role === 'admin' ? 'admin' : 'staff';
  const customToken = await getAuth().createCustomToken(`staff_${username}`, { role });
  logger.info('Staff login successful');
  return { success: true, username: data.username || username, customToken };
});
