import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

interface Cat {
  id: string;
  name: string;
  householdId: string;
  schedule: {
    type: string;
    intervalHours?: number;
    fixedTimes?: string[];
    isActive: boolean;
  };
}

interface Household {
  id: string;
  name: string;
  members: Array<{
    userId: string;
    role: string;
  }>;
}

// Scheduled function that runs every 15 minutes
export const checkFeedingReminders = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    console.log('Checking feeding reminders...');
    
    try {
      const now = new Date();
      const currentTime = now.toTimeString().slice(0, 5); // HH:MM format
      
      // Get all cats with active schedules
      const catsSnapshot = await db.collection('cats')
        .where('schedule.isActive', '==', true)
        .get();
      
      if (catsSnapshot.empty) {
        console.log('No cats with active schedules found');
        return null;
      }
      
      const cats = catsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Cat[];
      
      // Group cats by household for batch processing
      const householdCats = new Map<string, Cat[]>();
      for (const cat of cats) {
        if (!householdCats.has(cat.householdId)) {
          householdCats.set(cat.householdId, []);
        }
        householdCats.get(cat.householdId)!.push(cat);
      }
      
      // Process each household
      for (const [householdId, householdCatsList] of householdCats) {
        await processHouseholdFeedingReminders(householdId, householdCatsList, now);
      }
      
      console.log('Feeding reminders check completed');
      return null;
    } catch (error) {
      console.error('Error checking feeding reminders:', error);
      return null;
    }
  });

async function processHouseholdFeedingReminders(
  householdId: string, 
  cats: Cat[], 
  now: Date
) {
  try {
    // Get household data
    const householdDoc = await db.collection('households').doc(householdId).get();
    if (!householdDoc.exists) {
      console.log(`Household ${householdId} not found`);
      return;
    }
    
    const household = householdDoc.data() as Household;
    
    // Get recent feedings for this household (last 24 hours)
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const recentFeedingsSnapshot = await db.collection('feedings')
      .where('householdId', '==', householdId)
      .where('timestamp', '>=', yesterday)
      .get();
    
    const recentFeedings = recentFeedingsSnapshot.docs.map(doc => doc.data());
    
    // Check each cat for overdue feedings
    for (const cat of cats) {
      await checkCatFeedingReminder(cat, household, recentFeedings, now);
    }
  } catch (error) {
    console.error(`Error processing household ${householdId}:`, error);
  }
}

async function checkCatFeedingReminder(
  cat: Cat, 
  household: Household, 
  recentFeedings: any[], 
  now: Date
) {
  try {
    const catFeedings = recentFeedings.filter(f => f.catId === cat.id);
    const lastFeeding = catFeedings.length > 0 
      ? new Date(catFeedings[0].timestamp) 
      : null;
    
    let isOverdue = false;
    let nextFeedingTime: Date | null = null;
    
    if (cat.schedule.type === 'interval') {
      // Check interval-based schedule
      if (cat.schedule.intervalHours) {
        const hoursSinceLastFeeding = lastFeeding 
          ? (now.getTime() - lastFeeding.getTime()) / (1000 * 60 * 60)
          : 999; // If no feeding recorded, consider overdue
        
        if (hoursSinceLastFeeding >= cat.schedule.intervalHours) {
          isOverdue = true;
          nextFeedingTime = lastFeeding 
            ? new Date(lastFeeding.getTime() + cat.schedule.intervalHours * 60 * 60 * 1000)
            : now;
        }
      }
    } else if (cat.schedule.type === 'fixed') {
      // Check fixed-time schedule
      if (cat.schedule.fixedTimes && cat.schedule.fixedTimes.length > 0) {
        const currentTime = now.toTimeString().slice(0, 5);
        const today = now.toDateString();
        
        // Check if any scheduled time has passed today without feeding
        for (const scheduledTime of cat.schedule.fixedTimes) {
          if (currentTime >= scheduledTime) {
            const scheduledDateTime = new Date(`${today} ${scheduledTime}`);
            const hasFeedingAtTime = catFeedings.some(f => {
              const feedingTime = new Date(f.timestamp);
              return feedingTime.toDateString() === today && 
                     feedingTime.toTimeString().slice(0, 5) >= scheduledTime;
            });
            
            if (!hasFeedingAtTime) {
              isOverdue = true;
              nextFeedingTime = scheduledDateTime;
              break;
            }
          }
        }
      }
    }
    
    if (isOverdue) {
      await sendFeedingReminderNotification(cat, household, nextFeedingTime);
      
      // Check if it's been more than 1 hour overdue for escalation
      if (nextFeedingTime && (now.getTime() - nextFeedingTime.getTime()) > 60 * 60 * 1000) {
        await triggerEscalationAlert(cat, household);
      }
    }
  } catch (error) {
    console.error(`Error checking cat ${cat.id} feeding reminder:`, error);
  }
}

async function sendFeedingReminderNotification(
  cat: Cat, 
  household: Household, 
  overdueTime: Date | null
) {
  try {
    const message = {
      topic: `household_${cat.householdId}`,
      notification: {
        title: 'Hora da alimentação! 🐱',
        body: `${cat.name} precisa ser alimentado`,
      },
      data: {
        type: 'feeding_reminder',
        catId: cat.id,
        householdId: cat.householdId,
        catName: cat.name,
        overdueTime: overdueTime?.toISOString() || '',
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
    
    const response = await admin.messaging().send(message);
    console.log(`Feeding reminder sent for ${cat.name}: ${response}`);
  } catch (error) {
    console.error(`Error sending feeding reminder for ${cat.name}:`, error);
  }
}

async function triggerEscalationAlert(cat: Cat, household: Household) {
  try {
    const message = {
      topic: `household_${cat.householdId}`,
      notification: {
        title: '⚠️ Alimentação Atrasada',
        body: `${cat.name} não foi alimentado há mais de 1 hora!`,
      },
      data: {
        type: 'escalation_alert',
        catId: cat.id,
        householdId: cat.householdId,
        catName: cat.name,
        severity: 'high',
      },
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#BA1A1A',
          priority: 'high' as const,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            alert: {
              title: '⚠️ Alimentação Atrasada',
              body: `${cat.name} não foi alimentado há mais de 1 hora!`,
            },
          },
        },
      },
    };
    
    const response = await admin.messaging().send(message);
    console.log(`Escalation alert sent for ${cat.name}: ${response}`);
    
    // Log escalation in Firestore
    await db.collection('escalation_logs').add({
      catId: cat.id,
      catName: cat.name,
      householdId: cat.householdId,
      householdName: household.name,
      timestamp: new Date(),
      type: 'feeding_overdue',
      severity: 'high',
    });
  } catch (error) {
    console.error(`Error sending escalation alert for ${cat.name}:`, error);
  }
}
