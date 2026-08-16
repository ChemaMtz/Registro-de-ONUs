const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  })
});

const db = admin.firestore();
const csvFilePath = '/Users/desarolloweb/Downloads/ONUS - Huawei v3.csv';

function parseDouble(value) {
  if (!value) return 0.0;
  const match = value.match(/-?\d+(\.\d+)?/);
  if (match) return parseFloat(match[0]);
  return 0.0;
}

function getValueOrNA(value) {
  const trimmed = value?.trim();
  if (!trimmed || trimmed === '') return 'N/A';
  return trimmed;
}

async function clearCollection() {
  console.log('Limpiando la colección "onus" previa...');
  const snapshot = await db.collection('onus').get();
  const docs = snapshot.docs;
  if (docs.length === 0) return;
  
  const batchSize = 400;
  for (let i = 0; i < docs.length; i += batchSize) {
    const batch = db.batch();
    docs.slice(i, i + batchSize).forEach(doc => batch.delete(doc.ref));
    await batch.commit();
  }
  console.log(`Se eliminaron ${docs.length} documentos antiguos.`);
}

async function uploadAllData() {
  await clearCollection();

  const records = [];
  
  fs.createReadStream(csvFilePath)
    .pipe(csv({
      headers: [
        'ID',
        'numeroSerial',
        'MAC',
        'SSID',
        'Contraseña',
        'Contraseña Antigua',
        'Estado ONU 1',
        'Estado ONU 2',
        'TX',
        'RX',
        'Nombre de Usuario',
        'Localidad',
        'Tipo de Instalacion',
        'Etiqueta',
        'Estado'
      ],
      skipLines: 1
    }))
    .on('data', (data) => {
      // Create the record. Include excel_id temporarily.
      const onuData = {
        excel_id: data.ID?.trim(), // the ID from Excel
        numero_serial: getValueOrNA(data.numeroSerial),
        mac: getValueOrNA(data.MAC),
        ssid: getValueOrNA(data.SSID),
        password: getValueOrNA(data['Contraseña']),
        password_antigua: getValueOrNA(data['Contraseña Antigua']),
        cliente_nombre: getValueOrNA(data['Nombre de Usuario']),
        localidad: getValueOrNA(data['Localidad']),
        nap: 'N/A', 
        etiqueta: getValueOrNA(data['Etiqueta']),
        modelo_ont: 'N/A', 
        tx: parseDouble(data['TX']),
        rx: parseDouble(data['RX']),
        estado_onu: getValueOrNA(data['Estado ONU 1']),
        estado_servicio: getValueOrNA(data['Estado ONU 2']),
        tipo_instalacion: getValueOrNA(data['Tipo de Instalacion']),
        estado: (data['Estado']?.trim() === '') ? 'Libre' : getValueOrNA(data['Estado']),
        tecnico_instalador: 'N/A', 
        soporte_provision: 'N/A' 
      };
      
      // Removed the filter so ALL 5000+ rows go in
      records.push(onuData);
    })
    .on('end', async () => {
      console.log(`Parsed ${records.length} records. Beginning upload to 'onus' collection...`);
      
      const batchSize = 400;
      let committedCount = 0;

      try {
        for (let i = 0; i < records.length; i += batchSize) {
          const batch = db.batch();
          const chunk = records.slice(i, i + batchSize);
          
          chunk.forEach(record => {
            const excelId = record.excel_id;
            delete record.excel_id; // Remove before saving so it doesn't pollute data, or you can keep it. We'll delete it since the ID becomes the docId.

            // Use excelId if valid, otherwise fallback to MAC or auto generated
            let docId = '';
            if (excelId && excelId !== '') {
              docId = excelId;
            } else if (record.mac && record.mac !== 'N/A') {
              docId = record.mac.replace(/:/g, '').toUpperCase();
            }

            const docRef = docId ? db.collection('onus').doc(docId) : db.collection('onus').doc();
            batch.set(docRef, record, { merge: true });
          });
          
          await batch.commit();
          committedCount += chunk.length;
          console.log(`Committed batch ${Math.floor(i / batchSize) + 1} of ${Math.ceil(records.length / batchSize)} (${committedCount} records)`);
        }
        
        console.log('Full upload complete successfully!');
      } catch (error) {
        console.error('Error during upload:', error);
      } finally {
        process.exit(0);
      }
    });
}

uploadAllData().catch(console.error);
