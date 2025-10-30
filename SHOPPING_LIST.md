# 🛒 LISTA DE COMPRA RÁPIDA - Sistema ESP32 Control de Temperatura y Válvulas

**Imprime esta lista para llevarla contigo o enviar a proveedores**

---

## 📱 COMPONENTES PRINCIPALES (8 items)

```
[ ] 1x ESP32-WROOM-32 DevKit v1 (38 pines)
[ ] 1x Pantalla OLED SSD1306 0.96" 128x64 I2C (azul o blanco)
[ ] 1x Sensor temperatura DS18B20 (encapsulado impermeable recomendado)
[ ] 1x SSR Relé estado sólido 25A 3-32V DC control, 24-380V AC carga
[ ] 7x Optoacoplador MOC3021 o MOC3041
[ ] 7x TRIAC BTA16-600B o equivalente 16A 600V
[ ] 7x Electroválvula 220V AC normalmente cerrada (NC) rosca 1/2"
[ ] 1x Fuente alimentación 5V 3A switching con cable AC
```

**Subtotal estimado: ~$130 USD**

---

## 🔧 COMPONENTES PASIVOS (Resistencias)

```
[ ] 10x Resistencia 10kΩ 1/4W (botones y pull-ups)
[ ] 1x  Resistencia 4.7kΩ 1/4W (DS18B20 pull-up) ⚠️ IMPORTANTE
[ ] 7x  Resistencia 330Ω 1/4W (optoacopladores)
[ ] 15x Resistencia 470Ω 1/4W (LEDs)
[ ] 1x  Resistencia 1kΩ 1/4W (LED sistema)
```

**Tip:** Comprar kit surtido de resistencias 1/4W (más económico)

---

## 🔧 COMPONENTES PASIVOS (Capacitores)

```
[ ] 7x  Capacitor cerámico 100nF 250V AC (snubber TRIACs)
[ ] 2x  Capacitor cerámico 100nF 50V (desacople)
[ ] 1x  Capacitor electrolítico 100µF 16V (filtro fuente)
```

**Opcional pero recomendado:**
```
[ ] 7x  Resistencia 100Ω 1/2W (snubber TRIACs)
```

---

## 💡 LEDS INDICADORES (9 items)

```
[ ] 8x LED 3mm o 5mm ROJO (7 válvulas + 1 SSR)
[ ] 1x LED 3mm o 5mm VERDE (sistema encendido)
```

**Alternativa:** LED bicolor rojo/verde para ahorrar espacio

---

## 🎛️ BOTONES Y CONTROLES (7 items)

```
[ ] 5x Pulsador táctil 6x6mm o 12x12mm montaje panel (menú)
      → UP, DOWN, NEXT, BACK, CONFIRM

[ ] 2x Pulsador 12x12mm o selector industrial (activación manual válvulas)
      → Entrada manual válvula 0 y 1
```

---

## 🔌 CONECTORES Y BORNERAS (12 items)

```
[ ] 8x  Bornera 2 polos 5mm paso (220V AC) - 1 entrada + 7 salidas válvulas
[ ] 1x  Bornera 2 polos 3.5mm (salida SSR)
[ ] 1x  Conector DC barrel jack hembra 5.5x2.1mm (entrada 5V)
[ ] 1x  Header socket hembra 2x19 pines 2.54mm (montaje ESP32)
[ ] 1x  Header macho 4 pines 2.54mm (OLED I2C)
[ ] 1x  Header macho 3 pines 2.54mm (DS18B20)
```

---

## 🛡️ PROTECCIONES (3 items críticos)

```
[ ] 1x Fusible 5A rápido + portafusible PCB o DIN
[ ] 1x Varistor MOV 275V (protección sobretensión)
[ ] 1x Disipador térmico para SSR (si carga >10A)
```

---

## 🏗️ ESTRUCTURA Y MONTAJE (6 items)

```
[ ] 1x Gabinete plástico mínimo 20x15x8cm (IP20 o superior)
[ ] 1x PCB doble cara ~15x20cm O perfboard perforada
[ ] 10x Separadores nylon M3 10mm (montaje PCB)
[ ] 1x Set tornillos M3 (6mm y 10mm) + M2.5 (OLED)
[ ] 1x Prensa-estopa PG7 o PG9 (entrada cables)
[ ] 4x Taco adhesivo goma (pies gabinete)
```

---

## 🔗 CABLEADO (5 items)

```
[ ] 5m  Cable dupont macho-macho y macho-hembra (protoboard)
[ ] 3m  Cable sólido AWG 22 rojo/negro/amarillo (conexiones DC)
[ ] 3m  Cable flexible AWG 18 o 16 marrón/azul (conexiones AC 220V)
[ ] 1m  Tubo termocontráctil surtido (3mm, 5mm, 8mm diámetros)
[ ] 1   Rollo cinta aislante negra
```

---

## 🛠️ HERRAMIENTAS NECESARIAS (si no tienes)

```
[ ] Soldador eléctrico 30-60W punta fina
[ ] Estaño 60/40 con resina 0.8mm
[ ] Multímetro digital (voltaje AC/DC, continuidad)
[ ] Alicate corte diagonal
[ ] Alicate punta fina
[ ] Destornilladores plano + phillips (varios tamaños)
[ ] Pelacables ajustable AWG 22-16
[ ] Pinzas antiestáticas (opcional)
```

---

## 📦 OPCIONES DE COMPRA

### Opción A: Kit Completo (Recomendado para principiantes)
**Buscar "ESP32 kit electrónica" en Amazon/AliExpress que incluya:**
- ESP32 + breadboard + cables dupont + LEDs + resistencias + botones

**Comprar por separado:**
- OLED, DS18B20, SSR, MOC3021, TRIACs, electroválvulas

### Opción B: Componentes Individuales (Más económico)
**AliExpress / Amazon:**
- ESP32, OLED, DS18B20, fuente 5V

**Mouser / Digi-Key:**
- MOC3021, BTA16, resistencias, capacitores, borneras

**Proveedor industrial local:**
- Electroválvulas, SSR, gabinete, cable AC

---

## 💰 PRESUPUESTO ESTIMADO

| Categoría | Costo (USD) |
|-----------|-------------|
| **Componentes principales** | $130.00 |
| **Componentes pasivos** | $10.00 |
| **LEDs y botones** | $5.00 |
| **Conectores y borneras** | $8.00 |
| **Protecciones** | $6.00 |
| **Estructura y montaje** | $20.00 |
| **Cableado** | $5.00 |
| **TOTAL ESTIMADO** | **~$184.00** |

*Precios aproximados, varían según región y proveedor*

---

## ⚠️ VERIFICACIONES IMPORTANTES ANTES DE COMPRAR

```
✓ Electroválvulas: Voltaje correcto (110V US / 220V EU)
✓ Electroválvulas: Tipo de rosca compatible con instalación
✓ ESP32: Modelo con 38 pines (no compactos)
✓ OLED: Dirección I2C 0x3C (estándar)
✓ DS18B20: Con cable si necesitas instalación remota
✓ Fuente 5V: Mínimo 2A, recomendado 3A
✓ TRIACs: Corriente mínimo 10A (recomendado 16A)
✓ Gabinete: Espacio suficiente para todos los componentes
✓ Cable AC: Calibre apropiado para corriente de válvulas
```

---

## 📋 CANTIDADES RESUMEN

| Tipo | Cantidad Total |
|------|---------------|
| **Circuitos integrados** | 9 (1 ESP32 + 7 MOC + 1 sensor) |
| **Componentes potencia** | 8 (1 SSR + 7 TRIAC) |
| **Electroválvulas** | 7 |
| **Resistencias** | ~35 unidades |
| **Capacitores** | ~10 unidades |
| **LEDs** | 9 unidades |
| **Botones** | 7 unidades |
| **Conectores** | ~15 items |

---

## 🌐 ENLACES ÚTILES DE PROVEEDORES

### Internacional
- **AliExpress:** aliexpress.com (ESP32, OLED, sensores - envío 15-30 días)
- **Amazon:** amazon.com (kits rápidos - envío 1-3 días)
- **eBay:** ebay.com (componentes variados)

### Componentes Profesionales
- **Mouser:** mouser.com (stock amplio, datasheets completos)
- **Digi-Key:** digikey.com (envío rápido, calidad garantizada)
- **Newark:** newark.com (distribución Americas)
- **RS Components:** rs-online.com (Europa)

### PCB
- **JLCPCB:** jlcpcb.com (5 PCBs $2 USD + envío)
- **PCBWay:** pcbway.com (calidad premium)
- **Aisler:** aisler.net (Europa, pequeñas cantidades)

### Electroválvulas
- **Grainger:** grainger.com (industrial USA)
- **McMaster-Carr:** mcmaster.com (amplio catálogo)
- **Proveedores locales:** Plomería industrial

---

## 📞 TIPS DE COMPRA

1. **Compra por lotes:** Agrupa pedidos para ahorrar envío
2. **Verifica voltajes:** 110V vs 220V según tu país
3. **Stock local:** Busca proveedores electrónica cerca de ti
4. **Kits económicos:** A veces es más barato comprar kit de resistencias/capacitores
5. **Electroválvulas:** Verifica compatibilidad con fluido (agua/aire/gas)
6. **Tiempo entrega:** AliExpress tarda 2-4 semanas, Amazon 1-3 días
7. **Garantías:** Componentes principales con garantía del vendedor

---

## ✅ CHECKLIST FINAL

```
Antes de ordenar, tengo definido:

Hardware:
[ ] Cantidad exacta de electroválvulas (7 o menos)
[ ] Tipo de fluido a controlar (agua/aire/gas)
[ ] Presión de trabajo del sistema
[ ] Ubicación de instalación (interior/exterior)
[ ] Distancia entre ESP32 y electroválvulas

Eléctrico:
[ ] Voltaje de red disponible (110V/220V)
[ ] Punto de alimentación cercano
[ ] Carga total del sistema calculada
[ ] Necesidad de disipadores térmicos

Mecánico:
[ ] Espacio para gabinete disponible
[ ] Tipo de montaje (pared/riel DIN/mesa)
[ ] Necesidad de protección IP (polvo/agua)
[ ] Longitud de cables necesaria

Funcional:
[ ] Rango de temperatura a controlar
[ ] Precisión requerida
[ ] Tipo de control (manual/automático/ambos)
[ ] Necesidad de monitoreo remoto (Bluetooth/WiFi)
```

---

**Documento actualizado:** 2025-10-30
**Versión:** 2.0.0
**Tiempo estimado de ensamblaje:** 4-6 horas (con experiencia)
**Dificultad:** Media (requiere soldadura y conocimientos de AC)

**¡Buena suerte con tu proyecto!** 🚀
