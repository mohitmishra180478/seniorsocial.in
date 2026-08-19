// Senior Social India Firebase configuration
// Replace the placeholder values below with your Firebase Web App config.
// Firebase Console > Project settings > Your apps > Web app > SDK setup and configuration.

export const firebaseConfig = {
  apiKey: "PASTE_FIREBASE_API_KEY_HERE",
  authDomain: "PASTE_PROJECT_ID.firebaseapp.com",
  projectId: "PASTE_PROJECT_ID",
  storageBucket: "PASTE_PROJECT_ID.firebasestorage.app",
  messagingSenderId: "PASTE_MESSAGING_SENDER_ID",
  appId: "PASTE_APP_ID"
};

export const isFirebaseConfigured = !firebaseConfig.apiKey.includes("PASTE_") && !firebaseConfig.projectId.includes("PASTE_");

// Add the Firebase Auth UID of your admin account here after you create your admin login.
export const adminUIDs = [
  "PASTE_ADMIN_FIREBASE_UID_HERE"
];
