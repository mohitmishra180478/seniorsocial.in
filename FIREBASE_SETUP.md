# Senior Social India - Firebase Setup

This website is ready to connect with Firebase for:

- User registration
- Email verification
- Phone OTP verification
- Firestore user database
- Admin dashboard
- User approval status
- Verified / pending / blocked member tracking

## 1. Create Firebase Project

1. Go to Firebase Console.
2. Click **Add project**.
3. Project name: `Senior Social India`.
4. Continue and create the project.

## 2. Add Web App

1. In Firebase project, click the web icon `</>`.
2. App nickname: `Senior Social Website`.
3. Register app.
4. Copy the Firebase config.

It will look like this:

```js
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "..."
};
```

Paste this config into `firebase-config.js`.

## 3. Enable Authentication

In Firebase:

1. Go to **Authentication**.
2. Click **Get started**.
3. Open **Sign-in method**.
4. Enable:
   - Email/Password
   - Phone

## 4. Add Authorised Domains

In Authentication settings, authorised domains should include:

- `seniorsocial.in`
- `www.seniorsocial.in`
- `localhost` for testing

## 5. Create Firestore Database

1. Go to **Firestore Database**.
2. Click **Create database**.
3. Start in production mode.
4. Select a region close to India, if available.
5. Create database.

## 6. Firestore Collections

The website will store users like this:

```text
users/{userId}
  fullName
  age
  city
  phone
  email
  interests
  lookingFor
  preferredVerificationMethod
  emailVerified
  phoneVerified
  adminApproved
  profileStatus
  createdAt
  updatedAt
```

## 7. Admin Dashboard

Admin page:

```text
/admin.html
```

The admin dashboard will show:

- Total users
- Verified users
- Pending users
- Approved users
- Blocked users
- Full user list
- City
- Mobile
- Email
- Verification status
- Admin status

## 8. Important Safety Rule

Do not publicly show senior members' mobile numbers, email addresses or identity details. Use admin approval before connecting members with groups or other members.

## 9. Next Step

After creating the Firebase project, copy your Firebase config and send it to the developer/ChatGPT to paste into `firebase-config.js`.
