# Lista de Materiales (BOM) - Sistema ESP32 Control de Temperatura y Válvulas

**Proyecto:** Sistema de Control de Temperatura y 7 Electroválvulas AC
**Versión:** 2.0.0
**Fecha:** 2025-10-30

---

## 📦 COMPONENTES PRINCIPALES

| Cantidad | Componente | Especificación | Uso | Ref. |
|----------|-----------|----------------|-----|------|
| 1 | **ESP32-WROOM-32** | Módulo ESP32 DevKit v1 o compatible, 38 pines | Microcontrolador principal | U1 |
| 1 | **Pantalla OLED** | SSD1306, 0.96", 128x64, I2C (0x3C) | Interfaz de usuario | DISP1 |
| 1 | **Sensor de Temperatura** | DS18B20, 1-Wire, TO-92 o encapsulado resistente al agua | Medición de temperatura | TEMP1 |
| 1 | **SSR (Solid State Relay)** | 3S-R-25DA o similar, 25A, 24-380V AC, control 3-32V DC | Control de calefacción | SSR1 |
| 7 | **Optoacoplador** | MOC3021 o MOC3041, salida TRIAC | Aislamiento válvulas AC | U2-U8 |
| 7 | **TRIAC** | BTA16-600B o similar, 16A, 600V | Conmutación válvulas AC | Q1-Q7 |
| 7 | **Electroválvula AC** | 220V AC, normalmente cerrada, rosca 1/2" o según aplicación | Control de fluidos | VALVE1-7 |

---

## 🔌 COMPONENTES DE POTENCIA Y PROTECCIÓN

| Cantidad | Componente | Especificación | Uso | Ref. |
|----------|-----------|----------------|-----|------|
| 1 | **Fuente 5V** | 5V 2A mínimo (recomendado 3A), switching | Alimentación ESP32 y lógica | PS1 |
| 1 | **Regulador de voltaje** | AMS1117-3.3V o similar (si no está en DevKit) | Alimentación OLED y sensor | REG1 |
| 8 | **Resistencia pull-up/down** | 10kΩ, 1/4W | Botones y control | R1-R8 |
| 1 | **Resistencia pull-up** | 4.7kΩ, 1/4W | Sensor DS18B20 (DATA a VCC) | R9 |
| 7 | **Resistencia limitadora** | 330Ω, 1/4W | Optoacopladores MOC3021 | R10-R16 |
| 14 | **Resistencia limitadora** | 470Ω, 1/4W | LEDs indicadores (7 válvulas + SSR) | R17-R30 |
| 1 | **Resistencia limitadora** | 1kΩ, 1/4W | LED sistema | R31 |
| 7 | **Snubber RC** | 100Ω + 100nF (opcional pero recomendado) | Protección TRIACs | C1-C7, R32-R38 |
| 1 | **Capacitor de filtro** | 100µF 16V electrolítico | Filtro fuente 5V | C8 |
| 2 | **Capacitor cerámico** | 100nF 50V | Desacople ESP32 y circuitos | C9-C10 |
| 1 | **Fusible** | 5A rápido para línea 220V AC | Protección circuito AC | F1 |
| 1 | **Portafusible** | Para PCB o riel DIN | Montaje fusible | - |
| 1 | **Varistor** | 275V MOV (Metal Oxide Varistor) | Protección sobretensión AC | VR1 |

---

## 🎛️ INTERFAZ DE USUARIO

| Cantidad | Componente | Especificación | Uso | Ref. |
|----------|-----------|----------------|-----|------|
| 5 | **Pulsadores** | 6x6mm táctil o 12x12mm panel, normalmente abierto | Navegación menú (UP/DOWN/NEXT/BACK/CONFIRM) | BTN1-5 |
| 2 | **Pulsadores/Selectores** | Opcional: montaje panel, industrial | Entrada manual válvulas 0 y 1 | SW1-2 |
| 8 | **LED 3mm o 5mm** | Rojo (7 válvulas + 1 SSR) | Indicadores de estado válvulas y SSR | LED1-8 |
| 1 | **LED 3mm o 5mm** | Verde | Indicador sistema encendido | LED9 |

---

## 🔩 CONECTORES Y CABLEADO

| Cantidad | Componente | Especificación | Uso | Ref. |
|----------|-----------|----------------|-----|------|
| 1 | **Bornera 2 polos** | 5mm, 10A mínimo | Entrada 220V AC | J1 |
| 7 | **Bornera 2 polos** | 5mm, 10A mínimo | Salidas válvulas AC | J2-J8 |
| 1 | **Bornera 2 polos** | 3.5mm | Salida SSR | J9 |
| 1 | **Conector DC** | Barrel jack 5.5x2.1mm hembra | Entrada fuente 5V | J10 |
| 1 | **Header hembra** | 2x19 pines (38 pines total) 2.54mm | Montaje ESP32 | - |
| 1 | **Header macho** | 4 pines 2.54mm | Conexión OLED I2C | J11 |
| 1 | **Header macho** | 3 pines 2.54mm | Conexión DS18B20 | J12 |
| 5m | **Cable dupont** | Macho-macho y macho-hembra | Conexiones protoboard | - |
| 3m | **Cable sólido** | AWG 22 varios colores | Conexiones internas | - |
| 3m | **Cable flexible** | AWG 18 o 16 | Conexiones AC 220V | - |
| 1 rollo | **Tubo termocontráctil** | Varios diámetros | Aislamiento conexiones | - |

---

## 🏗️ MONTAJE Y ESTRUCTURA

| Cantidad | Componente | Especificación | Uso | Ref. |
|----------|-----------|----------------|-----|------|
| 1 | **PCB** | OPCIÓN A: Diseño personalizado ~15x20cm | Montaje componentes (recomendado) | - |
| 1 | **Protoboard/Perfboard** | OPCIÓN B: 10x15cm doble cara | Montaje componentes (alternativo) | - |
| 1 | **Gabinete plástico** | Mínimo 20x15x8cm, IP20 o superior | Caja contenedora | - |
| 1 | **Riel DIN** | 35mm, 15cm longitud (opcional) | Montaje profesional | - |
| 10 | **Separadores M3** | 10mm nylon o metálicos | Montaje PCB | - |
| 20 | **Tornillos M3** | 6mm + 10mm varios | Fijación general | - |
| 4 | **Tornillos M2.5** | 6mm | Montaje OLED | - |
| 1 | **Placa de montaje** | DIN o aluminio | Soporte componentes (opcional) | - |

---

## ⚡ ALIMENTACIÓN

### Opción A: Fuente Externa (Recomendada)
| Cantidad | Componente | Especificación |
|----------|-----------|----------------|
| 1 | Fuente switching | 5V 3A, encapsulada, con cable AC |

### Opción B: Fuente Integrada
| Cantidad | Componente | Especificación |
|----------|-----------|----------------|
| 1 | Módulo fuente AC-DC | Hi-Link HLK-5M05 o similar, 5V 1A |
| 1 | Transformador | 220V a 9V AC, 500mA (alternativo) |
| 1 | Puente rectificador | 1A 50V |
| 1 | Regulador lineal | LM7805 + disipador |

---

## 🛠️ HERRAMIENTAS NECESARIAS

| Herramienta | Uso |
|-------------|-----|
| Soldador eléctrico | 30-60W con punta fina |
| Estaño | 60/40 con resina |
| Multímetro digital | Medición voltaje/continuidad |
| Alicates de corte | Corte de componentes |
| Alicates de punta | Manipulación de cables |
| Destornilladores | Plano y Phillips varios tamaños |
| Pelacables | AWG 22-18 |
| Pistola de calor | Tubo termocontráctil (opcional) |
| Taladro | Perforación de gabinete (opcional) |

---

## 📱 SOFTWARE Y LICENCIAS

| Item | Descripción | Costo |
|------|-------------|-------|
| Arduino IDE | Gratuito | $0 |
| Librerías ESP32 | Gratuitas | $0 |
| Flutter SDK | Gratuito | $0 |
| App móvil | Código incluido | $0 |

---

## 💰 RESUMEN DE COSTOS (ESTIMADO USD)

### Componentes Básicos
| Categoría | Cantidad | Costo Unit. | Subtotal |
|-----------|----------|-------------|----------|
| ESP32-WROOM-32 | 1 | $8.00 | $8.00 |
| OLED 0.96" | 1 | $5.00 | $5.00 |
| DS18B20 | 1 | $3.00 | $3.00 |
| SSR 25A | 1 | $8.00 | $8.00 |
| MOC3021 | 7 | $0.50 | $3.50 |
| TRIAC BTA16 | 7 | $1.50 | $10.50 |
| Electroválvula 220V AC | 7 | $12.00 | $84.00 |

### Componentes Pasivos y Varios
| Categoría | Costo Estimado |
|-----------|----------------|
| Resistencias (todas) | $2.00 |
| Capacitores (todos) | $3.00 |
| LEDs (9 unidades) | $1.50 |
| Pulsadores (7 unidades) | $3.50 |
| Conectores y borneras | $8.00 |
| Cables y tubo termocontráctil | $5.00 |

### Estructura y Alimentación
| Categoría | Costo Estimado |
|-----------|----------------|
| Fuente 5V 3A | $6.00 |
| Gabinete plástico | $12.00 |
| PCB personalizado | $15.00 |
| Tornillería y separadores | $3.00 |
| Protecciones (fusible, varistor) | $3.00 |

### **TOTAL ESTIMADO: ~$183.00 USD**

*Nota: Precios aproximados, pueden variar según proveedor y región*

---

## 🛒 PROVEEDORES RECOMENDADOS

### Componentes Electrónicos:
- **AliExpress** - ESP32, OLED, sensores (envío internacional)
- **Mouser Electronics** - Componentes profesionales
- **Digi-Key** - Stock amplio, envío rápido
- **Amazon** - Kits y componentes populares

### Electroválvulas:
- **Grainger** - Electroválvulas industriales
- **Alibaba** - Compra al por mayor
- **Proveedores locales** - Plomería industrial

### PCB:
- **JLCPCB** - Fabricación económica
- **PCBWay** - Calidad profesional
- **Aisler** - Envío Europa

---

## 📋 LISTA DE COMPRA RÁPIDA

### Paquete 1: Microcontrolador y Sensores
```
[ ] 1x ESP32-WROOM-32 DevKit
[ ] 1x OLED SSD1306 0.96" I2C
[ ] 1x DS18B20 temperatura (encapsulado impermeable)
[ ] 1x Resistencia 4.7kΩ (pull-up DS18B20)
```

### Paquete 2: Control de Potencia
```
[ ] 1x SSR 25A (3S-R-25DA o similar)
[ ] 7x MOC3021 optoacoplador
[ ] 7x TRIAC BTA16-600B
[ ] 7x Resistencia 330Ω (optoacopladores)
[ ] 7x Set snubber (100Ω + 100nF)
```

### Paquete 3: Electroválvulas
```
[ ] 7x Electroválvula 220V AC (especificar rosca y tipo)
```

### Paquete 4: Interfaz Usuario
```
[ ] 5x Pulsadores 6x6mm (menú)
[ ] 2x Pulsadores 12x12mm (activación manual)
[ ] 8x LED 3mm rojo (válvulas + SSR)
[ ] 1x LED 3mm verde (sistema)
[ ] 9x Resistencia 470Ω (LEDs)
```

### Paquete 5: Conectores y Alimentación
```
[ ] 1x Fuente 5V 3A switching
[ ] 8x Bornera 2 polos (AC)
[ ] 1x Conector DC barrel jack
[ ] Headers macho/hembra
[ ] Cable dupont varios
[ ] Cable AWG 18 (AC)
```

### Paquete 6: Protecciones
```
[ ] 1x Fusible 5A + portafusible
[ ] 1x Varistor 275V MOV
[ ] 2x Capacitor 100nF cerámico
[ ] 1x Capacitor 100µF electrolítico
```

### Paquete 7: Estructura
```
[ ] 1x Gabinete plástico 20x15x8cm
[ ] 1x PCB o perfboard 15x20cm
[ ] 1x Header hembra 2x19 (ESP32)
[ ] Tornillería M3 y M2.5
[ ] Separadores 10mm
```

---

## 🔍 ESPECIFICACIONES TÉCNICAS DE COMPONENTES CRÍTICOS

### ESP32-WROOM-32
- **Voltaje:** 3.3V (regulado en DevKit desde 5V)
- **Corriente:** ~240mA típica, 500mA pico
- **GPIOs:** 34 digitales (algunos solo entrada)
- **I2C:** 2 buses (usamos uno para OLED)
- **1-Wire:** Cualquier GPIO (usamos GPIO 36)
- **Bluetooth:** 2.4 GHz Classic + BLE

### DS18B20
- **Rango temperatura:** -55°C a +125°C
- **Precisión:** ±0.5°C (-10°C a +85°C)
- **Resolución:** 9 a 12 bits configurable (0.0625°C a 12 bits)
- **Alimentación:** 3.0V a 5.5V
- **Cable recomendado:** Máximo 100m (con resistencia adecuada)

### SSR (Solid State Relay)
- **Control:** 3-32V DC (usamos 3.3V ESP32)
- **Carga:** 24-380V AC, 25A
- **Corriente LED:** ~10-20mA
- **Ventajas:** Sin ruido mecánico, vida útil larga, conmutación rápida
- **Importante:** Requiere disipador de calor para cargas >10A

### MOC3021 + TRIAC
- **MOC3021:** Optoacoplador salida TRIAC, aislamiento 5000V RMS
- **Corriente LED:** 5-30mA (usamos ~10mA con R=330Ω)
- **BTA16-600B:** TRIAC 16A RMS, 600V
- **Disipación:** Máximo 35W (requiere disipador para >5A)
- **Snubber RC:** Recomendado 100Ω 1/2W + 100nF 250V AC

### Electroválvulas
- **Voltaje:** 220V AC (verificar según región: 110V US, 230V EU)
- **Tipo:** Normalmente cerrada (NC)
- **Corriente:** ~50-200mA según modelo
- **Rosca:** 1/2" BSP común (verificar según instalación)
- **Presión:** Típica 0-10 bar
- **Aplicaciones:** Agua, aire, gases inertes (verificar compatibilidad)

---

## ⚠️ NOTAS DE SEGURIDAD

### Manejo de 220V AC
1. **Siempre desconectar** la alimentación AC antes de trabajar
2. **Usar fusible** y varistor para protección
3. **Aislamiento adecuado** entre circuitos AC y DC
4. **Gabinete cerrado** para evitar contacto accidental
5. **Distancia de fuga** mínima 5mm entre pistas AC en PCB
6. **Cable apropiado** AWG 18 o menor para AC
7. **Etiquetado claro** de conexiones peligrosas

### Componentes de Potencia
1. **Disipadores** para SSR y TRIACs si carga >10A
2. **Ventilación** adecuada en gabinete
3. **Protección térmica** opcional (termostato 60°C)
4. **Testing** con multímetro antes de energizar

---

## 📝 CHECKLIST DE COMPRA

Antes de ordenar, verificar:

```
[ ] Voltaje de electroválvulas correcto para tu región
[ ] Tipo de rosca de electroválvulas compatible con instalación
[ ] ESP32 con 38 pines (no versiones compactas)
[ ] OLED con dirección I2C 0x3C (mayoría lo tienen)
[ ] DS18B20 con cable si necesitas montaje remoto
[ ] Fuente 5V con suficiente corriente (mínimo 2A)
[ ] Gabinete con espacio suficiente para componentes
[ ] Cantidad correcta de borneras y conectores
[ ] Resistencias de valores correctos
[ ] TRIACs con corriente superior a carga de válvulas
```

---

## 📞 SOPORTE Y CONSULTAS

Para dudas sobre componentes o equivalencias:
- Crear issue en el repositorio
- Consultar datasheets de fabricantes
- Verificar compatibilidad con proveedores locales

---

**Documento generado:** 2025-10-30
**Versión:** 2.0.0
**Licencia:** MIT
**Proyecto:** ESP32-WROM32-CONTROL_TEMP_VALVULE
