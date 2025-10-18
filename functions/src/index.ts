import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export all functions
export { checkFeedingReminders } from './feedingReminders';
export { handleEscalationAlerts } from './escalationAlerts';
export { sendFeedingNotification } from './sendFeedingNotification';
