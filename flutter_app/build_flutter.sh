#!/bin/bash
# Script de Build y Deploy para Flutter App - TWF ESP32 Control v2.0.0

echo "=========================================="
echo "  TWF ESP32 Control - Flutter Build"
echo "  Versión 2.0.0"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo -e "${BLUE}ℹ $1${NC}"
}

# Verificar que estamos en el directorio flutter_app
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml no encontrado"
    echo "Por favor ejecuta este script desde el directorio flutter_app"
    exit 1
fi

print_success "Directorio del proyecto Flutter encontrado"
echo ""

# Verificar si Flutter está instalado
print_info "Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado"
    echo ""
    echo "Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    echo ""
    echo "Linux:"
    echo "  wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz"
    echo "  tar xf flutter_linux_3.16.0-stable.tar.xz"
    echo "  export PATH=\"\$PATH:\$HOME/flutter/bin\""
    exit 1
fi

print_success "Flutter instalado: $(flutter --version | head -n 1)"
echo ""

# Verificar estado de Flutter
print_info "Ejecutando Flutter doctor..."
flutter doctor -v | head -20
echo ""

# Preguntar modo de build
echo "Selecciona el modo de build:"
echo "1. APK Debug (rápido, para desarrollo)"
echo "2. APK Release (optimizado, para distribución)"
echo "3. App Bundle (para Google Play Store)"
echo "4. Instalar en dispositivo conectado"
echo "5. Ejecutar en modo debug"
read -p "Opción (1-5): " build_option

case $build_option in
    1)
        BUILD_MODE="debug"
        BUILD_TYPE="apk"
        ;;
    2)
        BUILD_MODE="release"
        BUILD_TYPE="apk"
        ;;
    3)
        BUILD_MODE="release"
        BUILD_TYPE="appbundle"
        ;;
    4)
        BUILD_MODE="install"
        BUILD_TYPE=""
        ;;
    5)
        BUILD_MODE="run"
        BUILD_TYPE=""
        ;;
    *)
        print_error "Opción inválida"
        exit 1
        ;;
esac

echo ""

# Limpiar builds anteriores
print_info "Limpiando builds anteriores..."
flutter clean
print_success "Limpieza completada"
echo ""

# Obtener dependencias
print_info "Obteniendo dependencias..."
if flutter pub get; then
    print_success "Dependencias instaladas"
else
    print_error "Error al instalar dependencias"
    exit 1
fi
echo ""

# Analizar código
print_info "Analizando código..."
if flutter analyze --no-fatal-infos --no-fatal-warnings; then
    print_success "Análisis completado sin errores críticos"
else
    print_warning "Se encontraron advertencias (no críticas)"
fi
echo ""

# Ejecutar según el modo seleccionado
case $BUILD_MODE in
    "run")
        print_info "Ejecutando app en modo debug..."
        echo ""
        print_warning "Asegúrate de tener un dispositivo conectado o emulador corriendo"
        echo ""
        flutter devices
        echo ""
        read -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
        flutter run
        exit 0
        ;;

    "install")
        print_info "Verificando dispositivos conectados..."
        DEVICES=$(flutter devices | grep -v "No devices" | grep "•" | wc -l)

        if [ "$DEVICES" -eq 0 ]; then
            print_error "No hay dispositivos conectados"
            echo ""
            echo "Opciones:"
            echo "1. Conecta un dispositivo Android via USB"
            echo "2. Inicia un emulador"
            echo "3. Habilita 'Depuración USB' en el dispositivo"
            exit 1
        fi

        print_success "Dispositivo(s) encontrado(s)"
        flutter devices
        echo ""

        print_info "Compilando e instalando APK..."
        if flutter install; then
            print_success "App instalada en el dispositivo"
        else
            print_error "Error al instalar"
            exit 1
        fi
        exit 0
        ;;

    "debug")
        print_info "Compilando APK Debug..."
        if flutter build apk --debug; then
            print_success "APK Debug compilado"
            APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        else
            print_error "Error al compilar"
            exit 1
        fi
        ;;

    "release")
        if [ "$BUILD_TYPE" = "apk" ]; then
            print_info "Compilando APK Release..."
            echo "Esto puede tardar 3-5 minutos..."
            echo ""

            if flutter build apk --release; then
                print_success "APK Release compilado"
                APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
            else
                print_error "Error al compilar"
                exit 1
            fi
        else
            print_info "Compilando App Bundle (AAB)..."
            echo "Esto puede tardar 3-5 minutos..."
            echo ""

            if flutter build appbundle --release; then
                print_success "App Bundle compilado"
                AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
            else
                print_error "Error al compilar"
                exit 1
            fi
        fi
        ;;
esac

echo ""
echo "=========================================="
print_success "Build completado exitosamente"
echo "=========================================="
echo ""

# Mostrar información del archivo generado
if [ ! -z "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    print_info "Archivo APK generado:"
    echo "  Ruta: $APK_PATH"
    echo "  Tamaño: $APK_SIZE"
    echo ""

    # Renombrar con versión
    NEW_APK="build/app/outputs/flutter-apk/TWF_ESP32_Control_v2.0.0_${BUILD_MODE}.apk"
    cp "$APK_PATH" "$NEW_APK"
    print_success "APK copiado a: $NEW_APK"
    echo ""

    # Preguntar si instalar
    read -p "¿Deseas instalar en un dispositivo conectado? (s/n): " install_now
    if [ "$install_now" = "s" ] || [ "$install_now" = "S" ]; then
        print_info "Verificando dispositivos..."
        flutter devices
        echo ""

        if command -v adb &> /dev/null; then
            print_info "Instalando APK via ADB..."
            if adb install -r "$APK_PATH"; then
                print_success "APK instalado exitosamente"
            else
                print_error "Error al instalar. Prueba: adb install -r $APK_PATH"
            fi
        else
            print_warning "ADB no encontrado"
            echo "Copia el APK al dispositivo manualmente:"
            echo "  $NEW_APK"
        fi
    fi
fi

if [ ! -z "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    print_info "Archivo App Bundle generado:"
    echo "  Ruta: $AAB_PATH"
    echo "  Tamaño: $AAB_SIZE"
    echo ""

    # Renombrar con versión
    NEW_AAB="build/app/outputs/bundle/release/TWF_ESP32_Control_v2.0.0.aab"
    cp "$AAB_PATH" "$NEW_AAB"
    print_success "AAB copiado a: $NEW_AAB"
    echo ""

    print_info "Este archivo se puede subir a Google Play Console"
    print_warning "No se puede instalar directamente en dispositivos"
fi

echo ""
print_info "Próximos pasos:"
if [ "$BUILD_MODE" = "release" ] && [ "$BUILD_TYPE" = "apk" ]; then
    echo "1. Transferir APK al dispositivo Android"
    echo "2. Instalar: Configuración → Seguridad → Permitir fuentes desconocidas"
    echo "3. Abrir archivo APK en el dispositivo"
    echo "4. Conceder permisos (Bluetooth, Ubicación)"
    echo "5. Conectar al ESP32 'ESP32_TempControl'"
elif [ "$BUILD_MODE" = "release" ] && [ "$BUILD_TYPE" = "appbundle" ]; then
    echo "1. Ir a Google Play Console"
    echo "2. Crear nueva versión"
    echo "3. Subir: $NEW_AAB"
    echo "4. Completar información de la versión"
    echo "5. Publicar"
fi
echo ""
print_info "Para troubleshooting, consulta: ../DEPLOYMENT.md"
echo ""
print_success "Build completado!"
echo ""
