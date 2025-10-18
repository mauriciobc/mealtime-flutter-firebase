import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// HTTP function to manually send feeding notifications
export const sendFeedingNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { catId, householdId, message, type = 'feeding_reminder' } = data;
  
  if (!catId || !householdId) {
    throw new functions.https.HttpsError('invalid-argument', 'catId and householdId are required');
  }
  
  try {
    // Verify user has access to the household
    const householdDoc = await db.collection('households').doc(householdId).get();
    if (!householdDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Household not found');
    }
    
    const household = householdDoc.data();
    const isMember = household?.members?.some((member: any) => member.userId === context.auth.uid);
    
    if (!isMember) {
      throw new functions.https.HttpsError('permission-denied', 'User is not a member of this household');
    }
    
    // Get cat information
    const catDoc = await db.collection('cats').doc(catId).get();
    if (!catDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Cat not found');
    }
    
    const cat = catDoc.data();
    
    // Send notification
    const notificationMessage = {
      topic: `household_${householdId}`,
      notification: {
        title: message || 'Lembrete de Alimentação',
        body: `${cat?.name || 'Gato'} precisa ser alimentado`,
      },
      data: {
        type: type,
        catId: catId,
        householdId: householdId,
        catName: cat?.name || 'Gato',
        sentBy: context.auth.uid,
        timestamp: new Date().toISOString(),
      },
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#6750A4',
          priority: 'high' as const,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };
    
    const response = await admin.messaging().send(notificationMessage);
    
    // Log the notification
    await db.collection('notification_logs').add({
      type: type,
      catId: catId,
      householdId: householdId,
      sentBy: context.auth.uid,
      message: message || 'Lembrete de Alimentação',
      timestamp: new Date(),
      fcmResponse: response,
    });
    
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending feeding notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification');
  }
});

// Function to send weight reminder notifications
export const sendWeightReminder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { catId, householdId, frequency } = data;
  
  if (!catId || !householdId) {
    throw new functions.https.HttpsError('invalid-argument', 'catId and householdId are required');
  }
  
  try {
    // Verify user has access to the household
    const householdDoc = await db.collection('households').doc(householdId).get();
    if (!householdDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Household not found');
    }
    
    const household = householdDoc.data();
    const isMember = household?.members?.some((member: any) => member.userId === context.auth.uid);
    
    if (!isMember) {
      throw new functions.https.HttpsError('permission-denied', 'User is not a member of this household');
    }
    
    // Get cat information
    const catDoc = await db.collection('cats').doc(catId).get();
    if (!catDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Cat not found');
    }
    
    const cat = catDoc.data();
    
    // Send weight reminder notification
    const notificationMessage = {
      topic: `household_${householdId}`,
      notification: {
        title: '📏 Lembrete de Pesagem',
        body: `Hora de pesar ${cat?.name || 'o gato'}`,
      },
      data: {
        type: 'weight_reminder',
        catId: catId,
        householdId: householdId,
        catName: cat?.name || 'Gato',
        frequency: frequency || 'weekly',
        sentBy: context.auth.uid,
        timestamp: new Date().toISOString(),
      },
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#7D5260',
          priority: 'medium' as const,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };
    
    const response = await admin.messaging().send(notificationMessage);
    
    // Log the notification
    await db.collection('notification_logs').add({
      type: 'weight_reminder',
      catId: catId,
      householdId: householdId,
      sentBy: context.auth.uid,
      frequency: frequency || 'weekly',
      timestamp: new Date(),
      fcmResponse: response,
    });
    
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending weight reminder:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send weight reminder');
  }
});
