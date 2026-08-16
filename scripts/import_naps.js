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

const results = [];
const localidades = new Set();
const naps = new Set();
const prefijosMap = {};

fs.createReadStream('../NAP CLIENTES - LISTA GENERAL.csv')
  .pipe(csv())
  .on('data', (data) => {
    // Las columnas son: MUNICIPIO ,LOCALIDAD,NAP
    const rawMunicipio = data['MUNICIPIO '] || data['MUNICIPIO'];
    const rawLocalidad = data['LOCALIDAD'];
    const rawNap = data['NAP'];

    if (!rawLocalidad || !rawNap) return;

    const localidad = rawLocalidad.trim();
    const nap = rawNap.trim();
    
    localidades.add(localidad);
    naps.add(nap);

    // Detect prefix from NAP
    // NAP format example: "BB 201" -> prefix is "BB-" or just "BB " or "BB". Let's use the letters before space/number
    let match = nap.match(/^([A-Za-zÑñ]+)[ -._]?\d/);
    if (!match) match = nap.match(/^([A-Za-zÑñ]+)/); // Fallback
    
    if (match) {
        let prefix = match[1].toUpperCase(); // Sin guion, solo letras (ej: BB, CH, ACT)
        let locKey = localidad.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
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
    console.log(`Encontradas ${localidades.size} localidades únicas y ${naps.size} NAPs.`);
    
    // Upload to Firestore
    try {
        const docRef = db.collection('onus').doc('---config_catalogs---');
        const docSnap = await docRef.get();
        let existingZonas = [];
        let existingNaps = [];
        let existingPrefijos = {};

        if (docSnap.exists) {
            const data = docSnap.data();
            existingZonas = data.zonas || [];
            existingNaps = data.naps || [];
            existingPrefijos = data.prefijos || {};
        }

        const mergedZonas = Array.from(new Set([...existingZonas, ...Array.from(localidades)])).sort();
        const mergedNaps = Array.from(new Set([...existingNaps, ...Array.from(naps)])).sort();
        const mergedPrefijos = { ...existingPrefijos, ...prefijosMap };

        await docRef.set({
            zonas: mergedZonas,
            naps: mergedNaps,
            prefijos: mergedPrefijos
        }, { merge: true });

        console.log('¡Catálogos (Localidades, NAPs y Prefijos) actualizados en Firestore exitosamente!');
        process.exit(0);
    } catch (e) {
        console.error('Error:', e);
        process.exit(1);
    }
  });
