import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface EscalationLog {
  catId: string;
  catName: string;
  householdId: string;
  householdName: string;
  timestamp: Date;
  type: string;
  severity: string;
}

// Function to handle escalation alerts
export const handleEscalationAlerts = functions.firestore
  .document('escalation_logs/{logId}')
  .onCreate(async (snap, context) => {
    const escalationLog = snap.data() as EscalationLog;
    
    console.log(`Processing escalation alert: ${escalationLog.type} for ${escalationLog.catName}`);
    
    try {
      // Get household members
      const householdDoc = await db.collection('households').doc(escalationLog.householdId).get();
      if (!householdDoc.exists) {
        console.log(`Household ${escalationLog.householdId} not found`);
        return null;
      }
      
      const household = householdDoc.data();
      const members = household?.members || [];
      
      // Send escalation notification to all members
      await sendEscalationNotification(escalationLog, members);
      
      // If severity is high and it's been more than 2 hours, send additional alert
      if (escalationLog.severity === 'high') {
        const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
        if (escalationLog.timestamp < twoHoursAgo) {
          await sendCriticalEscalationAlert(escalationLog, members);
        }
      }
      
      return null;
    } catch (error) {
      console.error('Error handling escalation alert:', error);
      return null;
    }
  });

async function sendEscalationNotification(
  escalationLog: EscalationLog, 
  members: any[]
) {
  try {
    const message = {
      topic: `household_${escalationLog.householdId}`,
      notification: {
        title: '🚨 Alerta de Escalação',
        body: `Atenção! ${escalationLog.catName} precisa de cuidados urgentes`,
      },
      data: {
        type: 'escalation_alert',
        catId: escalationLog.catId,
        householdId: escalationLog.householdId,
        catName: escalationLog.catName,
        severity: escalationLog.severity,
        alertType: escalationLog.type,
      },
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#BA1A1A',
          priority: 'high' as const,
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            alert: {
              title: '🚨 Alerta de Escalação',
              body: `Atenção! ${escalationLog.catName} precisa de cuidados urgentes`,
            },
          },
        },
      },
    };
    
    const response = await admin.messaging().send(message);
    console.log(`Escalation notification sent: ${response}`);
  } catch (error) {
    console.error('Error sending escalation notification:', error);
  }
}

async function sendCriticalEscalationAlert(
  escalationLog: EscalationLog, 
  members: any[]
) {
  try {
    const message = {
      topic: `household_${escalationLog.householdId}`,
      notification: {
        title: '🚨 URGENTE - Ação Necessária',
        body: `${escalationLog.catName} não foi alimentado há mais de 3 horas! Verifique imediatamente.`,
      },
      data: {
        type: 'critical_escalation',
        catId: escalationLog.catId,
        householdId: escalationLog.householdId,
        catName: escalationLog.catName,
        severity: 'critical',
        alertType: escalationLog.type,
      },
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#BA1A1A',
          priority: 'high' as const,
          sound: 'default',
          vibrate: [0, 250, 250, 250],
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            alert: {
              title: '🚨 URGENTE - Ação Necessária',
              body: `${escalationLog.catName} não foi alimentado há mais de 3 horas! Verifique imediatamente.`,
            },
            category: 'CRITICAL_ALERT',
          },
        },
      },
    };
    
    const response = await admin.messaging().send(message);
    console.log(`Critical escalation alert sent: ${response}`);
    
    // Log critical escalation
    await db.collection('escalation_logs').add({
      ...escalationLog,
      type: 'critical_escalation',
      severity: 'critical',
      timestamp: new Date(),
    });
  } catch (error) {
    console.error('Error sending critical escalation alert:', error);
  }
}

// Function to clean up old escalation logs (runs daily)
export const cleanupEscalationLogs = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    console.log('Cleaning up old escalation logs...');
    
    try {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      
      const oldLogsSnapshot = await db.collection('escalation_logs')
        .where('timestamp', '<', thirtyDaysAgo)
        .get();
      
      const batch = db.batch();
      oldLogsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      await batch.commit();
      console.log(`Cleaned up ${oldLogsSnapshot.docs.length} old escalation logs`);
      
      return null;
    } catch (error) {
      console.error('Error cleaning up escalation logs:', error);
      return null;
    }
  });
