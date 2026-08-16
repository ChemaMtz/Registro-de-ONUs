#!/bin/bash
echo "Clonando e instalando Flutter..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Agregar Flutter al PATH temporalmente para la compilación en Vercel
export PATH="$PATH:`pwd`/flutter/bin"

echo "Habilitando soporte para Web..."
flutter config --enable-web

echo "Obteniendo dependencias..."
flutter pub get

echo "Construyendo la aplicación web..."
flutter build web --release