#!/bin/bash
# Script de Setup y Deploy para ESP32 - TWF Control v2.0.0

echo "=========================================="
echo "  TWF ESP32 Control - Setup & Deploy"
echo "  Versión 2.0.0"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${NC}ℹ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "ESP32_Temp_Control_Valves_BT.ino" ]; then
    print_error "Archivo .ino no encontrado"
    echo "Por favor ejecuta este script desde el directorio del proyecto"
    exit 1
fi

print_success "Directorio del proyecto encontrado"
echo ""

# Verificar si arduino-cli está instalado
print_info "Verificando arduino-cli..."
if ! command -v arduino-cli &> /dev/null; then
    print_warning "arduino-cli no está instalado"
    echo ""
    echo "Opciones:"
    echo "1. Instalar arduino-cli automáticamente"
    echo "2. Usar Arduino IDE manualmente"
    echo "3. Cancelar"
    read -p "Selecciona una opción (1-3): " option

    case $option in
        1)
            print_info "Instalando arduino-cli..."
            curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
            export PATH=$PATH:$HOME/bin
            print_success "arduino-cli instalado"
            ;;
        2)
            print_info "Abre Arduino IDE y sigue estos pasos:"
            echo ""
            echo "1. File → Open → ESP32_Temp_Control_Valves_BT.ino"
            echo "2. Tools → Board → ESP32 Dev Module"
            echo "3. Tools → Port → (Selecciona tu ESP32)"
            echo "4. Click en Upload (→)"
            echo ""
            exit 0
            ;;
        3)
            print_info "Cancelado por el usuario"
            exit 0
            ;;
        *)
            print_error "Opción inválida"
            exit 1
            ;;
    esac
fi

print_success "arduino-cli disponible"
echo ""

# Configurar arduino-cli
print_info "Configurando arduino-cli..."
arduino-cli config init --overwrite 2>/dev/null
arduino-cli config add board_manager.additional_urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
print_success "Configuración completada"
echo ""

# Actualizar índice de boards
print_info "Actualizando índice de placas..."
arduino-cli core update-index
print_success "Índice actualizado"
echo ""

# Instalar soporte para ESP32
print_info "Verificando soporte para ESP32..."
if arduino-cli core list | grep -q "esp32:esp32"; then
    print_success "ESP32 ya está instalado"
else
    print_info "Instalando soporte para ESP32 (esto puede tardar varios minutos)..."
    arduino-cli core install esp32:esp32@2.0.11
    print_success "ESP32 instalado"
fi
echo ""

# Instalar librerías necesarias
print_info "Instalando librerías requeridas..."

libraries=(
    "Adafruit GFX Library@1.11.3"
    "Adafruit SSD1306@2.5.7"
    "OneWire@2.3.7"
    "DallasTemperature@3.9.0"
)

for lib in "${libraries[@]}"; do
    lib_name=$(echo $lib | cut -d'@' -f1)
    print_info "Instalando $lib_name..."
    arduino-cli lib install "$lib" 2>/dev/null || print_warning "$lib_name ya instalado o no encontrado"
done

print_success "Librerías instaladas"
echo ""

# Detectar puerto del ESP32
print_info "Detectando puerto del ESP32..."
PORTS=$(arduino-cli board list | grep -i "esp32\|serial\|usb" | awk '{print $1}')

if [ -z "$PORTS" ]; then
    print_error "No se detectó ningún ESP32 conectado"
    echo ""
    echo "Por favor:"
    echo "1. Conecta el ESP32 via USB"
    echo "2. Verifica que el driver esté instalado (CP210x o CH340)"
    echo "3. Ejecuta este script nuevamente"
    exit 1
fi

# Si hay múltiples puertos, preguntar cuál usar
PORT_COUNT=$(echo "$PORTS" | wc -l)
if [ "$PORT_COUNT" -gt 1 ]; then
    echo "Se detectaron múltiples dispositivos:"
    echo "$PORTS" | nl
    read -p "Selecciona el número del puerto: " port_num
    PORT=$(echo "$PORTS" | sed -n "${port_num}p")
else
    PORT=$PORTS
fi

print_success "ESP32 detectado en: $PORT"
echo ""

# Compilar el firmware
print_info "Compilando firmware..."
echo "Esto puede tardar 1-2 minutos..."

if arduino-cli compile --fqbn esp32:esp32:esp32 ESP32_Temp_Control_Valves_BT.ino 2>&1 | tee /tmp/compile_output.log | grep -q "error:"; then
    print_error "Error al compilar el firmware"
    echo ""
    echo "Ver errores completos en: /tmp/compile_output.log"
    cat /tmp/compile_output.log | grep "error:"
    exit 1
fi

print_success "Compilación exitosa"
echo ""

# Cargar al ESP32
print_info "Cargando firmware al ESP32..."
echo "Por favor, NO desconectes el ESP32 durante este proceso"
echo ""

if arduino-cli upload -p $PORT --fqbn esp32:esp32:esp32 ESP32_Temp_Control_Valves_BT.ino 2>&1 | tee /tmp/upload_output.log; then
    print_success "Firmware cargado exitosamente"
else
    print_error "Error al cargar el firmware"
    echo ""
    print_info "Soluciones:"
    echo "1. Mantén presionado el botón BOOT del ESP32"
    echo "2. Mientras lo mantienes, presiona el botón RESET"
    echo "3. Suelta RESET pero mantén BOOT"
    echo "4. Ejecuta: arduino-cli upload -p $PORT --fqbn esp32:esp32:esp32 ESP32_Temp_Control_Valves_BT.ino"
    exit 1
fi

echo ""
echo "=========================================="
print_success "Deployment del firmware completado"
echo "=========================================="
echo ""

# Abrir Serial Monitor si está disponible
read -p "¿Deseas abrir el Serial Monitor para verificar? (s/n): " open_monitor

if [ "$open_monitor" = "s" ] || [ "$open_monitor" = "S" ]; then
    print_info "Abriendo Serial Monitor (Ctrl+C para salir)..."
    echo "Presiona el botón RESET en el ESP32 para ver el inicio"
    echo ""
    arduino-cli monitor -p $PORT -c baudrate=115200
fi

echo ""
print_success "Setup completado"
echo ""
print_info "Próximos pasos:"
echo "1. Verifica el Serial Monitor (115200 baud)"
echo "2. Deberías ver: 'TWF ESP32 Temp Control v2.0.0'"
echo "3. Conecta la app Flutter al Bluetooth 'ESP32_TempControl'"
echo ""
print_info "Para troubleshooting, consulta: DEPLOYMENT.md"
echo ""
