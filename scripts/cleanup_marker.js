const admin = require('firebase-admin');
const path = require('path');

// Usar el archivo de clave de cuenta de servicio directamente
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const docId = '---localidad_normalized_v1---';

async function cleanup() {
  try {
    const ref = db.collection('onus').doc(docId);
    const snap = await ref.get();

    if (!snap.exists) {
      console.log(`El documento "${docId}" no existe. Nada que borrar.`);
      return;
    }

    await ref.delete();
    console.log(`Documento "${docId}" eliminado exitosamente.`);
  } catch (err) {
    console.error('Error al eliminar:', err.message);
    process.exit(1);
  }
}

cleanup();
