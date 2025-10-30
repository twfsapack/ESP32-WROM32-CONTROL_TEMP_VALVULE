# ESP32_Temp_Valve_Controller

**Sistema de control de temperatura y 7 electroválvulas (AC) con ESP32-WROOM-32 + OLED + App Flutter (Bluetooth)**

**Descripción corta:** Sistema de control de temperatura y válvulas AC con ESP32, OLED 0.96", sensor DS18B20, SSR, 7 salidas para optoacopladores+triac para electroválvulas, y aplicación móvil Flutter por Bluetooth para control y monitorización en tiempo real.

## Contenido del repositorio

- `firmware/ESP32_Temp_Control_Valves_BT.ino` - Firmware ESP32 completo (Bluetooth, DS18B20, OLED, 7 válvulas, menús y LEDs).  
- `flutter/` - Código fuente principal de la app Flutter (archivo `main.dart` y `pubspec.yaml`).  
- `diagrams/` - Diagramas de conexión y mockups de pantallas.  
- `pcb/` - Netlist, BOM y guía de colocación para PCB; instrucciones para Proteus (ISIS + ARES).  
- `proteus_library/` - Paquete Proteus con símbolo ESP32-WROOM-32 (placeholder .LIB/.IDX).  
- `assets/` - Iconos y mockups generados para la app.  
- `LICENSE` - Licencia MIT.

## Instalación rápida

### Firmware (ESP32)
1. Abre `firmware/ESP32_Temp_Control_Valves_BT.ino` en Arduino IDE.  
2. Selecciona la placa **ESP32 Dev Module** y el puerto correspondiente.  
3. Instala las librerías necesarias: `Adafruit_SSD1306`, `Adafruit_GFX`, `OneWire`, `DallasTemperature`, `BluetoothSerial`.  
4. Compila y carga al módulo ESP32.

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

