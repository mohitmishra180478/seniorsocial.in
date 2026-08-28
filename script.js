import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js';
import {
  getAuth,
  createUserWithEmailAndPassword,
  sendEmailVerification,
  updateProfile
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js';
import {
  getFirestore,
  doc,
  setDoc,
  serverTimestamp
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js';
import { firebaseConfig, isFirebaseConfigured } from './firebase-config.js';

const legalUndertakingText = 'I confirm that I am a genuine user and that I will not use Senior Social for abuse, misconduct, harassment, fraud, illegal activity, unsafe behaviour, or misuse of the platform. I understand that any such conduct may lead to suspension/removal and appropriate action or proceedings under applicable Indian law.';
const documentUndertakingText = 'I understand that Senior Social requires a current passport-size photo and Aadhaar card picture for internal records and admin review before approval. These documents will be provided manually/offline to admin and are not used for email or mobile verification.';

const menuToggle = document.querySelector('.menu-toggle');
const navLinks = document.querySelector('.nav-links');
const year = document.querySelector('#year');
const joinForm = document.querySelector('#joinForm');
const formMessage = document.querySelector('#formMessage');

let deferredInstallPrompt = null;
const installAppBtn = document.querySelector('#installAppBtn');

let app = null;
let auth = null;
let db = null;

if (isFirebaseConfigured) {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  db = getFirestore(app);
}

if (year) {
  year.textContent = new Date().getFullYear();
}

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => null);
  });
}

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  deferredInstallPrompt = event;
  installAppBtn?.classList.remove('hidden');
});

installAppBtn?.addEventListener('click', async () => {
  if (!deferredInstallPrompt) return;
  deferredInstallPrompt.prompt();
  await deferredInstallPrompt.userChoice;
  deferredInstallPrompt = null;
  installAppBtn.classList.add('hidden');
});

if (menuToggle && navLinks) {
  menuToggle.addEventListener('click', () => {
    navLinks.classList.toggle('open');
  });

  document.querySelectorAll('.nav-links a').forEach((link) => {
    link.addEventListener('click', () => navLinks.classList.remove('open'));
  });
}

function setMessage(message, isError = false) {
  if (!formMessage) return;
  formMessage.textContent = message;
  formMessage.classList.toggle('error-text', isError);
  formMessage.classList.toggle('success-text', !isError);
}

function onlyDigits(value) {
  return String(value || '').replace(/\D/g, '');
}

if (joinForm) {
  joinForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    if (!isFirebaseConfigured || !auth || !db) {
      setMessage('Firebase is not configured yet. Please contact Senior Social directly at info@seniorsocial.in.', true);
      return;
    }

    const submitButton = joinForm.querySelector('button[type="submit"]');
    submitButton.disabled = true;
    submitButton.textContent = 'Saving...';
    setMessage('Creating your registration securely...');

    try {
      const formData = new FormData(joinForm);
      const email = String(formData.get('Email') || '').trim().toLowerCase();
      const password = String(formData.get('Password') || '').trim();
      const fullName = String(formData.get('Full name') || '').trim();
      const ageRaw = String(formData.get('Age') || '').trim();
      const age = Number(ageRaw);
      const phone = onlyDigits(formData.get('Mobile number'));
      const documentUndertakingAccepted = Boolean(formData.get('Document undertaking'));
      const legalUndertakingAccepted = Boolean(formData.get('Legal undertaking'));

      if (!email || !password || !fullName || !ageRaw || !phone) {
        throw new Error('Please complete full name, age, mobile number, email and password.');
      }

      if (!Number.isInteger(age) || age < 60) {
        throw new Error('Age is mandatory and must be 60 years or above.');
      }

      if (phone.length !== 10) {
        throw new Error('Mobile number must be exactly 10 digits. Please enter a valid 10 digit mobile number.');
      }

      if (!documentUndertakingAccepted) {
        throw new Error('Please accept the document undertaking before registration.');
      }

      if (!legalUndertakingAccepted) {
        throw new Error('Please accept the legal undertaking before registration.');
      }

      const credential = await createUserWithEmailAndPassword(auth, email, password);
      const user = credential.user;

      await updateProfile(user, { displayName: fullName });
      await sendEmailVerification(user);

      const profile = {
        uid: user.uid,
        fullName,
        age,
        city: String(formData.get('City') || '').trim(),
        phone,
        email,
        interests: String(formData.get('Interests') || '').trim(),
        lookingFor: String(formData.get('Looking for') || '').trim(),
        preferredVerificationMethod: 'Email verification plus manual admin mobile/document review',
        correctInformationDeclaration: Boolean(formData.get('Correct information declaration')),
        consent: Boolean(formData.get('Consent')),
        emailVerified: user.emailVerified,
        phoneVerified: false,
        phoneVerificationMethod: 'Manual admin verification',
        familyContactVerified: false,
        identityDocumentUploaded: false,
        passportPhotoUploaded: false,
        documentsToBeProvidedOffline: true,
        documentUndertakingAccepted: true,
        documentUndertakingText,
        aadhaarRecordPurposeOnly: true,
        aadhaarNotUsedForEmailOrMobileVerification: true,
        legalUndertakingAccepted: true,
        legalUndertakingText,
        adminApproved: false,
        profileStatus: 'Pending Review',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      };

      await setDoc(doc(db, 'users', user.uid), profile);

      joinForm.reset();
      setMessage('Registration saved successfully. Please check your email verification link. Admin will manually verify mobile number and documents before approval.');
    } catch (error) {
      let friendlyMessage = error.message || 'Unable to save registration. Please try again.';
      if (error.code === 'auth/email-already-in-use') {
        friendlyMessage = 'This email is already registered. Please use a different email or contact Senior Social.';
      }
      if (error.code === 'auth/weak-password') {
        friendlyMessage = 'Please use a password with at least 6 characters.';
      }
      if (error.code === 'auth/invalid-email') {
        friendlyMessage = 'Please enter a valid email address.';
      }
      setMessage(friendlyMessage, true);
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = 'Register Interest';
    }
  });
}
