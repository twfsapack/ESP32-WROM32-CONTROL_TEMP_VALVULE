# TWF ESP32 Control App v2.0.0

**Aplicación móvil Flutter para control de sistema ESP32 de temperatura y electroválvulas**

Compatible con Firmware ESP32 v2.0.0

---

## ✨ Características

- ✅ **Splash Screen** con logo TWF animado
- ✅ **Solicitud automática de permisos** Bluetooth y ubicación
- ✅ **Menú principal intuitivo** con indicador de conexión
- ✅ **Indicador Bluetooth** que cambia a verde cuando se conecta
- ✅ **Opciones deshabilitadas** hasta establecer conexión
- ✅ **Control de Temperatura** (pantalla en desarrollo)
- ✅ **Control de 7 Electroválvulas** (pantalla en desarrollo)
- ✅ **Protocolo compatible** con firmware ESP32 v2.0.0
- ✅ **Tema claro/oscuro** automático

---

## 📱 Capturas de Pantalla

1. **Splash Screen**: Logo TWF con animación
2. **Menú Principal**: Indicador BT y opciones del menú
3. **Conexión**: Lista de dispositivos Bluetooth disponibles
4. **Temperatura**: Monitoreo en tiempo real (próximamente)
5. **Válvulas**: Control individual de 7 válvulas (próximamente)

---

## 🔧 Requisitos

### Software
- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior
- Android Studio o VS Code
- Git

### Hardware
- Dispositivo Android con Bluetooth
- Android 7.0 (API 23) o superior
- ESP32-WROOM-32 con firmware v2.0.0

---

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE.git
cd ESP32-WROM32-CONTROL_TEMP_VALVULE/flutter_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Copiar el logo TWF

Copiar el archivo `app_icon_tecnoworldfuture.png` a la carpeta assets:

```bash
mkdir -p assets/images/
cp ../app_icon_tecnoworldfuture.png assets/images/
```

### 4. Verificar configuración de Android

Asegurarse que el archivo `android/app/build.gradle` tenga:

```gradle
minSdkVersion 23
targetSdkVersion 34
```

### 5. Conectar dispositivo Android

```bash
# Verificar dispositivos conectados
flutter devices

# Debería mostrar tu dispositivo Android
```

### 6. Ejecutar la aplicación

```bash
# Modo debug
flutter run

# Modo release
flutter run --release
```

---

## 📂 Estructura del Proyecto

```
flutter_app/
├── lib/
│   ├── main.dart                      # Punto de entrada de la app
│   ├── screens/
│   │   ├── splash_screen.dart         # Pantalla de bienvenida
│   │   ├── menu_screen.dart           # Menú principal
│   │   ├── connection_screen.dart     # Pantalla de conexión BT
│   │   ├── temperature_screen.dart    # Control de temperatura
│   │   └── valves_screen.dart         # Control de válvulas
│   └── services/
│       └── bluetooth_service.dart     # Servicio de comunicación BT
│
├── android/
│   ├── app/
│   │   ├── build.gradle               # Configuración de compilación
│   │   └── src/main/
│   │       └── AndroidManifest.xml    # Permisos y configuración
│   └── ...
│
├── assets/
│   └── images/
│       └── app_icon_tecnoworldfuture.png  # Logo TWF
│
├── pubspec.yaml                       # Dependencias del proyecto
└── README.md                          # Este archivo
```

---

## 🔌 Protocolo de Comunicación

### Formato de Datos Recibidos (desde ESP32)

```
TEMP_ACT=24.5;TEMP_SET=25.0;RELE=ON;VALVE0=ON,0,5,1;VALVE1=OFF,2,10,1;...
```

**Campos:**
- `TEMP_ACT`: Temperatura actual en °C
- `TEMP_SET`: Temperatura objetivo en °C
- `RELE`: Estado del SSR (ON/OFF)
- `VALVEx`: Estado de válvula X (estado, delay, tiempo, habilitada)

### Comandos Enviados (hacia ESP32)

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `GET_STATUS` | Solicitar estado actual | `GET_STATUS` |
| `PING` | Verificar conexión | `PING` |
| `SET_TEMP=X` | Configurar temperatura | `SET_TEMP=25.5` |
| `START_VALVE=X` | Activar válvula X | `START_VALVE=0` |
| `STOP_VALVE=X` | Detener válvula X | `STOP_VALVE=0` |
| `SET_VALVE_X_DELAY=Y` | Config. retardo de válvula | `SET_VALVE_0_DELAY=5` |
| `SET_VALVE_X_TIME=Y` | Config. duración de válvula | `SET_VALVE_0_TIME=10` |
| `ENABLE_VALVE_X=Y` | Habilitar/deshabilitar | `ENABLE_VALVE_0=1` |
| `CONFIRM` | Confirmar cambios | `CONFIRM` |

---

## 📡 Servicio de Bluetooth

### BluetoothService

Singleton que gestiona toda la comunicación con el ESP32.

**Métodos principales:**

```dart
// Conexión
Future<bool> connect(BluetoothDevice device)
Future<void> disconnect()

// Comandos
void setTemperature(double temp)
void startValve(int index)
void stopValve(int index)
void setValveDelay(int index, int delay)
void setValveTime(int index, int time)
void enableValve(int index, bool enabled)
void getStatus()
void ping()

// Streams
Stream<bool> connectionStream        // Estado de conexión
Stream<ESP32Data> dataStream         // Datos del ESP32
Stream<String> logStream             // Logs de comunicación
```

**Uso:**

```dart
final bluetoothService = BluetoothService();

// Conectar
await bluetoothService.connect(device);

// Escuchar datos
bluetoothService.dataStream.listen((data) {
  print('Temperatura: ${data.currentTemp}°C');
  print('SSR: ${data.relayOn}');
});

// Enviar comando
bluetoothService.setTemperature(25.5);
```

---

## 🎨 Diseño de Pantallas

### 1. Splash Screen

**Características:**
- Logo TWF con animación fade + scale
- Solicitud automática de permisos
- Verificación de Bluetooth
- Transición automática al menú

**Animaciones:**
- Duración: 1.5 segundos
- Fade: 0% → 100% opacidad
- Scale: 0.5x → 1.0x tamaño

### 2. Menú Principal

**Características:**
- Card de estado de conexión (rojo/verde)
- Indicador Bluetooth en AppBar
- 2 opciones principales:
  - Control de Temperatura (termómetro naranja)
  - Control de Electroválvulas (gota azul)
- Opciones deshabilitadas si no hay conexión
- Card informativa con versiones
- Botón de conexión/desconexión

**Estados:**
- **Desconectado**: Fondo rojo, opciones bloqueadas
- **Conectado**: Fondo verde, opciones habilitadas

### 3. Pantalla de Conexión

**Características:**
- Lista de dispositivos emparejados
- Botón de escaneo de nuevos dispositivos
- Indicador de escaneo en progreso
- Instrucciones para buscar "ESP32_TempControl"
- Feedback visual durante conexión

### 4. Control de Temperatura (Placeholder)

**Características actuales:**
- Muestra temperatura actual
- Muestra temperatura objetivo
- Indica estado del SSR
- Botón de actualizar

**Próximamente:**
- Gráfico histórico de temperatura
- Controles para ajustar temperatura
- Indicadores visuales mejorados

### 5. Control de Válvulas (Placeholder)

**Características actuales:**
- Lista de 7 válvulas
- Estado actual (ON/OFF)
- Información de delay y duración
- Botones Start/Stop
- Indicador de habilitación

**Próximamente:**
- Edición de parámetros
- Historial de activaciones
- Programación de secuencias

---

## 🔐 Permisos de Android

La app solicita los siguientes permisos:

| Permiso | Uso | Requerido |
|---------|-----|-----------|
| `BLUETOOTH` | Conexión Bluetooth básica | Sí |
| `BLUETOOTH_ADMIN` | Gestión de Bluetooth | Sí |
| `BLUETOOTH_SCAN` | Escaneo de dispositivos (Android 12+) | Sí |
| `BLUETOOTH_CONNECT` | Conexión (Android 12+) | Sí |
| `ACCESS_FINE_LOCATION` | Escaneo BT requiere ubicación | Sí |
| `ACCESS_COARSE_LOCATION` | Escaneo BT (fallback) | Sí |

**Nota:** Los permisos se solicitan automáticamente en el Splash Screen.

---

## 🐛 Solución de Problemas

### App no compila

```bash
# Limpiar caché de Flutter
flutter clean

# Reinstalar dependencias
flutter pub get

# Verificar versión de Flutter
flutter doctor -v
```

### Bluetooth no funciona

1. Verificar permisos en Configuración de Android
2. Asegurarse que Bluetooth esté habilitado
3. Verificar que el ESP32 esté encendido
4. Intentar emparejar el dispositivo manualmente primero

### No aparece el logo TWF

```bash
# Verificar que existe el archivo
ls -l assets/images/app_icon_tecnoworldfuture.png

# Ejecutar flutter pub get
flutter pub get

# Limpiar y reconstruir
flutter clean && flutter pub get && flutter run
```

### Error de permisos en Android 12+

Asegurarse que `AndroidManifest.xml` tenga los permisos de Bluetooth para API 31+:

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

---

## 📱 Compilar APK

### Debug APK

```bash
flutter build apk --debug
```

El APK estará en: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### APK Divididos por ABI (más pequeños)

```bash
flutter build apk --split-per-abi
```

Genera 3 APKs en `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit)
- `app-x86_64-release.apk` (x86 64-bit)

---

## 🔄 Próximas Mejoras

### Versión 2.1.0

- [ ] Pantalla de Temperatura completa con gráfico
- [ ] Configuración de parámetros de válvulas
- [ ] Guardado de configuraciones en local
- [ ] Historial de eventos
- [ ] Notificaciones push

### Versión 2.2.0

- [ ] Modo offline con reconexión automática
- [ ] Exportación de datos
- [ ] Temas personalizados
- [ ] Múltiples perfiles de configuración
- [ ] Widget de acceso rápido

---

## 📝 Dependencias

```yaml
dependencies:
  flutter_bluetooth_serial: ^0.4.0  # Comunicación Bluetooth
  permission_handler: ^11.0.1       # Gestión de permisos
  cupertino_icons: ^1.0.2           # Iconos iOS
```

---

## 👨‍💻 Desarrollo

### Añadir nueva pantalla

1. Crear archivo en `lib/screens/nueva_pantalla.dart`
2. Importar `bluetooth_service.dart`
3. Agregar navegación desde `menu_screen.dart`

### Modificar protocolo Bluetooth

Editar `lib/services/bluetooth_service.dart`:
- Método `_processLine()` para parseo de datos
- Métodos de comandos para envío

### Cambiar tema

Editar `lib/main.dart`:
- Sección `ThemeData` para tema claro
- Sección `darkTheme` para tema oscuro

---

## 📄 Licencia

MIT License - Ver archivo `LICENSE` en la raíz del repositorio.

---

## 🙏 Créditos

**Desarrollado por:** TecnoWorldFuture (TWF)

**Versión:** 2.0.0

**Compatible con:** Firmware ESP32 v2.0.0

**Repositorio:** https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE

---

## 📞 Soporte

Para problemas o sugerencias, crear un issue en el repositorio de GitHub.

---

**¡Disfruta controlando tu sistema ESP32!** 🚀
