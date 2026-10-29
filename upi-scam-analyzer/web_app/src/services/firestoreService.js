import {
  collection,
  addDoc,
  query,
  orderBy,
  limit,
  onSnapshot,
} from 'firebase/firestore';
import { db } from '../firebase';

function scansRef(uid) {
  return collection(db, 'users', uid, 'scans');
}

export async function saveScan(uid, result) {
  await addDoc(scansRef(uid), {
    ...result,
    timestamp: result.timestamp || new Date().toISOString(),
  });
}

/**
 * Subscribes to the user's scan history.
 * @returns unsubscribe function
 */
export function watchHistory(uid, onData) {
  const q = query(scansRef(uid), orderBy('timestamp', 'desc'), limit(100));
  return onSnapshot(q, (snap) => {
    const scans = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    onData(scans);
  });
}
