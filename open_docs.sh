#!/bin/bash
# Script de acceso rápido a documentación ESP32 v2.0.0

PROJECT_DIR="/home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE"

echo "======================================"
echo "  ESP32 Control Temperatura y Válvulas"
echo "  v2.0.0 - Documentación Rápida"
echo "======================================"
echo ""

echo "Archivos disponibles:"
echo ""
echo "1) README.md - Descripción general"
echo "2) CHANGELOG.md - Cambios v2.0.0"
echo "3) BOM.md - Lista de materiales (600+ líneas)"
echo "4) SHOPPING_LIST.md - Lista de compra (350+ líneas)"
echo "5) WIRING_DIAGRAM.md - Diagrama conexiones (1500+ líneas)"
echo "6) ESP32_Temp_Control_Valves_BT.ino - Firmware"
echo "7) Abrir carpeta en explorador"
echo "8) Abrir carpeta en VS Code"
echo "9) Ver en GitHub"
echo "0) Salir"
echo ""

read -p "Selecciona una opción [0-9]: " choice

case $choice in
    1)
        cat "$PROJECT_DIR/README.md" | less
        ;;
    2)
        cat "$PROJECT_DIR/CHANGELOG.md" | less
        ;;
    3)
        cat "$PROJECT_DIR/BOM.md" | less
        ;;
    4)
        cat "$PROJECT_DIR/SHOPPING_LIST.md" | less
        ;;
    5)
        cat "$PROJECT_DIR/WIRING_DIAGRAM.md" | less
        ;;
    6)
        cat "$PROJECT_DIR/ESP32_Temp_Control_Valves_BT.ino" | less
        ;;
    7)
        xdg-open "$PROJECT_DIR" 2>/dev/null || nautilus "$PROJECT_DIR" 2>/dev/null || echo "Instalando explorador de archivos..."
        ;;
    8)
        code "$PROJECT_DIR" 2>/dev/null || echo "VS Code no instalado. Instalar con: sudo apt install code"
        ;;
    9)
        xdg-open "https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/tree/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk" 2>/dev/null || echo "Abre manualmente: https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE"
        ;;
    0)
        echo "¡Hasta luego!"
        exit 0
        ;;
    *)
        echo "Opción inválida"
        ;;
esac

echo ""
echo "Presiona Enter para continuar..."
read
