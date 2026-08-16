/// Mapa de localidades → prefijos NAP (Company).
/// Las claves están normalizadas (minúsculas, sin acentos).
const _prefijos = <String, String>{
  'actopan': 'ACT',
  'atitalaquia': 'ATI',
  'arbol grande': 'AG',
  'carrillo puerto': 'CP',
  'cd sahagun': 'CS',
  'el arenal': 'ARE',
  'el rosario': 'ROS',
  'huichapan': 'HUI',
  'lagunilla': 'LAG',
  'progreso': 'PRO',
  'san antonio': 'SANT',
  'san jose': 'SJ',
  'san salvador': 'SS',
  'santiago de anaya': 'SA',
  'tepatepec': 'TEP',
  'tetepango': 'TT',
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

/// Elimina acentos, pasa a minúsculas y normaliza espacios.
String _normalizarTexto(String texto) {
  const conAcentos = 'ÁÉÍÓÚáéíóúñÑ';
  const sinAcentos = 'AEIOUaeiounN';
  var salida = texto.trim();
  for (var i = 0; i < conAcentos.length; i++) {
    salida = salida.replaceAll(conAcentos[i], sinAcentos[i]);
  }
  return salida.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

/// Convierte un NAP a su forma "cruda" (solo letras y dígitos) para comparación.
/// Ej: "BB 201" → "BB201", "ACT-100" → "ACT100", "CH- 108" → "CH108"
String _napParaComparar(String nap) {
  return nap.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
}

/// Busca el prefijo para una localidad: primero dinámico (admin), luego estático.
String? _buscarPrefijo(String localidadNormalizada, [Map<String, String>? dinamicos]) {
  // 0. Coincidencia en prefijos dinámicos (del administrador)
  if (dinamicos != null) {
    // Normalizar claves del mapa dinámico para comparación
    for (final entry in dinamicos.entries) {
      final keyNorm = _normalizarTexto(entry.key);
      if (keyNorm == localidadNormalizada) return entry.value;
    }
    for (final entry in dinamicos.entries) {
      final keyNorm = _normalizarTexto(entry.key);
      if (localidadNormalizada.contains(keyNorm) || keyNorm.contains(localidadNormalizada)) {
        return entry.value;
      }
    }
  }

  // 1. Coincidencia exacta estática
  if (_prefijos.containsKey(localidadNormalizada)) {
    return _prefijos[localidadNormalizada];
  }

  // 2. Coincidencia por inicio (mínimo 4 caracteres para evitar falsos positivos)
  if (localidadNormalizada.length >= 4) {
    final inicio = localidadNormalizada.substring(0, 4);
    for (final entry in _prefijos.entries) {
      if (entry.key.startsWith(inicio)) {
        return entry.value;
      }
    }
  }

  // 3. Si la entrada contiene al inicio de alguna llave conocida
  if (localidadNormalizada.length >= 3) {
    final inicio = localidadNormalizada.substring(0, 3);
    for (final entry in _prefijos.entries) {
      if (entry.key.startsWith(inicio)) {
        return entry.value;
      }
    }
  }

  return null;
}

/// Filtra NAPs por localidad con lógica EXCLUYENTE.
/// - Si no hay localidad seleccionada → retorna lista vacía []
/// - Si no encuentra el prefijo → retorna lista vacía []
/// - NUNCA retorna la lista completa de NAPs
/// - Soporta NAPs en cualquier formato (BB 201, BB-201, BB201)
List<String> filtrarNapsPorLocalidad(
  List<String> todosLosNaps,
  String? localidadSeleccionada, [
  Map<String, String>? prefijosDinamicos,
]) {
  // Seguridad: sin localidad → vacío
  if (localidadSeleccionada == null || localidadSeleccionada.isEmpty) {
    return [];
  }

  final entrada = _normalizarTexto(localidadSeleccionada);

  // Seguridad: entrada muy corta → vacío
  if (entrada.length < 3) return [];

  final prefijoRaw = _buscarPrefijo(entrada, prefijosDinamicos);

  // Seguridad: sin prefijo identificado → vacío
  if (prefijoRaw == null) return [];

  // El prefijo puede contener múltiples valores separados por coma (ej: "CCA,CAA,CÑB")
  final prefijosList = prefijoRaw
      .split(',')
      .map((p) => _napParaComparar(p)) // normalizar prefijo también
      .where((p) => p.isNotEmpty)
      .toList();

  // Filtro excluyente: comparar NAPs normalizados (sin espacios/guiones/puntos)
  final filtrados = <String>[];
  for (final nap in todosLosNaps) {
    final napComparable = _napParaComparar(nap);
    for (final p in prefijosList) {
      if (napComparable.startsWith(p)) {
        filtrados.add(nap);
        break;
      }
    }
  }

  filtrados.sort();
  return filtrados;
}
