#!/bin/bash
# Script para ejecutar la app Flutter en modo web para preview visual

echo "=========================================="
echo "  TWF ESP32 Control - Preview Web"
echo "=========================================="
echo ""

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado en este sistema."
    echo ""
    echo "Para instalar Flutter:"
    echo "1. Visita: https://flutter.dev/docs/get-started/install/linux"
    echo "2. Descarga Flutter SDK"
    echo "3. Agrega Flutter al PATH"
    echo ""
    exit 1
fi

echo "✅ Flutter detectado: $(flutter --version | head -n 1)"
echo ""

# Navegar al directorio de la app
cd "$(dirname "$0")"

echo "📦 Instalando dependencias..."
flutter pub get

echo ""
echo "🌐 Ejecutando app en modo web..."
echo ""
echo "La app se abrirá en tu navegador por defecto."
echo "Puedes interactuar con las pantallas aunque no estés"
echo "conectado al ESP32 (mostrará datos de ejemplo)."
echo ""
echo "Presiona Ctrl+C para detener el servidor."
echo ""

# Ejecutar en modo web
flutter run -d web-server --web-port=8080

echo ""
echo "✅ Preview finalizado"
