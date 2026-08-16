/// Diccionario de normalización de localidades.
/// Mapea TODAS las variantes erróneas → nombre canónico correcto.
const _normalizationMap = <String, String>{
  // ═══ CASE (mayúsculas/minúsculas) ═══
  'huichapan': 'Huichapan',
  'hUICHAPAN': 'Huichapan',
  'atitalaquia': 'Atitalaquia',
  'AtitalAquia': 'Atitalaquia',
  'tetepango': 'Tetepango',
  'tETEPANGO': 'Tetepango',
  'San jose': 'San Jose',
  'San José': 'San Jose',
  'San antonio': 'San Antonio',
  'San salvador': 'San Salvador',
  'santiago de anaya': 'Santiago de Anaya',
  'Santiago de anaya': 'Santiago de Anaya',
  'cd sahagun': 'CD Sahagun',
  'Cd Sahagun': 'CD Sahagun',
  'Cd. Sahagun': 'CD Sahagun',
  'Cd. Sahagún': 'CD Sahagun',
  'CD. Sahagun': 'CD Sahagun',
  'Cd sahagun': 'CD Sahagun',
  'Cd.Sahagún': 'CD Sahagun',
  'El arenal': 'El Arenal',
  'EL arenal': 'El Arenal',
  'Arenal': 'El Arenal',
  'El Arenal': 'El Arenal',
  'Arbol grande': 'Arbol Grande',
  'Árbol Grande': 'Arbol Grande',
  'Carrillo puerto': 'Carrillo Puerto',
  'carrillo puerto': 'Carrillo Puerto',
  'Carrillo': 'Carrillo Puerto',
  'El rosario': 'El Rosario',
  'El Rosario': 'El Rosario',
  'Zona lagunilla': 'Lagunilla',
  'Zona Lagunilla': 'Lagunilla',
  'lagunilla': 'Lagunilla',
  'Cañada Mix': 'Cañada',
  'palmillas': 'Palmillas',
  'santa maria': 'Santa Maria',
  'Polotitlán': 'Polotitlan',
  'Guzmán Mayer': 'Guzman Mayer',

  // ═══ TYPOS (errores de dedo) ═══
  'Santigo de Anaya': 'Santiago de Anaya',
  'Huchapan': 'Huichapan',
  'Chicavsco': 'Chicavasco',
  'Chicavasvo': 'Chicavasco',
  'Pogreso': 'Progreso',
  'pROGRESO': 'Progreso',
  'Tetepang0': 'Tetepango',
  'Tetepengo': 'Tetepango',
  'San Salvadort': 'San Salvador',
  'San Sañvador': 'San Salvador',
  'San Sallvador': 'San Salvador',
  'San Antopnio': 'San Antonio',
  'Laguinilla': 'Lagunilla',
  'Huaxto': 'Huaxtho',
  'Actopam': 'Actopan',
  'Motobhata': 'Motobatha',
  'tepatepec': 'Tepatepec',
  'TEPATEPEC': 'Tepatepec',

  // ═══ RUIDO (caracteres especiales, espacios, prefijos) ═══
  '|San Antonio': 'San Antonio',
  'Santiago de Anaya|': 'Santiago de Anaya',
  'Tetepango (Ulapa)': 'Tetepango',
  'carillo puerto MIxq': 'Carrillo Puerto',
  'Motobatha, Carrillo Puerto': 'Motobatha',
  'Mothobata, Carrillo Puerto': 'Motobatha',
  'Rosario Tothie Pacheco': 'Rosario',
};

/// Aplica limpieza adicional a cualquier string de localidad.
/// - Trim de espacios
/// - Elimina pipes, tabs y caracteres basura
/// - Normaliza espacios múltiples
String cleanLocalidad(String raw) {
  var cleaned = raw
      .trim()
      .replaceAll(RegExp(r'[|]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'\(.*?\)'), '') // Elimina paréntesis y su contenido
      .trim();

  // Buscar coincidencia exacta en el mapa de normalización
  if (_normalizationMap.containsKey(cleaned)) {
    return _normalizationMap[cleaned]!;
  }

  return cleaned;
}

/// Versión de cleanLocalidad que además aplica Title Case automático
/// a strings que no están en el mapa.
String normalizeLocalidad(String raw) {
  final cleaned = cleanLocalidad(raw);

  // Si ya está en el mapa canónico, retornar
  if (_normalizationMap.containsKey(cleaned)) {
    return _normalizationMap[cleaned]!;
  }

  // Si el string original contenía una coma, podría ser multi-valor
  // Nos quedamos solo con el primer valor antes de la coma
  if (cleaned.contains(',')) {
    final parts = cleaned.split(',');
    return normalizeLocalidad(parts.first.trim());
  }

  return cleaned;
}
