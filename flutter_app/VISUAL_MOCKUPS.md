# 📱 Mockups Visuales de la App TWF ESP32 Control v2.0.0

Este documento muestra mockups detallados de todas las pantallas de la aplicación.

---

## 1. 🎬 Splash Screen (Pantalla de Bienvenida)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│                                         │
│              ╔════════════╗             │
│              ║            ║             │
│              ║    TWF     ║             │  ← Logo animado
│              ║   LOGO     ║             │    (fade + scale)
│              ║            ║             │
│              ╚════════════╝             │
│                                         │
│                                         │
│           TWF ESP32 Control             │  ← Texto fade-in
│                v2.0.0                   │
│                                         │
│                                         │
│              ┌──────────┐               │
│              │ ████████ │               │  ← Progress bar
│              └──────────┘               │
│                                         │
│        Verificando permisos...          │  ← Status dinámico
│                                         │
│                                         │
│                                         │
└─────────────────────────────────────────┘

Secuencia:
1. Logo aparece con fade + scale (1.5s)
2. Solicita permisos Bluetooth + Location
3. Verifica Bluetooth disponible
4. Navega automáticamente al menú
```

---

## 2. 🏠 Menú Principal

```
┌─────────────────────────────────────────┐
│ ◀ TWF ESP32 Control       🔵 [Conectado]│  ← AppBar con BT indicator
├─────────────────────────────────────────┤
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║  🔵 Conectado a ESP32_TempControl  ║│  ← Card verde si conectado
│  ║                                     ║│    Card rojo si desconectado
│  ║  [🔗 Desconectar]                  ║│
│  ╚═════════════════════════════════════╝│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  🌡️  Control de Temperatura        ││  ← Opción 1 (HABILITADA)
│  │                                     ││
│  │  Monitoreo y ajuste de temperatura ││
│  │                                  ▶  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  💧  Control de Electroválvulas    ││  ← Opción 2 (HABILITADA)
│  │                                     ││
│  │  Configuración de 7 válvulas AC    ││
│  │                                  ▶  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║  ℹ️  TWF ESP32 Control v2.0.0       ║│  ← Info card
│  ║  Compatible con firmware v2.0.0     ║│
│  ╚═════════════════════════════════════╝│
│                                         │
│         [📱 Conectar Dispositivo]       │  ← Botón si no conectado
│                                         │
└─────────────────────────────────────────┘

Estados BT:
- 🔴 Rojo + Desconectado → Opciones DESHABILITADAS (gris)
- 🟢 Verde + Conectado → Opciones HABILITADAS (color)
```

---

## 3. 🔗 Pantalla de Conexión Bluetooth

```
┌─────────────────────────────────────────┐
│ ◀ Conectar Dispositivo            [🔄] │
├─────────────────────────────────────────┤
│                                         │
│  💡 Busca un dispositivo llamado:       │
│     "ESP32_TempControl"                 │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                         │
│  📱 Dispositivos Emparejados            │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🔵 ESP32_TempControl                ││  ← Dispositivo
│  │ Dirección: 1A:2B:3C:4D:5E:6F        ││
│  │                        [Conectar]   ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ⚫ Mi Laptop                        ││
│  │ Dirección: AA:BB:CC:DD:EE:FF        ││
│  │                        [Conectar]   ││
│  └─────────────────────────────────────┘│
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                         │
│         [🔍 Escanear Dispositivos]      │  ← Botón scan
│                                         │
│                                         │
└─────────────────────────────────────────┘

Durante conexión:
┌─────────────────────────────────────────┐
│         Conectando...                   │
│         ┌──────────┐                    │
│         │ ████████ │  ← Spinner         │
│         └──────────┘                    │
└─────────────────────────────────────────┘
```

---

## 4. 🌡️ Pantalla de Temperatura (Completa)

```
┌─────────────────────────────────────────┐
│ ◀ Control de Temperatura          [🔄] │  ← AppBar con refresh
├─────────────────────────────────────────┤
│ 🔴 ⚠️  Temperatura Alta                 │  ← Alerta (si aplica)
│ La temperatura actual supera el         │    Solo aparece cuando
│ objetivo en más de 5°C                  │    diff > 5°C
└─────────────────────────────────────────┘
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║                                     ║│
│  ║    🌡️         Temperatura Actual    ║│  ← Card destacada
│  ║                                     ║│
│  ║              32.5°C                 ║│  ← Color dinámico:
│  ║                                     ║│    <20°C: Azul
│  ║                                     ║│    20-25°C: Verde
│  ╚═════════════════════════════════════╝│    25-30°C: Naranja
│                                         │    >30°C: Rojo
│  ╔═════════════════════════════════════╗│
│  ║  Estado del SSR:  🟢 ENCENDIDO     ║│  ← Animación pulsante
│  ╚═════════════════════════════════════╝│    cuando ON
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ 📊 Historial de Temperatura         ║│
│  ║                                     ║│
│  ║  35°C ┤                            ║│
│  ║  30°C ┤     ╱╲    ╱╲              ║│  ← Gráfico fl_chart
│  ║  25°C ┤────╱──╲──╱──╲─────────    ║│    Línea cyan: Actual
│  ║  20°C ┤   ╱    ╲╱    ╲            ║│    Línea naranja: Objetivo
│  ║  15°C ┤                            ║│
│  ║       └──────────────────────────  ║│
│  ║       0s    20s    40s    60s      ║│
│  ║                                     ║│
│  ║  ━━ Temperatura Actual              ║│  ← Leyenda
│  ║  ┄┄ Temperatura Objetivo            ║│
│  ╚═════════════════════════════════════╝│
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ 🎛️ Ajustar Temperatura Objetivo     ║│
│  ║                                     ║│
│  ║      Temperatura Objetivo  📝       ║│  ← Icono si hay cambios
│  ║            28.5°C                   ║│
│  ║                                     ║│
│  ║  ⊖  ━━━━━━━━●━━━━━━━━━━━━━  ⊕     ║│  ← Slider 0-100°C
│  ║  0°C                        100°C   ║│
│  ║                                     ║│
│  ║  ┌─────────────────────────────────┐║│
│  ║  │  📤 Enviar al ESP32             │║│  ← Verde si hay cambios
│  ║  └─────────────────────────────────┘║│    Gris si no hay cambios
│  ║                                     ║│
│  ║  Tienes cambios sin guardar         ║│  ← Solo si hay cambios
│  ╚═════════════════════════════════════╝│
│                                         │
└─────────────────────────────────────────┘

Interacciones:
- Slider: Arrastra para ajustar (0.5°C por paso)
- Botones ⊖/⊕: Click para -0.5 / +0.5
- Botón Enviar: Solo habilitado si hay cambios
- Gráfico: Actualización automática cada 2s (50 puntos)
- Refresh: Fuerza actualización inmediata
```

---

## 5. 💧 Pantalla de Válvulas - Vista General (Colapsada)

```
┌─────────────────────────────────────────┐
│ ◀ Control de Electroválvulas      [🔄] │
├─────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐
│ │  💧  7 Electroválvulas AC            │  ← Header fijo
│ │      Control independiente           │    Fondo cyan claro
│ │                                      │
│ │  [🟢 Iniciar Todas] [🔴 Detener]    │  ← Control masivo
│ └───────────────────────────────────────┘
├─────────────────────────────────────────┤
│  ╔═════════════════════════════════════╗│
│  ║ ① Válvula 1              [INACTIVA]║│  ← Card 1 (colapsada)
│  ║                                  ▼  ║│    Borde gris
│  ║ ⏱ Retardo: 0s     ⏲ Duración: 5s   ║│    Fondo blanco
│  ╚═════════════════════════════════════╝│
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ ② Válvula 2  💧   [ACTIVA]  🟢     ║│  ← Card 2 (colapsada)
│  ║                                  ▼  ║│    Borde verde
│  ║ ⏱ Retardo: 5s     ⏲ Duración: 10s  ║│    Fondo verde claro
│  ╚═════════════════════════════════════╝│    PULSANDO (animación)
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ ③ Válvula 3           [INACTIVA]   ║│  ← Card 3 (colapsada)
│  ║                                  ▼  ║│
│  ║ ⏱ Retardo: 2s     ⏲ Duración: 15s  ║│
│  ╚═════════════════════════════════════╝│
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ ④ Válvula 4        [DESHABILITADA] ║│  ← Card 4 (deshabilitada)
│  ║                                  ▼  ║│    Borde gris oscuro
│  ║ ⏱ Retardo: 0s     ⏲ Duración: 20s  ║│    Fondo gris claro
│  ╚═════════════════════════════════════╝│
│                                         │
│  ... (Válvulas 5, 6, 7 similares) ...  │
│                                         │
└─────────────────────────────────────────┘

Nota: Tap en cualquier card para expandir y ver controles
```

---

## 6. 💧 Pantalla de Válvulas - Card Expandida (Válvula 2)

```
┌─────────────────────────────────────────┐
│ ◀ Control de Electroválvulas      [🔄] │
├─────────────────────────────────────────┤
│ ... (Header con botones masivos) ...   │
├─────────────────────────────────────────┤
│  ╔═════════════════════════════════════╗│
│  ║ ② Válvula 2  💧   [ACTIVA]  🟢     ║│  ← Header (tap para colapsar)
│  ║                                  ▲  ║│    Círculo verde con "2"
│  ║ ⏱ Retardo: 5s     ⏲ Duración: 10s  ║│    Animación pulsante activa
│  ║─────────────────────────────────────║│
│  ║                                     ║│  ← Contenido expandido
│  ║ ┌─────────────────────────────────┐ ║│
│  ║ │ ✅ Válvula Habilitada      [⚪️] │ ║│  ← Switch ON
│  ║ │ Puede ser activada manual o     │ ║│    Fondo verde claro
│  ║ │ automáticamente                 │ ║│
│  ║ └─────────────────────────────────┘ ║│
│  ║                                     ║│
│  ║ ⏱ Retardo de Inicio                ║│
│  ║ Tiempo de espera antes de activar  ║│
│  ║                                     ║│
│  ║  ⊖  ━━●━━━━━━━━━  ⊕   5 segundos  ║│  ← Slider naranja
│  ║  0s                           60s   ║│    Botones +/- naranja
│  ║                                     ║│
│  ║ ⏲ Duración de Activación            ║│
│  ║ Tiempo que permanecerá activa       ║│
│  ║                                     ║│
│  ║  ⊖  ━━━━●━━━━━━━  ⊕   10 segundos ║│  ← Slider azul
│  ║  1s                          5min   ║│    Botones +/- azul
│  ║                                     ║│
│  ║ ┌──────────────────┐ ┌──────────── ║│
│  ║ │ ▶ Iniciar        │ │ ⏹ Detener  │║│  ← Botones grandes
│  ║ └──────────────────┘ └──────────── ║│    Verde / Rojo
│  ║                                     ║│
│  ║ [💾 Guardar Solo Esta Válvula]      ║│  ← Botón guardar
│  ╚═════════════════════════════════════╝│
│                                         │
│  ... (Otras válvulas colapsadas) ...   │
│                                         │
└─────────────────────────────────────────┘
```

---

## 7. 💧 Pantalla de Válvulas - Con Cambios Pendientes

```
┌─────────────────────────────────────────┐
│ ◀ Control de Electroválvulas      [🔄] │
├─────────────────────────────────────────┤
│ ... (Header + Cards) ...                │
│                                         │
│  ╔═════════════════════════════════════╗│
│  ║ ① Válvula 1  📝      [INACTIVA]    ║│  ← Icono edit si cambió
│  ║                                  ▼  ║│
│  ║ ⏱ Retardo: 3s ⚠️  ⏲ Duración: 8s ⚠️ ║│    (modificado)
│  ╚═════════════════════════════════════╝│
│                                         │
│  ... (Más válvulas) ...                 │
│                                         │
├─────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐
│ │ ⚠️ Tienes cambios sin guardar        │  ← Sticky footer naranja
│ │                                       │    Solo aparece si hay
│ │ ┌─────────────────────────────────┐  │    cambios pendientes
│ │ │ 💾 Guardar Todos los Cambios    │  │
│ │ └─────────────────────────────────┘  │    Botón grande cyan
│ └───────────────────────────────────────┘
└─────────────────────────────────────────┘
```

---

## 8. 🔔 Diálogo de Confirmación - Iniciar Todas

```
┌─────────────────────────────────────────┐
│                                         │
│    ╔═════════════════════════════════╗  │
│    ║ Iniciar Todas las Válvulas      ║  │
│    ║                                 ║  │
│    ║ ¿Estás seguro de que deseas     ║  │
│    ║ iniciar todas las válvulas      ║  │
│    ║ habilitadas?                    ║  │
│    ║                                 ║  │
│    ║  [Cancelar]        [Iniciar]   ║  │
│    ╚═════════════════════════════════╝  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 9. 🎨 Paleta de Colores

```
┌─────────────────────────────────────────┐
│ COLORES TWF ESP32 CONTROL v2.0.0        │
├─────────────────────────────────────────┤
│                                         │
│ Primary (Cyan TWF):   #00BCD4  ████    │
│ Primary Container:    #B2EBF2  ████    │
│                                         │
│ Success (Verde):      #4CAF50  ████    │
│ Success Light:        #C8E6C9  ████    │
│                                         │
│ Error (Rojo):         #F44336  ████    │
│ Error Light:          #FFCDD2  ████    │
│                                         │
│ Warning (Naranja):    #FF9800  ████    │
│ Warning Light:        #FFE0B2  ████    │
│                                         │
│ Info (Azul):          #2196F3  ████    │
│ Info Light:           #BBDEFB  ████    │
│                                         │
│ Grey Dark:            #616161  ████    │
│ Grey Light:           #E0E0E0  ████    │
│ Grey Ultra Light:     #F5F5F5  ████    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 10. 📐 Especificaciones de Diseño

### Tipografía
```
┌─────────────────────────────────────────┐
│ Display Large:   56pt  Bold (Temp)      │
│ Display Medium:  48pt  Bold (Target)    │
│ Headline Large:  32pt  Bold             │
│ Title Large:     22pt  Regular          │
│ Title Medium:    16pt  Medium           │
│ Body Large:      16pt  Regular          │
│ Body Medium:     14pt  Regular          │
│ Body Small:      12pt  Regular          │
│ Label:           11pt  Regular          │
└─────────────────────────────────────────┘
```

### Espaciado
```
┌─────────────────────────────────────────┐
│ Screen Padding:       16px              │
│ Card Padding:         16-24px           │
│ Card Margin:          12px              │
│ Section Spacing:      20px              │
│ Element Spacing:      8-12px            │
│ Border Radius (Card): 12px              │
│ Border Radius (Btn):  8px               │
│ Border Width:         1-2px             │
│ Elevation (Active):   4dp               │
│ Elevation (Normal):   2dp               │
└─────────────────────────────────────────┘
```

### Iconos
```
┌─────────────────────────────────────────┐
│ Large Icons:     48px  (Headers)        │
│ Medium Icons:    32px  (Cards)          │
│ Small Icons:     20px  (Inline)         │
│ Tiny Icons:      16px  (Buttons)        │
└─────────────────────────────────────────┘
```

---

## 11. 🎭 Estados de Interacción

### Válvula Card
```
┌─────────────────────────────────────────┐
│ Estado           │ Color  │ Animación   │
├──────────────────┼────────┼─────────────┤
│ Activa           │ Verde  │ Pulsante    │
│ Inactiva         │ Blanco │ Ninguna     │
│ Deshabilitada    │ Gris   │ Ninguna     │
│ Modificada       │ +Icono │ Ninguna     │
└─────────────────────────────────────────┘
```

### Botones
```
┌─────────────────────────────────────────┐
│ Estado     │ Estilo                     │
├────────────┼────────────────────────────┤
│ Habilitado │ Color sólido + sombra      │
│ Presionado │ Color más oscuro + elevación│
│ Disabled   │ Gris + sin sombra          │
│ Loading    │ Spinner + deshabilitado    │
└─────────────────────────────────────────┘
```

### Slider
```
┌─────────────────────────────────────────┐
│ Estado     │ Comportamiento             │
├────────────┼────────────────────────────┤
│ Normal     │ Track gris + thumb color   │
│ Arrastrando│ Thumb más grande + label   │
│ Disabled   │ Gris completo + opaco      │
└─────────────────────────────────────────┘
```

---

## 12. 🎬 Animaciones

### SSR Indicator (Temperatura)
```
Duración: 800ms
Curva: easeInOut
Efecto: Scale 0.8 → 1.0 → 0.8 (repeat)
Trigger: relayOn == true
```

### Válvula Card (Válvulas)
```
Duración: 1000ms
Curva: easeInOut
Efecto: Scale 0.7 → 1.0 → 0.7 (repeat)
Trigger: valveState == true
```

### Logo Splash
```
Duración: 1500ms
Curva: easeOut
Efecto: Fade 0 → 1 + Scale 0.5 → 1.0
Trigger: initState
```

### Card Expansion
```
Duración: 300ms
Curva: fastOutSlowIn
Efecto: Height expand/collapse
Trigger: Tap en header
```

---

## 13. 📱 Flujo de Navegación

```
Splash Screen (3s)
    ↓
    ├── Permisos denegados → Mensaje error → Reintentar
    │
    ├── Bluetooth no disponible → Mensaje error → Configuración
    │
    └── Todo OK
        ↓
    Menu Principal
        ↓
        ├── No conectado → [Botón Conectar] → Pantalla Conexión
        │                                          ↓
        │                                      Seleccionar ESP32
        │                                          ↓
        │                                      Conectando...
        │                                          ↓
        │                                      ← Volver a Menú (conectado)
        │
        └── Conectado
            ↓
            ├── [Temperatura] → Pantalla Temperatura
            │                       ↓
            │                   [Ajustar temp] → Slider
            │                   [Enviar] → Comando BT
            │                   [← Atrás] → Menú
            │
            └── [Válvulas] → Pantalla Válvulas
                                ↓
                            [Tap Card] → Expandir
                                ↓
                            [Edit params] → Local change
                            [Guardar] → Comando BT
                            [Iniciar/Detener] → Comando BT
                            [Iniciar Todas] → Diálogo → Confirmar
                            [← Atrás] → Menú
```

---

## 14. 💡 Instrucciones de Visualización

### Para ver las pantallas en tu navegador:

```bash
cd /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/flutter_app
./run_preview.sh
```

O manualmente:
```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

### Para ver en emulador Android:

```bash
cd flutter_app
flutter pub get
flutter emulators --launch <emulator_name>
flutter run
```

### Para ver en dispositivo físico:

1. Conecta tu teléfono Android via USB
2. Activa "Depuración USB" en Opciones de Desarrollador
3. Ejecuta:
```bash
cd flutter_app
flutter devices  # Verifica que aparezca tu dispositivo
flutter run
```

---

## 15. 🎯 Verificación Visual - Checklist

Al ejecutar la app, verifica:

### Splash Screen
- [ ] Logo TWF aparece con animación suave
- [ ] Texto "TWF ESP32 Control v2.0.0" visible
- [ ] Progress bar animado
- [ ] Texto de estado actualizable
- [ ] Transición automática a Menú (3-5s)

### Menú Principal
- [ ] AppBar muestra icono BT (verde=conectado, rojo=desconectado)
- [ ] Card de estado con color correcto
- [ ] Opciones deshabilitadas si no hay conexión
- [ ] Iconos grandes y visibles (🌡️ 💧)
- [ ] Botón "Conectar" visible si no conectado

### Pantalla Temperatura
- [ ] Temperatura actual en tamaño grande con color dinámico
- [ ] SSR indicator pulsa cuando está encendido
- [ ] Gráfico muestra 2 líneas (actual + objetivo)
- [ ] Slider funciona suavemente (0-100°C)
- [ ] Botón "Enviar" se habilita/deshabilita correctamente
- [ ] Alertas aparecen cuando diff > 5°C

### Pantalla Válvulas
- [ ] 7 cards visibles, cada una con número de círculo
- [ ] Cards colapsadas muestran info rápida
- [ ] Tap expande/colapsa correctamente
- [ ] Sliders funcionan (retardo 0-60s, duración 1-300s)
- [ ] Switch de habilitación funciona
- [ ] Válvulas activas pulsan
- [ ] Sticky footer aparece al editar
- [ ] Botones "Iniciar Todas" muestran diálogo

---

## 📸 Cómo Tomar Screenshots

Una vez que tengas la app ejecutándose:

### En navegador (Web):
1. Presiona F12 (DevTools)
2. Click en icono de dispositivo móvil
3. Selecciona dimensiones (360x640 o 375x667)
4. Click derecho → "Capturar captura de pantalla"

### En emulador Android:
- Presiona Ctrl + S (Linux/Windows)
- Presiona Cmd + S (macOS)
- O usa el botón de cámara en la barra lateral

### En dispositivo real:
- Android: Botón Power + Volumen Abajo
- Screenshots se guardan en: /sdcard/Pictures/Screenshots/

---

¿Necesitas ayuda para ejecutar la app o algún ajuste en el diseño visual?
