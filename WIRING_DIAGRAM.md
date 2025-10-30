# 🔌 DIAGRAMA DE CONEXIONES - Sistema ESP32 Control de Temperatura y Válvulas

**Versión:** 2.0.0
**Fecha:** 2025-10-30
**Proyecto:** ESP32-WROM32-CONTROL_TEMP_VALVULE

---

## ⚠️ ADVERTENCIAS DE SEGURIDAD

```
🔴 PELIGRO - ALTA TENSIÓN 220V AC
├─ Desconectar TODA alimentación antes de trabajar
├─ NO tocar componentes con alimentación conectada
├─ Usar herramientas aisladas
├─ Verificar polaridad y voltajes ANTES de energizar
├─ Aislar completamente circuitos AC de DC
└─ En caso de duda, consultar a un electricista certificado
```

**Este diagrama maneja voltajes MORTALES. Proceder con extrema precaución.**

---

## 📐 DIAGRAMA GENERAL DEL SISTEMA

```
                    ╔═══════════════════════════════════════════════════╗
                    ║           SISTEMA DE CONTROL ESP32                ║
                    ║                                                   ║
                    ║   ┌─────────────────────────────────────────┐   ║
                    ║   │      ESP32-WROOM-32 DevKit v1           │   ║
                    ║   │          (38 pines)                      │   ║
                    ║   │                                          │   ║
                    ║   │  GPIO 36 ◄─── DS18B20 (Temperatura)     │   ║
                    ║   │  GPIO 21,22 ◄─► OLED I2C               │   ║
                    ║   │  GPIO 26 ───► SSR (Calefacción)        │   ║
                    ║   │  GPIO 34,35,32,33,25 ◄─── 5 Botones    │   ║
                    ║   │  GPIO 2,15,13,12,16,17,0 ───► Válvulas │   ║
                    ║   │  GPIO 4,5,18,19,21,22,23 ───► LEDs     │   ║
                    ║   │  GPIO 27 ───► LED SSR                   │   ║
                    ║   │  GPIO 14 ───► LED Sistema              │   ║
                    ║   │  GPIO 39,37 ◄─── Entradas Manuales     │   ║
                    ║   │                                          │   ║
                    ║   │  VIN ◄─── 5V desde Fuente              │   ║
                    ║   │  GND ◄─── GND Común                     │   ║
                    ║   └─────────────────────────────────────────┘   ║
                    ║                                                   ║
                    ╚═══════════════════════════════════════════════════╝
                                         │
                    ┌────────────────────┼────────────────────┐
                    ▼                    ▼                    ▼
            ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
            │  SUBSISTEMA   │   │  SUBSISTEMA   │   │  SUBSISTEMA   │
            │  TEMPERATURA  │   │   VÁLVULAS    │   │   INTERFAZ    │
            └───────────────┘   └───────────────┘   └───────────────┘
```

---

## 📊 TABLA MAESTRA DE CONEXIONES ESP32

### Pines de Entrada (Input)

| GPIO | Función | Dispositivo | Tipo | Pull-up/down | Notas |
|------|---------|-------------|------|--------------|-------|
| **34** | BTN_UP | Pulsador menú | INPUT_PULLUP | Interno | Solo input, sin pull-down |
| **35** | BTN_DOWN | Pulsador menú | INPUT_PULLUP | Interno | Solo input, sin pull-down |
| **32** | BTN_NEXT | Pulsador menú | INPUT_PULLUP | Interno | - |
| **33** | BTN_BACK | Pulsador menú | INPUT_PULLUP | Interno | - |
| **25** | BTN_CONFIRM | Pulsador menú | INPUT_PULLUP | Interno | - |
| **36** | ONE_WIRE_BUS | Sensor DS18B20 | 1-Wire | Ext. 4.7kΩ | SVP - Solo input |
| **39** | VALVE_INPUT_0 | Pulsador válvula 0 | INPUT_PULLUP | Interno | SVN - Solo input |
| **37** | VALVE_INPUT_1 | Pulsador válvula 1 | INPUT_PULLUP | Interno | Solo input |

### Pines de Salida (Output)

| GPIO | Función | Dispositivo | Tipo | Corriente | Notas |
|------|---------|-------------|------|-----------|-------|
| **26** | SSR_PIN | Relé SSR | OUTPUT | 20mA | Control calefacción |
| **27** | LED_SSR | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **14** | LED_SYSTEM | LED sistema | OUTPUT | 15mA | Con R=1kΩ |
| **2** | VALVE_1 | Optoacoplador 1 | OUTPUT | 10mA | MOC3021 LED |
| **15** | VALVE_2 | Optoacoplador 2 | OUTPUT | 10mA | MOC3021 LED |
| **13** | VALVE_3 | Optoacoplador 3 | OUTPUT | 10mA | MOC3021 LED |
| **12** | VALVE_4 | Optoacoplador 4 | OUTPUT | 10mA | MOC3021 LED |
| **16** | VALVE_5 | Optoacoplador 5 | OUTPUT | 10mA | MOC3021 LED |
| **17** | VALVE_6 | Optoacoplador 6 | OUTPUT | 10mA | MOC3021 LED |
| **0** | VALVE_7 | Optoacoplador 7 | OUTPUT | 10mA | ⚠️ Boot mode, ver nota |
| **4** | LED_VALVE_1 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **5** | LED_VALVE_2 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **18** | LED_VALVE_3 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **19** | LED_VALVE_4 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **21** | LED_VALVE_5 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **22** | LED_VALVE_6 | LED indicador | OUTPUT | 15mA | Con R=470Ω |
| **23** | LED_VALVE_7 | LED indicador | OUTPUT | 15mA | Con R=470Ω |

### Pines de Comunicación I2C

| GPIO | Función | Dispositivo | Protocolo | Notas |
|------|---------|-------------|-----------|-------|
| **21** | SDA | OLED Display | I2C | Dirección 0x3C |
| **22** | SCL | OLED Display | I2C | Pull-up interno |

### Pines de Alimentación

| Pin | Voltaje | Corriente | Función |
|-----|---------|-----------|---------|
| **VIN** | 5V | 2-3A | Entrada alimentación principal |
| **3V3** | 3.3V | 500mA | Salida regulada (no usar como entrada) |
| **GND** | 0V | - | Tierra común (múltiples pines disponibles) |

---

## 🔧 SUBSISTEMA 1: SENSOR DE TEMPERATURA DS18B20

### Diagrama de Conexión

```
                     ESP32                        DS18B20
                  ┌─────────┐                  ┌───────────┐
                  │         │                  │           │
     3.3V ────────┤ 3V3     │                  │    VDD    ├──── 3.3V
                  │         │    ┌─── 4.7kΩ ───┤           │
     GPIO 36 ─────┤ GPIO36  ├────┤             │   DATA    │
                  │         │    └─────────────┤           │
     GND ─────────┤ GND     │                  │    GND    ├──── GND
                  │         │                  │           │
                  └─────────┘                  └───────────┘

NOTAS:
- Resistencia 4.7kΩ pull-up OBLIGATORIA entre DATA y VDD
- Cable máximo recomendado: 100 metros
- DS18B20 puede alimentarse en modo parásito (solo 2 cables)
- Temperatura: -55°C a +125°C
- Precisión: ±0.5°C (-10°C a +85°C)
```

### Conexiones Físicas

| DS18B20 Pin | Color Cable | ESP32 Pin | Componente Adicional |
|-------------|-------------|-----------|----------------------|
| VDD (Rojo) | Rojo | 3V3 | - |
| DATA (Amarillo) | Amarillo | GPIO 36 | Resistencia 4.7kΩ a 3V3 |
| GND (Negro) | Negro | GND | - |

### Esquema Eléctrico

```
    3.3V ───┬─────────────┬──── VDD (DS18B20)
            │             │
          [4.7kΩ]         │
            │             │
    GPIO36 ─┴─────────────┴──── DATA (DS18B20)

    GND ────────────────────── GND (DS18B20)
```

---

## 🖥️ SUBSISTEMA 2: PANTALLA OLED SSD1306

### Diagrama de Conexión

```
                     ESP32                        OLED 0.96"
                  ┌─────────┐                  ┌─────────────┐
                  │         │                  │             │
     3.3V ────────┤ 3V3     ├──────────────────┤ VCC         │
                  │         │                  │             │
     GND ─────────┤ GND     ├──────────────────┤ GND         │
                  │         │                  │             │
     GPIO 21 ─────┤ GPIO21  ├──────────────────┤ SDA  (I2C)  │
                  │         │                  │             │
     GPIO 22 ─────┤ GPIO22  ├──────────────────┤ SCL  (I2C)  │
                  │         │                  │             │
                  └─────────┘                  └─────────────┘

NOTAS:
- Dirección I2C por defecto: 0x3C
- Resolución: 128x64 píxeles
- NO conectar a 5V, solo 3.3V
- Pull-ups I2C ya incluidos en módulo OLED
```

### Tabla de Conexiones

| OLED Pin | ESP32 Pin | Voltaje | Protocolo |
|----------|-----------|---------|-----------|
| VCC | 3V3 | 3.3V | - |
| GND | GND | 0V | - |
| SDA | GPIO 21 | 3.3V | I2C Data |
| SCL | GPIO 22 | 3.3V | I2C Clock |

---

## 🎛️ SUBSISTEMA 3: BOTONES DE MENÚ (5 unidades)

### Diagrama de Conexión

```
    Botón UP (GPIO 34)                Esquema de 1 Botón:
    ┌───────────────┐
    │               │                      3.3V (Pull-up interno ESP32)
    │   ┌───────┐   │                         │
    │   │  ESP  │   │                         ↓
    │   │       │   │                 GPIO ──[ESP32]── (Pull-up)
    │   │ GPIO34├───┼──── Pulsador ────┐      │
    │   │       │   │                   │      │
    │   └───────┘   │                  [SW]    │
    │               │                   │      │
    └───────────────┘                  GND ────┘

    Todos los botones siguen el mismo esquema
```

### Tabla de Conexiones de Botones

| Función | GPIO | Pin 1 (Botón) | Pin 2 (Botón) | Resistencia | Tipo |
|---------|------|---------------|---------------|-------------|------|
| **BTN_UP** | GPIO 34 | Pin GPIO | Pin GND | Pull-up interno | INPUT_PULLUP |
| **BTN_DOWN** | GPIO 35 | Pin GPIO | Pin GND | Pull-up interno | INPUT_PULLUP |
| **BTN_NEXT** | GPIO 32 | Pin GPIO | Pin GND | Pull-up interno | INPUT_PULLUP |
| **BTN_BACK** | GPIO 33 | Pin GPIO | Pin GND | Pull-up interno | INPUT_PULLUP |
| **BTN_CONFIRM** | GPIO 25 | Pin GPIO | Pin GND | Pull-up interno | INPUT_PULLUP |

### Esquema Físico Detallado

```
Pulsador táctil 6x6mm (Vista superior):
    ┌─────────┐
    │ ●     ● │ ← Pin 1 (GPIO)
    │         │
    │    ▓    │ ← Botón
    │         │
    │ ●     ● │ ← Pin 2 (GND)
    └─────────┘

Conexión:
Pin 1 ──────────────── GPIO XX (ESP32)
Pin 2 ──────────────── GND

Lógica:
- Botón NO presionado: GPIO = HIGH (3.3V por pull-up)
- Botón presionado: GPIO = LOW (0V por conexión a GND)
```

---

## 🔌 SUBSISTEMA 4: ENTRADAS MANUALES DE VÁLVULAS

### Diagrama de Conexión

```
    Entrada Manual Válvula 0 (GPIO 39)
    ┌─────────────────────────────┐
    │                             │
    │   ┌───────┐                 │
    │   │  ESP  │                 │
    │   │       │                 │
    │   │ GPIO39├─────────┬───────┼──── Selector/Pulsador
    │   │       │         │       │
    │   └───────┘        [10kΩ]   │
    │                     │       │
    └─────────────────────┼───────┘
                         GND

    Entrada Manual Válvula 1 (GPIO 37)
    - Esquema idéntico con GPIO 37
```

### Tabla de Conexiones

| Válvula | GPIO | Tipo Entrada | Dispositivo | Función |
|---------|------|--------------|-------------|---------|
| Válvula 0 | GPIO 39 | INPUT_PULLUP | Selector/Pulsador | Activación manual independiente |
| Válvula 1 | GPIO 37 | INPUT_PULLUP | Selector/Pulsador | Activación manual independiente |
| Válvula 2-6 | - | Pendiente | Expansor I2C | Requiere PCF8574/MCP23017 |

### Expansión Futura con PCF8574 (Opcional)

```
Para implementar 7 entradas completas:

    ESP32                    PCF8574 (Expansor I2C)
    ┌─────────┐              ┌─────────────────────┐
    │         │              │                     │
    │ GPIO21──┼─────SDA──────┤ SDA      P0 ────────┼─── Válvula 0
    │ GPIO22──┼─────SCL──────┤ SCL      P1 ────────┼─── Válvula 1
    │ 3V3 ────┼──────────────┤ VCC      P2 ────────┼─── Válvula 2
    │ GND ────┼──────────────┤ GND      P3 ────────┼─── Válvula 3
    │         │              │          P4 ────────┼─── Válvula 4
    │         │              │          P5 ────────┼─── Válvula 5
    │         │              │          P6 ────────┼─── Válvula 6
    │         │              │          P7 ───────(NC)
    └─────────┘              └─────────────────────┘

Dirección I2C del PCF8574: 0x20 (por defecto)
```

---

## 🔥 SUBSISTEMA 5: CONTROL DE TEMPERATURA SSR

### Diagrama de Conexión Completo

```
    ESP32                                SSR 25A                     Carga AC
    ┌─────────┐                      ┌──────────┐                ┌──────────┐
    │         │                      │          │                │          │
    │ GPIO26──┼───[330Ω]───┬────────┤ +  LED - │                │  Carga   │
    │         │            │         │          │                │  (Heater)│
    │         │           ─┴─ LED    │   SSR    │   220V AC ─────┤ L1       │
    │         │            │  Rojo   │          │                │          │
    │ GPIO27──┼───[470Ω]───┴─────────┤ Input +  │                │  N  ─────┼─── Neutral
    │         │                      │          │                │          │
    │ GND ────┼──────────────────────┤ Input -  │                └──────────┘
    │         │                      │          │
    └─────────┘                      │  Relay   ├──── 220V L ────┐
                                     │  Output  │                │
                                     │          ├──── 220V N ────┤
                                     └──────────┘                │
                                                                  │
    ⚠️ ZONA DE ALTO VOLTAJE 220V AC ────────────────────────────┘
```

### Tabla de Conexiones SSR

| ESP32 Pin | Componente | SSR Terminal | Carga | Notas |
|-----------|------------|--------------|-------|-------|
| GPIO 26 | Resistencia 330Ω | + Input (LED+) | - | Control digital |
| GPIO 27 | LED Rojo + R470Ω | - | - | Indicador visual |
| GND | - | - Input (LED-) | - | Tierra común |
| - | - | Load L (Output) | Heater L1 | ⚠️ 220V AC |
| - | - | Load N (Output) | Heater N | ⚠️ 220V AC |

### Especificaciones SSR

```
Modelo recomendado: 3S-R-25DA o similar
├─ Control: 3-32V DC (usamos 3.3V)
├─ Corriente LED: 10-20mA
├─ Carga: 24-380V AC
├─ Corriente máxima: 25A
├─ Aislamiento: 2500V RMS
└─ Montaje: Requiere disipador si carga >10A
```

### ⚠️ Advertencias SSR

```
1. NUNCA conectar/desconectar bajo carga
2. Verificar polaridad de entrada DC
3. Usar fusible en línea AC (5A recomendado)
4. Disipador térmico obligatorio para >10A
5. Mantener distancia >5mm entre terminales AC y DC
6. NO exceder corriente nominal (25A)
```

---

## ⚡ SUBSISTEMA 6: CONTROL DE ELECTROVÁLVULAS (7 unidades)

### Circuito de una Válvula (MOC3021 + TRIAC + Electroválvula)

```
    ESP32              Optoacoplador         TRIAC              Electroválvula
    ┌───────┐          ┌──────────┐       ┌─────────┐         ┌──────────────┐
    │       │          │ MOC3021  │       │ BTA16   │         │              │
    │       │          │          │       │         │         │   Válvula    │
    │GPIO 2 ├─[330Ω]──┤1  LED   6├───────┤ Gate    │   220V──┤ Terminal 1   │
    │       │          │          │       │         │      L  │              │
    │       │          │  Opto   4├───┐   │  TRIAC  ├─────────┤ Terminal 2   │
    │ GND ──┼──────────┤2  LED    │   │   │         │         │              │
    │       │          │          │   │   │   MT1 ──┼─────────┤ Neutral   N  │
    └───────┘          └──────────┘   │   └─────────┘         └──────────────┘
                                      │        │                      │
                                      │       [R]                    │
                                      │        │                      │
                                      │       [C] Snubber            │
                                      │        │                      │
                                      └────────┴──────────────────────┘
                                            Neutral

R = 100Ω 1/2W
C = 100nF 250V AC (Snubber para protección TRIAC)

⚠️ ZONA DE ALTO VOLTAJE 220V AC
```

### Esquema Simplificado por Válvula

```
VÁLVULA 1 (GPIO 2):
ESP32 GPIO2 ──[330Ω]──►(MOC3021 pin1)
ESP32 GND ──────────────(MOC3021 pin2)
MOC3021 pin6 ──────────►(TRIAC Gate)
MOC3021 pin4 ──────────►(TRIAC MT1) ──► Neutral
TRIAC MT2 ─────────────►(Electroválvula L)
Electroválvula N ───────►Neutral

Repetir para las 7 válvulas con GPIOs diferentes
```

### Tabla de Conexiones de Todas las Válvulas

| Válvula | GPIO | LED GPIO | MOC3021 | TRIAC | Electroválvula AC | Snubber |
|---------|------|----------|---------|-------|-------------------|---------|
| **1** | GPIO 2 | GPIO 4 | U2 | Q1 | VALVE1 | R32+C1 |
| **2** | GPIO 15 | GPIO 5 | U3 | Q2 | VALVE2 | R33+C2 |
| **3** | GPIO 13 | GPIO 18 | U4 | Q3 | VALVE3 | R34+C3 |
| **4** | GPIO 12 | GPIO 19 | U5 | Q4 | VALVE4 | R35+C4 |
| **5** | GPIO 16 | GPIO 21 | U6 | Q5 | VALVE5 | R36+C5 |
| **6** | GPIO 17 | GPIO 22 | U7 | Q6 | VALVE6 | R37+C6 |
| **7** | GPIO 0 | GPIO 23 | U8 | Q7 | VALVE7 | R38+C7 |

### Pinout MOC3021

```
Vista superior (con muesca arriba):
     ┌───┐
  1 ─┤ ● ├─ 6
     │   │     Pin 1: Anode LED (←GPIO via R330Ω)
  2 ─┤   ├─ 5  Pin 2: Cathode LED (←GND)
     │   │     Pin 4: Main Terminal (→TRIAC MT1 → Neutral)
  3 ─┤   ├─ 4  Pin 6: Triac Terminal (→TRIAC Gate)
     └───┘     Pin 3,5: No conectar
```

### Pinout TRIAC BTA16-600B

```
Vista frontal (con texto visible):
      ┌──────┐
      │ TAB  │ ← MT2 (Main Terminal 2) → Electroválvula
      │      │
    ──┤  G   ├──  Gate (←MOC3021 pin6)
      │      │
    ──┤ MT1  ├──  MT1 (Main Terminal 1) → Neutral
      └──────┘
```

### Red Snubber (Protección TRIAC)

```
Circuito Snubber por válvula:

    MT2 (Carga)
      │
      ├───[100Ω 1/2W]───┬─── MT1 (Neutral)
      │                  │
      └───[100nF 250V]───┘

Función: Protege el TRIAC contra di/dt y dv/dt
Obligatorio: Recomendado para cargas inductivas
```

---

## 💡 SUBSISTEMA 7: LEDS INDICADORES

### Esquema General de LEDs

```
Cada LED sigue el mismo esquema:

    ESP32                         LED
    ┌─────────┐              ┌─────────┐
    │         │              │         │
    │ GPIO XX─┼───[470Ω]────┤►├───────┼─── GND
    │         │     │         │   │     │
    └─────────┘     │         └───┼────┘
                    │             │
                Resistencia      Cátodo
                limitadora       (corto)
```

### Tabla Completa de LEDs

| Función | GPIO | Color LED | Resistencia | Corriente | Notas |
|---------|------|-----------|-------------|-----------|-------|
| **LED Sistema** | GPIO 14 | Verde | 1kΩ | 2mA | Indica sistema encendido |
| **LED SSR** | GPIO 27 | Rojo | 470Ω | 5mA | Indica calefacción activa |
| **LED Válvula 1** | GPIO 4 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 2** | GPIO 5 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 3** | GPIO 18 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 4** | GPIO 19 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 5** | GPIO 21 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 6** | GPIO 22 | Rojo | 470Ω | 5mA | - |
| **LED Válvula 7** | GPIO 23 | Rojo | 470Ω | 5mA | - |

### Identificación de Patas del LED

```
LED 3mm o 5mm (Vista frontal):

    ┌──────┐
    │  ──  │
    │      │
    └──┬─┬─┘
       │ └── Pata corta = Cátodo (-) → GND
       └──── Pata larga = Ánodo (+) → GPIO (via resistencia)

LED SMD 0805/1206:
    ┌────────┐
    │   ▲ │  │ ← Marca indica cátodo
    └────────┘
```

### Cálculo de Resistencia Limitadora

```
Fórmula: R = (Vsupply - Vled) / Iled

Para LED rojo:
- Vsupply = 3.3V (ESP32)
- Vled = 2.0V (típico LED rojo)
- Iled = 5mA (deseado)
- R = (3.3 - 2.0) / 0.005 = 260Ω
- Uso valor estándar: 330Ω o 470Ω

Para LED verde:
- Vled = 2.2V (típico LED verde)
- R = (3.3 - 2.2) / 0.005 = 220Ω
- Uso valor estándar: 330Ω o 470Ω
```

---

## 🔋 SUBSISTEMA 8: ALIMENTACIÓN

### Diagrama de Distribución de Alimentación

```
    Fuente 5V 3A           Regulador ESP32         Distribución
    ┌──────────┐           ┌──────────┐
    │          │           │  ESP32   │
    │  220V AC │           │ AMS1117  │
    │    ↓     │           │  3.3V    │
    │ [Trafo]  │           └────┬─────┘
    │    ↓     │                │
    │ 5V DC ───┼────────────────┤
    │   3A     │    │           │
    └──────────┘    │           ├───────► OLED (3.3V, 20mA)
         │          │           ├───────► DS18B20 (3.3V, 1mA)
         │          │           ├───────► LEDs x9 (3.3V, 45mA total)
         │          │           └───────► Lógica ESP32 (3.3V, 240mA)
         │          │
         │          └───[100µF]──► GND (Filtro)
         │
         ├──────────────────────────────► ESP32 VIN (5V)
         │
         └──────────────────────────────► GND Común

    Total consumo 3.3V: ~306mA (ESP32 regula desde 5V)
    Total consumo 5V: ~500mA (incluyendo regulador)
```

### Tabla de Consumos

| Componente | Voltaje | Corriente Típica | Corriente Máxima | Notas |
|------------|---------|------------------|------------------|-------|
| ESP32 core | 3.3V | 80mA | 240mA | WiFi/BT desactivados |
| ESP32 con BT | 3.3V | 120mA | 240mA | Bluetooth activo |
| OLED SSD1306 | 3.3V | 8mA | 20mA | Depende de píxeles encendidos |
| DS18B20 | 3.3V | 1mA | 1.5mA | Durante conversión |
| LED Sistema (verde) | 3.3V | 2mA | 5mA | Con R=1kΩ |
| LED SSR (rojo) | 3.3V | 5mA | 10mA | Con R=470Ω |
| LEDs Válvulas x7 | 3.3V | 35mA | 70mA | 7x5mA, con R=470Ω |
| **TOTAL 3.3V** | - | **251mA** | **546mA** | Regulado por ESP32 |
| SSR entrada | 3.3V | 10mA | 20mA | Control LED SSR |
| MOC3021 x7 | 3.3V | 70mA | 140mA | 7x10mA típico |
| **TOTAL 5V** | - | **~500mA** | **~1A** | Incluyendo regulación |

### Conexiones de Alimentación ESP32 DevKit

```
ESP32 DevKit v1 (38 pines):

    Pin VIN  ◄───── 5V desde fuente
    Pin 3V3  ◄───── NO CONECTAR (es salida)
    Pin GND  ◄───── GND común

    Múltiples pines GND disponibles:
    ├─ Pin GND (arriba izquierda)
    ├─ Pin GND (arriba derecha)
    └─ Pin GND (abajo)
```

### Esquema de Tierra Común (GND)

```
                        GND COMÚN
                            │
            ┌───────────────┼───────────────┐
            │               │               │
         ESP32           OLED           DS18B20
          GND             GND              GND
            │               │               │
            ├───────────────┼───────────────┤
            │               │               │
        Botones x5      LEDs x9         SSR
          GND             GND         Input (-)
            │               │               │
            └───────────────┼───────────────┘
                            │
                    ⚠️ Tierra común
                    (NO conectar a AC neutral)
```

### ⚠️ Aislamiento AC/DC

```
CRÍTICO: Separación de Tierras

    Circuito DC (ESP32)          Circuito AC (220V)
    ┌─────────────────┐          ┌─────────────────┐
    │                 │          │                 │
    │  ESP32 GND      │          │  Neutral AC     │
    │       │         │          │       │         │
    │    Tierra DC    │          │   Tierra AC     │
    └───────┬─────────┘          └───────┬─────────┘
            │                            │
            │  ❌ NO CONECTAR ❌         │
            │                            │
            │  Aislamiento via:          │
            │  - Optoacopladores         │
            │  - SSR                     │
            └────────────────────────────┘

NUNCA conectar GND del ESP32 al Neutral de 220V
```

---

## 📋 RESUMEN DE COMPONENTES POR SUBSISTEMA

### Subsistema 1: Temperatura
- 1x DS18B20
- 1x Resistencia 4.7kΩ
- Cable 3 conductores

### Subsistema 2: Display
- 1x OLED SSD1306 0.96"
- 4x Cable dupont

### Subsistema 3: Menú
- 5x Pulsadores 6x6mm
- Cable conexión

### Subsistema 4: Entradas Manuales
- 2x Pulsadores 12x12mm
- Opcional: 1x PCF8574 (expansión)

### Subsistema 5: Control Temperatura
- 1x SSR 25A
- 1x Resistencia 330Ω
- 1x LED rojo
- 1x Resistencia 470Ω
- Cable AC 220V

### Subsistema 6: Válvulas (x7 conjuntos)
- 7x MOC3021
- 7x TRIAC BTA16-600B
- 7x Electroválvula 220V AC
- 7x Resistencia 330Ω
- 7x Resistencia 100Ω 1/2W (snubber)
- 7x Capacitor 100nF 250V AC (snubber)
- Cable AC 220V

### Subsistema 7: Indicadores
- 1x LED verde (sistema)
- 8x LED rojo (SSR + válvulas)
- 1x Resistencia 1kΩ
- 8x Resistencia 470Ω

### Subsistema 8: Alimentación
- 1x Fuente 5V 3A
- 1x Capacitor 100µF 16V
- 2x Capacitor 100nF 50V
- Borneras y conectores

---

## 🔧 GUÍA DE MONTAJE PASO A PASO

### Paso 1: Preparación (30 minutos)
```
[ ] Verificar todos los componentes contra BOM
[ ] Preparar herramientas (soldador, multímetro, alicates)
[ ] Limpiar área de trabajo
[ ] Imprimir este diagrama
[ ] Tener datasheet a mano (ESP32, MOC3021, BTA16)
```

### Paso 2: Montaje ESP32 y Periféricos DC (1 hora)
```
[ ] Soldar headers al ESP32 si es necesario
[ ] Conectar OLED I2C (GPIO 21, 22)
[ ] Conectar DS18B20 con resistencia 4.7kΩ (GPIO 36)
[ ] Conectar 5 botones de menú (GPIO 34,35,32,33,25)
[ ] Conectar 2 entradas manuales (GPIO 39,37)
[ ] Conectar 9 LEDs con resistencias (GPIO 14,27,4,5,18,19,21,22,23)
```

### Paso 3: Prueba de Periféricos (30 minutos)
```
[ ] Conectar fuente 5V al ESP32 VIN
[ ] Cargar firmware de prueba
[ ] Verificar OLED muestra información
[ ] Verificar lectura de DS18B20
[ ] Probar cada botón
[ ] Verificar LEDs encienden
```

### Paso 4: Montaje Circuito SSR (30 minutos)
```
[ ] Soldar resistencia 330Ω a GPIO 26
[ ] Conectar SSR Input+ (via resistencia)
[ ] Conectar SSR Input- a GND
[ ] NO conectar aún 220V AC
```

### Paso 5: Montaje Circuitos Válvulas (2 horas)
```
Por cada válvula (repetir 7 veces):
[ ] Soldar resistencia 330Ω al GPIO correspondiente
[ ] Conectar MOC3021 pin 1 (via resistencia)
[ ] Conectar MOC3021 pin 2 a GND
[ ] Soldar TRIAC: Gate a MOC3021 pin 6
[ ] Soldar TRIAC: MT1 a MOC3021 pin 4
[ ] Soldar snubber (R 100Ω + C 100nF) entre MT2 y MT1
[ ] Verificar aislamiento entre circuito DC y AC
```

### Paso 6: Prueba de Lógica (1 hora)
```
[ ] Cargar firmware completo v2.0.0
[ ] Probar cada salida de válvula con LED (sin AC)
[ ] Verificar respuesta de SSR
[ ] Comprobar lectura temperatura
[ ] Navegar por menú OLED
[ ] Probar comandos Bluetooth desde app
```

### Paso 7: Conexión AC 220V (⚠️ PELIGRO - 1 hora)
```
⚠️ DESCONECTAR toda alimentación antes de trabajar

[ ] Instalar fusible 5A en línea Live
[ ] Conectar varistor MOV 275V entre L y N
[ ] Conectar SSR Output a carga (heater)
[ ] Conectar 7 electroválvulas a TRIACs MT2
[ ] Verificar aislamiento con multímetro (>1MΩ)
[ ] Conectar todos Neutral a barra común
[ ] Verificar conexiones múltiples veces
[ ] Cerrar gabinete
```

### Paso 8: Prueba Final (1 hora)
```
⚠️ Con gabinete CERRADO

[ ] Energizar 220V AC
[ ] Verificar LEDs sistema
[ ] Probar SSR con carga ligera
[ ] Activar cada válvula individualmente
[ ] Verificar temperatura real con termómetro
[ ] Probar control desde app Bluetooth
[ ] Verificar entradas manuales
[ ] Dejar funcionar 30 minutos monitoreando temperatura
```

---

## ⚠️ CHECKLIST DE SEGURIDAD

### Antes de Energizar
```
[ ] Todas las conexiones AC verificadas
[ ] Aislamiento DC/AC confirmado (>1MΩ)
[ ] Fusible instalado
[ ] Varistor instalado
[ ] Gabinete cerrado
[ ] Sin cables sueltos
[ ] Herramientas retiradas del área
[ ] Polaridad verificada
[ ] Sin cortocircuitos visibles
[ ] Disipadores instalados (si aplica)
```

### Durante Operación
```
[ ] Monitorear temperatura de componentes
[ ] Verificar LEDs indicadores
[ ] Escuchar sonidos anormales
[ ] Verificar válvulas abren/cierran
[ ] Comprobar temperatura real vs setpoint
[ ] Ningún olor a quemado
[ ] Fusible intacto
```

### Después de Uso
```
[ ] Desconectar 220V AC si no se usa
[ ] Verificar componentes no sobrecalentados
[ ] Limpiar área de trabajo
[ ] Anotar observaciones
[ ] Actualizar documentación si hay cambios
```

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Problema: OLED no muestra nada
```
Verificar:
[ ] Conexión I2C (GPIO 21=SDA, GPIO 22=SCL)
[ ] Voltaje OLED (debe ser 3.3V, NO 5V)
[ ] Dirección I2C correcta (0x3C típico)
[ ] Librería Adafruit_SSD1306 instalada
[ ] Inicialización en código: display.begin()
```

### Problema: DS18B20 no lee temperatura
```
Verificar:
[ ] Resistencia pull-up 4.7kΩ instalada
[ ] Conexión correcta (VDD, DATA, GND)
[ ] Sensor no invertido
[ ] Librería DallasTemperature instalada
[ ] Sensor no dañado (probar con otro)
[ ] Cable no excede 100m
```

### Problema: Botones no responden
```
Verificar:
[ ] Pulsador conectado entre GPIO y GND
[ ] INPUT_PULLUP configurado en código
[ ] Antirrebote implementado (debounce)
[ ] Pulsador no dañado (probar continuidad)
[ ] GPIO no usado para otra función
```

### Problema: LEDs no encienden
```
Verificar:
[ ] Polaridad correcta (ánodo a GPIO via R, cátodo a GND)
[ ] Resistencia limitadora instalada
[ ] GPIO configurado como OUTPUT
[ ] digitalWrite(pin, HIGH) en código
[ ] LED no quemado (probar con 3.3V directo)
```

### Problema: SSR no activa carga
```
Verificar:
[ ] Resistencia 330Ω en serie con GPIO 26
[ ] Polaridad SSR Input (+/-)
[ ] Voltaje control >3V DC
[ ] Carga AC conectada correctamente
[ ] SSR no dañado (probar con multímetro)
[ ] Fusible AC intacto
```

### Problema: Válvulas no activan
```
Verificar:
[ ] MOC3021 conexiones correctas (pin 1,2,4,6)
[ ] TRIAC Gate conectado a MOC3021 pin 6
[ ] TRIAC MT1 a Neutral
[ ] TRIAC MT2 a electroválvula
[ ] Electroválvula recibe 220V cuando activa
[ ] Snubber instalado (reduce fallos)
[ ] TRIAC no en cortocircuito
```

### Problema: ESP32 no arranca
```
Verificar:
[ ] Alimentación 5V presente en VIN
[ ] GND conectado
[ ] GPIO 0 no forzado a GND al arrancar
[ ] Consumo no excede capacidad fuente
[ ] Capacitor filtro 100µF instalado
[ ] USB conectado (para programación)
[ ] Botón BOOT no presionado
```

---

## 📐 DIMENSIONES Y LAYOUT RECOMENDADO

### Layout de PCB (Sugerido 15x20cm)

```
    ┌─────────────────────────────────────────────┐
    │ [FUENTE 5V]    [ESP32]         [OLED]       │
    │                                              │
    │ [Botones x5]                                 │
    │                                              │
    │ [LEDs x9 con R]                              │
    │                                              │
    │ [MOC3021 x7]  [TRIAC x7]  [Snubbers x7]    │
    │                                              │
    │ [Borneras AC] [Borneras Válvulas x7]        │
    │                                              │
    │ [SSR]  [Fusible]  [Varistor]                │
    └─────────────────────────────────────────────┘

    Separación mínima:
    - AC a DC: 10mm
    - TRIAC a MOC3021: 5mm
    - Pistas AC: 2mm ancho
    - Pistas DC: 0.5mm ancho
```

---

## 📞 SOPORTE ADICIONAL

**Documentos relacionados:**
- `BOM.md` - Lista completa de materiales
- `SHOPPING_LIST.md` - Lista de compra
- `CHANGELOG.md` - Detalles técnicos del firmware
- `README.md` - Información general del proyecto

**Para dudas:**
- Crear issue en el repositorio GitHub
- Incluir fotos del montaje
- Adjuntar logs del Serial Monitor
- Especificar qué ya se verificó

---

**Documento generado:** 2025-10-30
**Versión:** 2.0.0
**Autor:** TecnoWorldFuture
**Licencia:** MIT

**⚠️ ADVERTENCIA FINAL:**
Este proyecto maneja voltajes MORTALES de 220V AC.
Si no tienes experiencia con electricidad, busca ayuda profesional.
El autor no se hace responsable por daños, lesiones o muerte
resultantes del uso inadecuado de esta información.

**Trabaja seguro. Trabaja inteligente. 🛡️**
