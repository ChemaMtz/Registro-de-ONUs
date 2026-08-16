/// Filtro de NAPs por localidad (versión usada en edición inline de la lista).
/// NOTA: el orden de parámetros aquí es (String? localidad, List<String> naps, [Map prefijos])
/// para mantener compatibilidad con onu_list_screen.dart.

/// Normaliza el texto quitando acentos y pasándolo a minúsculas.
String _normalize(String input) {
  var str = input.toLowerCase().trim();
  const withDia = 'áéíóúüñ';
  const withoutDia = 'aeiouun';
  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }
  return str;
}

/// Convierte un NAP a su forma comparable (solo letras y dígitos).
/// Ej: "BB 201" → "BB201", "ACT-100" → "ACT100"
String _napComparable(String nap) {
  return nap.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
}

/// Mapa de las 32 localidades con sus prefijos técnicos (claves normalizadas).
final Map<String, String> _localidadAPrefijo = {
  'actopan': 'ACT',
  'tetepango': 'TT',
  'progreso': 'PRO',
  'carrillo puerto': 'CP',
  'rosario tothie pacheco': 'RTP',
  'huichapan': 'HUI',
  'atitalaquia': 'ATI',
  'arbol grande': 'AG',
  'cd sahagun': 'CS',
  'el arenal': 'ARE',
  'el rosario': 'ROS',
  'lagunilla': 'LAG',
  'san antonio': 'SANT',
  'san jose': 'SJ',
  'san salvador': 'SS',
  'santiago de anaya': 'SA',
  'tepatepec': 'TEP',
  'chicavasco': 'CHI',
  'palmillas': 'PAL',
  'caxuxi': 'CAX',
  'canada': 'CAN',
  'guzman mayer': 'GM',
  'huaxtho': 'HUA',
  'real toledo': 'RT',
  'demacu': 'DEM',
  'estancia': 'EST',
  'ojo de agua': 'OA',
  'polotitlan': 'POL',
  'santa maria': 'SM',
  'hermosillo': 'HER',
  'coelum': 'COE',
  'dextho': 'DEX',
  'motobatha': 'MO',
  'rosario': 'ROS',
};

/// Busca el prefijo correspondiente a la localidad.
String? _getPrefijoParaLocalidad(String localidadNormalizada, [Map<String, String>? dinamicos]) {
  if (localidadNormalizada.isEmpty) return null;

  // 0. Buscar en prefijos dinámicos (del administrador)
  if (dinamicos != null) {
    for (var entry in dinamicos.entries) {
      if (_normalize(entry.key) == localidadNormalizada) {
        return entry.value;
      }
    }
    for (var entry in dinamicos.entries) {
      final keyNorm = _normalize(entry.key);
      if (keyNorm.contains(localidadNormalizada) || localidadNormalizada.contains(keyNorm)) {
        return entry.value;
      }
    }
  }

  // 1. Buscar coincidencia exacta estática
  if (_localidadAPrefijo.containsKey(localidadNormalizada)) {
    return _localidadAPrefijo[localidadNormalizada];
  }

  // 2. Buscar coincidencia parcial
  for (var entry in _localidadAPrefijo.entries) {
    if (entry.key.contains(localidadNormalizada) || localidadNormalizada.contains(entry.key)) {
      return entry.value;
    }
  }

  return null;
}

/// Filtra NAPs por localidad con lógica EXCLUYENTE.
/// - Si no hay localidad → retorna lista vacía []
/// - Si no encuentra el prefijo → retorna lista vacía []
/// - Soporta NAPs en cualquier formato (BB 201, BB-201, BB201)
List<String> filtrarNapsPorLocalidad(
  String? localidadSeleccionada,
  List<String> todosLosNaps, [
  Map<String, String>? prefijosDinamicos,
]) {
  if (localidadSeleccionada == null || localidadSeleccionada.trim().isEmpty) {
    return [];
  }

  String localidadNorm = _normalize(localidadSeleccionada);

  String? prefijoRaw = _getPrefijoParaLocalidad(localidadNorm, prefijosDinamicos);

  if (prefijoRaw == null) {
    return [];
  }

  List<String> prefijosList = prefijoRaw
      .split(',')
      .map((p) => p.trim().toUpperCase())
      .where((p) => p.isNotEmpty)
      .toList();

  List<String> napsFiltrados = [];
  for (final nap in todosLosNaps) {
    final napCmp = _napComparable(nap);
    for (final p in prefijosList) {
      final pClean = p.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
      if (napCmp.startsWith(pClean)) {
        napsFiltrados.add(nap);
        break;
      }
    }
  }

  if (napsFiltrados.isEmpty) {
    return [];
  }

  return napsFiltrados;
}
