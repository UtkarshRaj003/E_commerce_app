const admin = require('firebase-admin');

const firebaseConfig = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!firebaseConfig) {
  console.error("❌ Error: FIREBASE_SERVICE_ACCOUNT variable nahi mila!");
  process.exit(1); 
}

try {
  const serviceAccount = JSON.parse(firebaseConfig);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("✅ Firebase Admin initialized successfully!");
} catch (error) {
  console.error("❌ Error: Firebase JSON parse karne mein dikat hai:", error.message);
  process.exit(1);
}

module.exports = admin;