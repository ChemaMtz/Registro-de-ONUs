const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializa Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function populateCatalogs() {
  console.log('Obteniendo ONUs de la base de datos...');
  const snapshot = await db.collection('onus').get();
  
  // Valores iniciales solicitados por el usuario
  const zonas = new Set(['Actopan', 'Huichapan']);
  const modelos = new Set(['Huawei V5', 'Huawei V5V3', 'Skyworth', 'Nokia', 'Ping Com']);
  const tecnicos = new Set(['Josmar', 'Luis']);
  const soportes = new Set(['Pablo', 'Kevin']);

  snapshot.docs.forEach(doc => {
    const data = doc.data();
    
    if (data.localidad && data.localidad !== 'N/A' && data.localidad.trim() !== '') zonas.add(data.localidad.trim());
    if (data.modelo_ont && data.modelo_ont !== 'N/A' && data.modelo_ont.trim() !== '') modelos.add(data.modelo_ont.trim());
    if (data.tecnico_instalador && data.tecnico_instalador !== 'N/A' && data.tecnico_instalador.trim() !== '') tecnicos.add(data.tecnico_instalador.trim());
    if (data.soporte_provision && data.soporte_provision !== 'N/A' && data.soporte_provision.trim() !== '') soportes.add(data.soporte_provision.trim());
  });

  // Convertir a arrays
  const catalogData = {
    zonas: Array.from(zonas),
    modelos: Array.from(modelos),
    tecnicos: Array.from(tecnicos),
    soportes: Array.from(soportes)
  };

  console.log('Guardando catálogos en Firestore (config/catalogs)...');
  await db.collection('config').doc('catalogs').set(catalogData, { merge: true });

  console.log('✅ Catálogos actualizados correctamente.');
}

populateCatalogs()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('Error al poblar catálogos:', error);
    process.exit(1);
  });
