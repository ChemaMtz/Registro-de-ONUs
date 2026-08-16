const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializa Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function inspectDoc() {
  const snapshot = await db.collection('onus').limit(1).get();
  snapshot.docs.forEach(doc => {
    console.log(doc.data());
  });
}

inspectDoc()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
