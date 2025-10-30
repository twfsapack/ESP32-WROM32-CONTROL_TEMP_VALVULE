# Registro de Cambios - Sistema ESP32 Control de Temperatura y Válvulas

## Versión 2.0.0 - Correcciones y Mejoras Críticas

### 🔧 CORRECCIONES CRÍTICAS

#### 1. Conflicto de Pines GPIO Resuelto
**Problema:** GPIOs 27, 33 y 25 estaban asignados múltiples veces causando mal funcionamiento.

**Solución:**
- Válvula 5: GPIO 27 → GPIO 16
- Válvula 6: GPIO 33 → GPIO 17
- Válvula 7: GPIO 25 → GPIO 0

**Archivo:** `ESP32_Temp_Control_Valves_BT.ino:40`

Nueva asignación de pines:
```cpp
int valvePins[7] = {2, 15, 13, 12, 16, 17, 0};
```

---

#### 2. Implementación de Sensor DS18B20 Real
**Problema:** El código usaba valores de temperatura simulados.

**Solución:**
- Agregadas librerías `OneWire` y `DallasTemperature`
- Sensor configurado en GPIO 36 (SVP)
- Lectura real de temperatura cada 1 segundo
- Validación de lecturas con detección de errores
- Resolución de 12 bits (0.0625°C)

**Archivos modificados:**
- `ESP32_Temp_Control_Valves_BT.ino:14-15` (includes)
- `ESP32_Temp_Control_Valves_BT.ino:25-28` (configuración)
- `ESP32_Temp_Control_Valves_BT.ino:99-101` (inicialización)
- `ESP32_Temp_Control_Valves_BT.ino:319-345` (lectura)

---

#### 3. Protocolo Bluetooth Unificado
**Problema:** ESP32 y Flutter usaban formatos incompatibles de comunicación.

**Solución:**
- Formato unificado: `TEMP_ACT=24.5;TEMP_SET=25.0;RELE=ON;VALVE0=ON,0,5,1;...`
- Agregadas variables `valveDelay[]` y `valveEnabled[]`
- Envío de estado completo cada 1 segundo

**Formato de datos por válvula:** `VALVE0=<estado>,<delay>,<tiempo>,<habilitada>`
- estado: ON/OFF
- delay: segundos de retardo antes de activar
- tiempo: duración en segundos
- habilitada: 1=sí, 0=no

**Archivo:** `ESP32_Temp_Control_Valves_BT.ino:357-378`

---

#### 4. Recepción de Comandos Bluetooth Implementada
**Problema:** El ESP32 solo enviaba datos, no podía recibir comandos de la app.

**Solución:** Implementada función `receiveBluetoothCommands()` con soporte completo para:

| Comando | Descripción |
|---------|-------------|
| `GET_STATUS` | Solicitar estado inmediato |
| `PING` | Verificar conexión (responde PONG) |
| `SET_TEMP=25.5` | Configurar temperatura objetivo |
| `START_VALVE=0` | Activar válvula N |
| `STOP_VALVE=0` | Detener válvula N |
| `SET_VALVE_0_DELAY=10` | Configurar retardo de válvula N |
| `SET_VALVE_0_TIME=5` | Configurar duración de válvula N |
| `ENABLE_VALVE_0=1` | Habilitar/deshabilitar válvula N |
| `CONFIRM` | Confirmar cambios |

**Archivo:** `ESP32_Temp_Control_Valves_BT.ino:321-352`

Todas las respuestas incluyen:
- `OK` para éxito
- `ERROR: <mensaje>` para fallos con descripción

---

### ✨ NUEVAS FUNCIONALIDADES

#### 5. Entradas Digitales para Control Manual
**Descripción:** Implementación de activación manual de válvulas mediante pulsadores/selectores.

**Características:**
- 2 entradas implementadas (GPIO 39 y 37)
- Detección por flanco con debounce de 50ms
- Respeta configuración de delay y tiempo
- Solo activa si la válvula está habilitada
- Logs por Serial Monitor

**Estructura preparada para expansión:**
- Para 7 entradas completas se recomienda expansor I2C (PCF8574 o MCP23017)
- Código modular para agregar más entradas fácilmente

**Archivos:**
- `ESP32_Temp_Control_Valves_BT.ino:37-46` (configuración)
- `ESP32_Temp_Control_Valves_BT.ino:99-101` (inicialización)
- `ESP32_Temp_Control_Valves_BT.ino:266-304` (función readValveInputs)
- `ESP32_Temp_Control_Valves_BT.ino:135` (llamada en loop)

---

#### 6. Sistema de Menú OLED Mejorado

**Mejoras implementadas:**

**Menú Principal:**
- Muestra temperatura actual en tiempo real
- Indica estado del SSR (ON/OFF)
- Información resumida en la parte inferior

**Submenú Temperatura:**
- Temperatura actual y objetivo
- Estado del SSR en texto
- Instrucciones de uso

**Submenú Electroválvulas:**
- Navegación entre 7 válvulas
- Edición de duración y retardo con indicador `>`
- Muestra estado actual (ACTIVA/INACTIVA)
- Muestra si está habilitada

**Submenú Estado del Sistema:**
- Resumen de temperatura
- Estado SSR
- Contador de válvulas activas (X/7 ON)
- Estado de conexión Bluetooth

**Controles:**
- `UP/DOWN`: Navegar o ajustar valores
- `NEXT`: Entrar a submenú o cambiar parámetro
- `BACK`: Volver al menú anterior
- `CONFIRM`: Confirmar cambios

**Archivo:** `ESP32_Temp_Control_Valves_BT.ino:197-322`

---

### 📊 MAPA DE PINES ACTUALIZADO

#### Entradas Digitales
| Pin | Función | Tipo |
|-----|---------|------|
| GPIO 34 | BTN_UP | INPUT_PULLUP |
| GPIO 35 | BTN_DOWN | INPUT_PULLUP |
| GPIO 32 | BTN_NEXT | INPUT_PULLUP |
| GPIO 33 | BTN_BACK | INPUT_PULLUP |
| GPIO 25 | BTN_CONFIRM | INPUT_PULLUP |
| GPIO 36 | Sensor DS18B20 | 1-Wire |
| GPIO 39 | Entrada manual válvula 0 | INPUT_PULLUP |
| GPIO 37 | Entrada manual válvula 1 | INPUT_PULLUP |

#### Salidas Digitales
| Pin | Función | Tipo |
|-----|---------|------|
| GPIO 26 | SSR Control Temperatura | OUTPUT |
| GPIO 27 | LED SSR | OUTPUT |
| GPIO 14 | LED Sistema | OUTPUT |

#### Salidas de Válvulas
| Pin | Válvula | LED |
|-----|---------|-----|
| GPIO 2 | Válvula 1 | GPIO 4 |
| GPIO 15 | Válvula 2 | GPIO 5 |
| GPIO 13 | Válvula 3 | GPIO 18 |
| GPIO 12 | Válvula 4 | GPIO 19 |
| GPIO 16 | Válvula 5 | GPIO 21 |
| GPIO 17 | Válvula 6 | GPIO 22 |
| GPIO 0 | Válvula 7 | GPIO 23 |

---

### 🔄 FLUJO DE DATOS ACTUALIZADO

```
┌─────────────────────────────────────────────┐
│           ESP32-WROOM-32                    │
│                                             │
│  ┌──────────┐    ┌──────────┐             │
│  │ DS18B20  │───→│  Temp    │             │
│  │ (GPIO36) │    │ Control  │──→ SSR      │
│  └──────────┘    └──────────┘   (GPIO26)  │
│                                             │
│  ┌──────────┐    ┌──────────┐             │
│  │ Entradas │───→│  Valve   │──→ 7x GPIO  │
│  │ Manual   │    │ Control  │              │
│  └──────────┘    └──────────┘             │
│                        ↕                    │
│                  ┌──────────┐              │
│                  │Bluetooth │              │
│                  │  Serial  │              │
│                  └─────┬────┘              │
└────────────────────────┼───────────────────┘
                         ↓
                  ┌─────────────┐
                  │ App Flutter │
                  │  (Android)  │
                  └─────────────┘
```

---

### 📚 DEPENDENCIAS REQUERIDAS

#### Arduino IDE:
- `Adafruit_SSD1306` (OLED)
- `Adafruit_GFX` (Gráficos)
- `OneWire` (Comunicación 1-Wire)
- `DallasTemperature` (Sensor DS18B20)
- `BluetoothSerial` (ESP32 Bluetooth)

#### Flutter:
- `flutter_bluetooth_serial`
- `fl_chart`

---

### ⚠️ NOTAS IMPORTANTES

#### GPIO 0:
- Usado para válvula 7
- Tiene pull-up interno para boot mode
- No conectar cargas que impidan el bootloader
- En producción, considerar reasignar a otro GPIO

#### Sensor DS18B20:
- Requiere resistor pull-up de 4.7kΩ entre DATA y VCC
- Puede alimentarse en modo parásito o normal
- Soporta múltiples sensores en el mismo bus

#### Entradas Manuales:
- Implementación actual: 2 de 7 entradas
- Para 7 entradas completas: usar expansor I2C
- PCF8574: 8 I/O digitales
- MCP23017: 16 I/O digitales

---

### 🎯 PRÓXIMAS MEJORAS RECOMENDADAS

1. **Persistencia EEPROM**
   - Guardar setpoint de temperatura
   - Guardar configuración de válvulas
   - Recordar estado al reiniciar

2. **Expansor I2C para Válvulas**
   - Implementar PCF8574 o MCP23017
   - 7 entradas digitales completas
   - Lectura mediante I2C

3. **Sistema de Alarmas**
   - Notificación por temperatura fuera de rango
   - Alerta por sensor desconectado
   - Timeout de válvulas

4. **Conectividad WiFi**
   - Control remoto por red local
   - Integración con Home Assistant
   - Servidor web embebido

5. **Historial de Datos**
   - Almacenar temperaturas en SD
   - Exportar logs
   - Gráficos históricos

---

### ✅ TESTS RECOMENDADOS

Antes de usar en producción:

1. **Hardware:**
   - [ ] Verificar conexión del sensor DS18B20
   - [ ] Probar cada válvula individualmente
   - [ ] Verificar SSR con carga real
   - [ ] Comprobar LEDs indicadores

2. **Software:**
   - [ ] Probar todos los comandos Bluetooth
   - [ ] Verificar navegación del menú
   - [ ] Confirmar lectura de temperatura
   - [ ] Probar activación manual de válvulas

3. **Integración:**
   - [ ] Conectar app Flutter
   - [ ] Verificar sincronización de datos
   - [ ] Probar control desde app
   - [ ] Confirmar actualización en tiempo real

---

### 📧 SOPORTE

Para reportar problemas o sugerencias:
- Crear issue en el repositorio
- Incluir logs del Serial Monitor
- Describir pasos para reproducir el problema

---

**Desarrollado por:** TecnoWorldFuture
**Versión:** 2.0.0
**Fecha:** 2025-10-30
**Licencia:** MIT
