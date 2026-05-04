const admin = require('firebase-admin');
const Notification = require('../models/notification');

const sendNotification = async (user, title, message, type) => {
  try {
    // Save in DB
    const notif = await Notification.create({
      user: user._id,
      title,
      message,
      type,
    });

    // Send FCM
    if (user.fcmToken) {
      await admin.messaging().send({
        token: user.fcmToken,
        notification: {
          title,
          body: message,
        },
        data: {
          type,
        },
      });
    }

    return notif;
  } catch (error) {
    console.log("Notification Error:", error.message);
  }
};

module.exports = sendNotification;