import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import * as crypto from 'crypto';
import { logger } from 'firebase-functions';

function hashPassword(password: string): string {
  return crypto.createHash('sha256').update(password).digest('hex');
}


export const verifyStaff = onCall(async (request) => {
  const { username, password } = request.data;
  if (!username || !password) {
    throw new HttpsError('invalid-argument', 'Missing username or password');
  }

  const db = getFirestore();
  const collectionRef = db.collection('staff_accounts');

  // Auto-seed if the collection is empty
  const snapshot = await collectionRef.limit(1).get();
  if (snapshot.empty) {
    logger.info('staff_accounts collection is empty. Seeding default accounts...');
    const batch = db.batch();

    const defaults = [
      { username: 'admin', password: 'luna2024' },
      { username: 'staff1', password: 'staff1234' },
      { username: 'staff2', password: 'staff5678' }
    ];

    for (const user of defaults) {
      const docRef = collectionRef.doc(user.username);
      batch.set(docRef, {
        username: user.username,
        passwordHash: hashPassword(user.password),
        createdAt: new Date()
      });
    }
    await batch.commit();
    logger.info('Successfully seeded default staff accounts.');
  }

  const staffRef = collectionRef.doc(username.toLowerCase());
  const doc = await staffRef.get();

  if (!doc.exists) {
    logger.info(`Staff login failed: User ${username} not found`);
    return { success: false, message: 'Invalid username or password' };
  }

  const data = doc.data();
  if (!data || !data.passwordHash) {
    logger.error(`Staff login failed: User ${username} has no passwordHash field`);
    return { success: false, message: 'Invalid server configuration' };
  }

  const hash = hashPassword(password);

  if (hash === data.passwordHash) {
    logger.info(`Staff login successful: ${username}`);
    return { success: true, username: data.username || username };
  } else {
    logger.info(`Staff login failed: Incorrect password for ${username}`);
    return { success: false, message: 'Invalid username or password' };
  }
});
