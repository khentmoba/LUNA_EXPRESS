import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { getAuth } from 'firebase-admin/auth';
import { logger } from 'firebase-functions';

/**
 * Firestore-triggered function that listens to rider document status changes
 * and sets the corresponding Firebase Auth custom claim (riderStatus).
 * 
 * Trigger: `riders/{uid}` document updated
 * 
 * When an admin approves or rejects a rider in the Firestore riders collection,
 * this function synchronises the riderStatus custom claim so that Firestore
 * Security Rules and client-side checks can enforce access control.
 */
export const manageRiderStatus = onDocumentUpdated(
  { document: 'riders/{uid}' },
  async (event) => {
    const uid = event.params.uid;
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData) {
      logger.warn(`manageRiderStatus: Missing data for rider ${uid}`);
      return;
    }

    const beforeStatus = beforeData.status as string;
    const afterStatus = afterData.status as string;

    // Only act when status actually changes
    if (beforeStatus === afterStatus) {
      logger.info(
        `manageRiderStatus: No status change for rider ${uid} (${beforeStatus})`,
      );
      return;
    }

    // Validate the new status
    const validStatuses = ['pending', 'approved', 'rejected'];
    if (!validStatuses.includes(afterStatus)) {
      logger.warn(
        `manageRiderStatus: Invalid status "${afterStatus}" for rider ${uid}`,
      );
      return;
    }

    try {
      // Set the custom claim on the Firebase Auth user
      await getAuth().setCustomUserClaims(uid, {
        riderStatus: afterStatus,
      });

      logger.info(
        `manageRiderStatus: Set riderStatus="${afterStatus}" for user ${uid}`,
      );
    } catch (error) {
      logger.error(
        `manageRiderStatus: Failed to set custom claims for user ${uid}:`,
        error,
      );
      throw error;
    }
  },
);
