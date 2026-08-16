const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');
const serviceAccount = require('../serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}
const db = admin.firestore();

const prefijosMap = {};

fs.createReadStream('../NAP CLIENTES - LISTA GENERAL.csv')
  .pipe(csv())
  .on('data', (data) => {
    const rawLocalidad = data['LOCALIDAD'];
    const rawNap = data['NAP'];

    if (!rawLocalidad || !rawNap) return;

    const localidad = rawLocalidad.trim();
    const nap = rawNap.trim();
    
    // Detect exact prefix including separator before numbers
    // This will capture "BB ", "CCA ", "ACT ", "C ", etc.
    let match = nap.match(/^([A-Za-zÑñ]+[ \-._]?)/); 
    
    if (match) {
        let prefix = match[1].toUpperCase();
        let locKey = localidad.toLowerCase();
        if (!prefijosMap[locKey]) {
            prefijosMap[locKey] = prefix;
        } else {
            let existingPrefixes = prefijosMap[locKey].split(',');
            if (!existingPrefixes.includes(prefix)) {
                prefijosMap[locKey] = prefijosMap[locKey] + ',' + prefix;
            }
        }
    }
  })
  .on('end', async () => {
    try {
        const docRef = db.collection('onus').doc('---config_catalogs---');
        // Actualizar solo los prefijos
        await docRef.set({
            prefijos: prefijosMap
        }, { merge: true });

        console.log('Prefijos corregidos subidos a Firestore.');
        process.exit(0);
    } catch (e) {
        console.error('Error:', e);
        process.exit(1);
    }
  });
