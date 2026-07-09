"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.manageRiderStatus = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const auth_1 = require("firebase-admin/auth");
const firebase_functions_1 = require("firebase-functions");
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
exports.manageRiderStatus = (0, firestore_1.onDocumentUpdated)({ document: 'riders/{uid}' }, async (event) => {
    const uid = event.params.uid;
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) {
        firebase_functions_1.logger.warn(`manageRiderStatus: Missing data for rider ${uid}`);
        return;
    }
    const beforeStatus = beforeData.status;
    const afterStatus = afterData.status;
    // Only act when status actually changes
    if (beforeStatus === afterStatus) {
        firebase_functions_1.logger.info(`manageRiderStatus: No status change for rider ${uid} (${beforeStatus})`);
        return;
    }
    // Validate the new status
    const validStatuses = ['pending', 'approved', 'rejected'];
    if (!validStatuses.includes(afterStatus)) {
        firebase_functions_1.logger.warn(`manageRiderStatus: Invalid status "${afterStatus}" for rider ${uid}`);
        return;
    }
    try {
        // Set the custom claim on the Firebase Auth user
        await (0, auth_1.getAuth)().setCustomUserClaims(uid, {
            riderStatus: afterStatus,
        });
        firebase_functions_1.logger.info(`manageRiderStatus: Set riderStatus="${afterStatus}" for user ${uid}`);
    }
    catch (error) {
        firebase_functions_1.logger.error(`manageRiderStatus: Failed to set custom claims for user ${uid}:`, error);
        throw error;
    }
});
//# sourceMappingURL=manage_rider_status.js.map