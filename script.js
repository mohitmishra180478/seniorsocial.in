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
import {
  getStorage,
  ref,
  uploadBytes,
  getDownloadURL
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-storage.js';
import { firebaseConfig, isFirebaseConfigured } from './firebase-config.js';

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
let storage = null;

if (isFirebaseConfigured) {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  db = getFirestore(app);
  storage = getStorage(app);
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

function getFile(formData, fieldName) {
  const file = formData.get(fieldName);
  return file instanceof File && file.size > 0 ? file : null;
}

function validateImageFile(file, label) {
  if (!file) return;
  const allowed = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowed.includes(file.type)) {
    throw new Error(`${label} must be a JPG, PNG or WEBP image.`);
  }
  const maxBytes = 5 * 1024 * 1024;
  if (file.size > maxBytes) {
    throw new Error(`${label} must be less than 5 MB.`);
  }
}

function addLegalUndertakingCheckbox() {
  if (!joinForm || document.querySelector('#legalUndertaking')) return;
  const submitButton = joinForm.querySelector('button[type="submit"]');
  if (!submitButton) return;

  const undertaking = document.createElement('label');
  undertaking.className = 'consent-line';
  undertaking.innerHTML = '<input id="legalUndertaking" name="Legal undertaking" type="checkbox" required /> I confirm that I am a genuine user and I undertake to use Senior Social only for lawful, respectful and genuine social connection purposes. I understand that any abuse, misconduct, harassment, fraud, illegal activity, misuse of the platform or unsafe behaviour may lead to removal from Senior Social and appropriate proceedings/action under applicable Indian law.';
  submitButton.parentNode.insertBefore(undertaking, submitButton);
}

async function uploadUserFile(userUid, file, type) {
  if (!file || !storage) return null;
  const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
  const filePath = `users/${userUid}/${type}-${Date.now()}-${safeName}`;
  const fileRef = ref(storage, filePath);
  await uploadBytes(fileRef, file);
  const url = await getDownloadURL(fileRef);
  return { path: filePath, url, name: file.name, contentType: file.type, size: file.size };
}

addLegalUndertakingCheckbox();

if (joinForm) {
  joinForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    if (!isFirebaseConfigured || !auth || !db || !storage) {
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
      const passportPhotoFile = getFile(formData, 'Passport size photo');
      const aadhaarPhotoFile = getFile(formData, 'Aadhaar card picture');
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

      if (!passportPhotoFile) {
        throw new Error('Current passport size photo is mandatory.');
      }

      if (!aadhaarPhotoFile) {
        throw new Error('Aadhaar card picture is mandatory for internal records. It is not used for email or mobile verification.');
      }

      if (!legalUndertakingAccepted) {
        throw new Error('Please accept the mandatory user undertaking before registering.');
      }

      validateImageFile(passportPhotoFile, 'Passport size photo');
      validateImageFile(aadhaarPhotoFile, 'Aadhaar card picture');

      const credential = await createUserWithEmailAndPassword(auth, email, password);
      const user = credential.user;

      await updateProfile(user, { displayName: fullName });
      await sendEmailVerification(user);

      setMessage('Uploading documents securely...');
      const passportPhoto = await uploadUserFile(user.uid, passportPhotoFile, 'passport-photo');
      const aadhaarCardPicture = await uploadUserFile(user.uid, aadhaarPhotoFile, 'aadhaar-card');

      const profile = {
        uid: user.uid,
        fullName,
        age,
        city: String(formData.get('City') || '').trim(),
        phone,
        email,
        interests: String(formData.get('Interests') || '').trim(),
        lookingFor: String(formData.get('Looking for') || '').trim(),
        preferredVerificationMethod: String(formData.get('Preferred verification method') || '').trim(),
        passportPhoto,
        aadhaarCardPicture,
        correctInformationDeclaration: Boolean(formData.get('Correct information declaration')),
        consent: Boolean(formData.get('Consent')),
        legalUndertakingAccepted,
        legalUndertakingText: 'I confirm that I am a genuine user and I undertake to use Senior Social only for lawful, respectful and genuine social connection purposes. I understand that any abuse, misconduct, harassment, fraud, illegal activity, misuse of the platform or unsafe behaviour may lead to removal from Senior Social and appropriate proceedings/action under applicable Indian law.',
        emailVerified: user.emailVerified,
        phoneVerified: false,
        familyContactVerified: false,
        identityDocumentUploaded: true,
        passportPhotoUploaded: Boolean(passportPhoto),
        adminApproved: false,
        profileStatus: 'Pending Review',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      };

      await setDoc(doc(db, 'users', user.uid), profile);

      joinForm.reset();
      setMessage('Registration saved successfully. Please check your email and click the verification link. Senior Social will review the profile before connecting members.');
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
      if (error.code === 'storage/unauthorized') {
        friendlyMessage = 'Document upload is not allowed yet. Please enable Firebase Storage and update Storage rules.';
      }
      setMessage(friendlyMessage, true);
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = 'Register Interest';
    }
  });
}
