# ESP32 Sistema de Control de Temperatura y Electroválvulas

**Versión 2.0.0 - Sistema profesional de control dual independiente**

**Sistema de control de temperatura y 7 electroválvulas (AC) con ESP32-WROOM-32 + OLED + App Flutter (Bluetooth)**

**Descripción:** Sistema de control de temperatura y válvulas AC con ESP32, OLED 0.96", sensor DS18B20 real, SSR, 7 salidas para optoacopladores+triac para electroválvulas, entradas digitales para activación manual, y aplicación móvil Flutter por Bluetooth para control y monitorización en tiempo real.

## ✨ Características Principales

- ✅ Control de temperatura con sensor DS18B20 real (histéresis configurable)
- ✅ 7 electroválvulas AC controladas independientemente
- ✅ Configuración individual de duración y retardo por válvula
- ✅ Entradas digitales para activación manual (2 implementadas, expandible a 7)
- ✅ Menú interactivo OLED mejorado con información en tiempo real
- ✅ Comunicación bidireccional Bluetooth con app móvil
- ✅ Control independiente: temperatura y válvulas funcionan autónomamente
- ✅ LEDs indicadores para cada válvula y SSR
- ✅ Sistema de comandos completo desde app Flutter

## 🆕 Novedades Versión 2.0.0

### Correcciones Críticas:
- ✅ Conflicto de pines GPIO resuelto (válvulas 5, 6, 7 reasignadas)
- ✅ Sensor DS18B20 real implementado (sin simulación)
- ✅ Protocolo Bluetooth unificado ESP32 ↔ Flutter
- ✅ Recepción de comandos Bluetooth implementada

### Nuevas Funcionalidades:
- ✨ Entradas digitales para activación manual de válvulas
- ✨ Sistema de menú OLED completamente rediseñado
- ✨ Configuración de retardo (delay) por válvula
- ✨ Sistema de habilitación/deshabilitación de válvulas
- ✨ Comandos bidireccionales completos

Ver [CHANGELOG.md](CHANGELOG.md) para detalles completos de los cambios.

## 📁 Contenido del repositorio

### Código Fuente
- `ESP32_Temp_Control_Valves_BT.ino` - Firmware ESP32 completo (Bluetooth, DS18B20, OLED, 7 válvulas, menús y LEDs)
- `lib_main.dart` - Código fuente de la app Flutter
- `pubspec.yaml` - Dependencias Flutter

### Documentación
- `README.md` - Este archivo (descripción general)
- `CHANGELOG.md` - Registro detallado de cambios v2.0.0
- `BOM.md` - Lista completa de materiales con especificaciones técnicas
- `SHOPPING_LIST.md` - Lista de compra rápida imprimible

### Diagramas y Recursos
- `diagram_valves.pdf` - Diagrama de conexiones completo
- `screen_*.png` - Mockups de la aplicación móvil
- `ChatGPT Image...png` - Esquema visual del sistema
- `app_icon_tecnoworldfuture.png` - Icono de la empresa

### Legal
- `LICENSE` - Licencia MIT

## 🛒 Lista de Materiales

¿Listo para construir el sistema? Consulta:

- **[BOM.md](BOM.md)** - Lista de materiales completa con especificaciones técnicas, proveedores y costos estimados
- **[SHOPPING_LIST.md](SHOPPING_LIST.md)** - Lista de compra rápida imprimible para llevar al proveedor

**Costo total estimado: ~$184 USD** (componentes + estructura)

---

## 🚀 Instalación rápida

### Firmware (ESP32)
1. Abre `ESP32_Temp_Control_Valves_BT.ino` en Arduino IDE
2. Selecciona la placa **ESP32 Dev Module** y el puerto correspondiente
3. Instala las librerías necesarias desde el Administrador de Librerías:
   - `Adafruit_SSD1306` (pantalla OLED)
   - `Adafruit_GFX` (gráficos)
   - `OneWire` (comunicación 1-Wire)
   - `DallasTemperature` (sensor DS18B20)
   - `BluetoothSerial` (incluida en el core ESP32)
4. Conecta el sensor DS18B20 al GPIO 36 con resistor pull-up de 4.7kΩ
5. Compila y carga al módulo ESP32
6. Abre el Serial Monitor (115200 baud) para ver logs de depuración

### App Flutter
1. Crea un proyecto Flutter y reemplaza `lib/main.dart` con `flutter/flutter_main.dart`.  
2. Copia `pubspec.yaml` y ejecuta `flutter pub get`.  
3. Añade permisos Bluetooth en AndroidManifest (`BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_CONNECT` y `ACCESS_FINE_LOCATION` para discovery según Android version).  
4. Ejecuta en un dispositivo Android y conecta al ESP32 mediante Bluetooth.

### PCB / Proteus
- Usa `pcb/netlist.csv`, `pcb/BOM.csv` y `pcb/placement_guide.png` para crear el esquemático y PCB en Proteus.  
- Sigue `pcb/proteus_instructions.txt` para pasos detallados.

## Licencia
Este proyecto se publica bajo la licencia MIT. Revisa el archivo `LICENSE` para más detalles.

## Créditos
Generado por el equipo de TecnoWorldFuture. Icono de la empresa incluido.

