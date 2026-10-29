import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
} from 'firebase/auth';
import { auth } from '../firebase';

function friendlyError(err) {
  switch (err.code) {
    case 'auth/email-already-in-use':
      return 'An account already exists for this email. Try logging in instead.';
    case 'auth/invalid-email':
      return 'That email address looks invalid.';
    case 'auth/weak-password':
      return 'Password should be at least 6 characters.';
    case 'auth/user-not-found':
    case 'auth/wrong-password':
    case 'auth/invalid-credential':
      return 'Incorrect email or password.';
    case 'auth/too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    default:
      return err.message || 'Something went wrong. Please try again.';
  }
}

export async function signUp(email, password) {
  try {
    const cred = await createUserWithEmailAndPassword(auth, email, password);
    return { success: true, user: cred.user };
  } catch (err) {
    return { success: false, message: friendlyError(err) };
  }
}

export async function login(email, password) {
  try {
    const cred = await signInWithEmailAndPassword(auth, email, password);
    return { success: true, user: cred.user };
  } catch (err) {
    return { success: false, message: friendlyError(err) };
  }
}

export function signOut() {
  return firebaseSignOut(auth);
}
export const logOut = signOut;

export function watchAuthState(callback) {
  return onAuthStateChanged(auth, callback);
}

export function getCurrentUser() {
  return auth.currentUser;
}
