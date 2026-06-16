"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyStaff = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const crypto = __importStar(require("crypto"));
const firebase_functions_1 = require("firebase-functions");
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}
exports.verifyStaff = (0, https_1.onCall)(async (request) => {
    const { username, password } = request.data;
    if (!username || !password) {
        throw new https_1.HttpsError('invalid-argument', 'Missing username or password');
    }
    const db = (0, firestore_1.getFirestore)();
    const collectionRef = db.collection('staff_accounts');
    // Auto-seed if the collection is empty
    const snapshot = await collectionRef.limit(1).get();
    if (snapshot.empty) {
        firebase_functions_1.logger.info('staff_accounts collection is empty. Seeding default accounts...');
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
        firebase_functions_1.logger.info('Successfully seeded default staff accounts.');
    }
    const staffRef = collectionRef.doc(username.toLowerCase());
    const doc = await staffRef.get();
    if (!doc.exists) {
        firebase_functions_1.logger.info(`Staff login failed: User ${username} not found`);
        return { success: false, message: 'Invalid username or password' };
    }
    const data = doc.data();
    if (!data || !data.passwordHash) {
        firebase_functions_1.logger.error(`Staff login failed: User ${username} has no passwordHash field`);
        return { success: false, message: 'Invalid server configuration' };
    }
    const hash = hashPassword(password);
    if (hash === data.passwordHash) {
        firebase_functions_1.logger.info(`Staff login successful: ${username}`);
        return { success: true, username: data.username || username };
    }
    else {
        firebase_functions_1.logger.info(`Staff login failed: Incorrect password for ${username}`);
        return { success: false, message: 'Invalid username or password' };
    }
});
//# sourceMappingURL=verify_staff.js.map