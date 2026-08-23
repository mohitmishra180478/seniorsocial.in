import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-app.js';
import {
  getAuth,
  signInWithEmailAndPassword,
  onAuthStateChanged,
  signOut
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js';
import {
  getFirestore,
  collection,
  getDocs,
  doc,
  updateDoc,
  serverTimestamp,
  query,
  orderBy
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js';
import { firebaseConfig, isFirebaseConfigured, adminUIDs } from './firebase-config.js?v=20260823-admin-uid';

const configWarning = document.querySelector('#configWarning');
const loginPanel = document.querySelector('#loginPanel');
const dashboardPanel = document.querySelector('#dashboardPanel');
const adminLoginForm = document.querySelector('#adminLoginForm');
const adminEmail = document.querySelector('#adminEmail');
const adminPassword = document.querySelector('#adminPassword');
const loginMessage = document.querySelector('#loginMessage');
const logoutBtn = document.querySelector('#logoutBtn');
const usersTableBody = document.querySelector('#usersTableBody');
const userSearch = document.querySelector('#userSearch');
const exportCsv = document.querySelector('#exportCsv');

const totalUsers = document.querySelector('#totalUsers');
const emailVerifiedUsers = document.querySelector('#emailVerifiedUsers');
const phoneVerifiedUsers = document.querySelector('#phoneVerifiedUsers');
const approvedUsers = document.querySelector('#approvedUsers');
const pendingUsers = document.querySelector('#pendingUsers');

let app;
let auth;
let db;
let allUsers = [];

function show(el) { el?.classList.remove('hidden'); }
function hide(el) { el?.classList.add('hidden'); }
function message(text, isError = false) {
  if (!loginMessage) return;
  loginMessage.textContent = text;
  loginMessage.classList.toggle('error-text', isError);
  loginMessage.classList.toggle('success-text', !isError);
}

function isAllowedAdmin(user) {
  if (!user) return false;
  if (!adminUIDs || adminUIDs.length === 0) return true;
  if (adminUIDs.some((uid) => uid.includes('PASTE_'))) return true;
  return adminUIDs.includes(user.uid);
}

function renderStats(users) {
  totalUsers.textContent = users.length;
  emailVerifiedUsers.textContent = users.filter((u) => u.emailVerified).length;
  phoneVerifiedUsers.textContent = users.filter((u) => u.phoneVerified).length;
  approvedUsers.textContent = users.filter((u) => u.adminApproved).length;
  pendingUsers.textContent = users.filter((u) => (u.profileStatus || '').toLowerCase().includes('pending')).length;
}

function renderUsers(users) {
  renderStats(users);
  usersTableBody.innerHTML = '';

  if (!users.length) {
    usersTableBody.innerHTML = '<tr><td colspan="8">No registrations found yet.</td></tr>';
    return;
  }

  users.forEach((user) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${user.fullName || ''}</strong><br><small>${user.lookingFor || ''}</small></td>
      <td>${user.city || ''}</td>
      <td>${user.phone || ''}</td>
      <td>${user.email || ''}</td>
      <td>${user.emailVerified ? 'Yes' : 'No'}</td>
      <td>${user.phoneVerified ? 'Yes' : 'No'}</td>
      <td>${user.profileStatus || 'Pending Review'}</td>
      <td class="table-actions">
        <button data-action="approve" data-id="${user.uid}">Approve</button>
        <button data-action="pending" data-id="${user.uid}">Pending</button>
        <button data-action="block" data-id="${user.uid}">Block</button>
      </td>
    `;
    usersTableBody.appendChild(tr);
  });
}

async function loadUsers() {
  const usersQuery = query(collection(db, 'users'), orderBy('createdAt', 'desc'));
  const snapshot = await getDocs(usersQuery);
  allUsers = snapshot.docs.map((docSnap) => ({ id: docSnap.id, ...docSnap.data() }));
  renderUsers(allUsers);
}

function filterUsers() {
  const term = (userSearch.value || '').toLowerCase().trim();
  if (!term) return renderUsers(allUsers);
  const filtered = allUsers.filter((u) => [u.fullName, u.city, u.phone, u.email, u.profileStatus].some((v) => String(v || '').toLowerCase().includes(term)));
  renderUsers(filtered);
}

async function updateStatus(uid, action) {
  const statusMap = {
    approve: { profileStatus: 'Admin Approved', adminApproved: true },
    pending: { profileStatus: 'Pending Review', adminApproved: false },
    block: { profileStatus: 'Blocked', adminApproved: false }
  };
  await updateDoc(doc(db, 'users', uid), { ...statusMap[action], updatedAt: serverTimestamp() });
  await loadUsers();
}

function downloadCsv() {
  const headers = ['Full name','Age','City','Mobile','Email','Interests','Looking for','Preferred verification','Email verified','Phone verified','Admin approved','Status'];
  const rows = allUsers.map((u) => [u.fullName, u.age, u.city, u.phone, u.email, u.interests, u.lookingFor, u.preferredVerificationMethod, u.emailVerified, u.phoneVerified, u.adminApproved, u.profileStatus]);
  const csv = [headers, ...rows].map((row) => row.map((cell) => `"${String(cell ?? '').replaceAll('"', '""')}"`).join(',')).join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'senior-social-users.csv';
  a.click();
  URL.revokeObjectURL(url);
}

if (!isFirebaseConfigured) {
  show(configWarning);
  message('Firebase is not configured yet.', true);
} else {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  db = getFirestore(app);

  adminLoginForm?.addEventListener('submit', async (event) => {
    event.preventDefault();
    try {
      message('Logging in...');
      await signInWithEmailAndPassword(auth, adminEmail.value.trim(), adminPassword.value);
    } catch (error) {
      message(error.message || 'Login failed.', true);
    }
  });

  logoutBtn?.addEventListener('click', () => signOut(auth));
  userSearch?.addEventListener('input', filterUsers);
  exportCsv?.addEventListener('click', downloadCsv);

  usersTableBody?.addEventListener('click', async (event) => {
    const button = event.target.closest('button[data-action]');
    if (!button) return;
    await updateStatus(button.dataset.id, button.dataset.action);
  });

  onAuthStateChanged(auth, async (user) => {
    if (user && isAllowedAdmin(user)) {
      hide(loginPanel);
      show(dashboardPanel);
      show(logoutBtn);
      message('Admin access granted.');
      await loadUsers();
    } else {
      show(loginPanel);
      hide(dashboardPanel);
      hide(logoutBtn);
      if (user && !isAllowedAdmin(user)) {
        message(`This account is not authorised as admin. Logged-in UID: ${user.uid}`, true);
        await signOut(auth);
      }
    }
  });
}
