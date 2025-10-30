/*
  Sistema de Control de Temperatura y Electroválvulas
  ---------------------------------------------------
  - Control por menú (OLED + 5 botones)
  - 7 salidas independientes para válvulas (con control manual/temporizado)
  - Control de temperatura con relé SSR
  - Comunicación Bluetooth (para app Flutter)
  - Indicadores LED físicos
*/

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

// ========== CONFIGURACIÓN OLED ==========
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// ========== SENSOR DE TEMPERATURA DS18B20 ==========
#define ONE_WIRE_BUS 36  // Pin de datos del DS18B20 (GPIO 36 - SVP)
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// ========== BOTONES DE MENÚ ==========
#define BTN_UP       34
#define BTN_DOWN     35
#define BTN_NEXT     32
#define BTN_BACK     33
#define BTN_CONFIRM  25

// ========== ENTRADAS DE ACTIVACIÓN MANUAL DE VÁLVULAS ==========
// NOTA: Para implementar 7 entradas completas se recomienda usar
// un expansor I2C como PCF8574 o MCP23017 debido a limitaciones de GPIO
// Por ahora, implementamos 2 entradas de ejemplo con GPIOs disponibles:
#define VALVE_INPUT_0  39  // Entrada manual válvula 0 (GPIO 39 - input only)
#define VALVE_INPUT_1  37  // Entrada manual válvula 1 (GPIO 37 - input only)
// Para las demás válvulas (2-6) se requiere expansor I2C

bool valveInputState[7] = {false, false, false, false, false, false, false};
unsigned long valveInputDebounce[7] = {0, 0, 0, 0, 0, 0, 0};

// ========== SALIDAS ==========
#define SSR_PIN      26      // Relé SSR (control temperatura)
#define LED_SSR      27      // LED indicador del SSR
#define LED_SYSTEM   14      // LED sistema encendido

// LEDs de válvulas (uno por válvula)
int valveLEDs[7] = {4, 5, 18, 19, 21, 22, 23};

// Salidas de electroválvulas (optoacopladores/triacs)
// CORRECCIÓN: Pines reasignados para evitar conflictos con botones y LED_SSR
int valvePins[7] = {2, 15, 13, 12, 16, 17, 0};

// ========== VARIABLES GLOBALES ==========
float setTemperature = 25.0;
float currentTemperature = 0.0;

bool relayState = false;
bool systemOn = true;

int valveTime[7] = {5, 5, 5, 5, 5, 5, 5}; // segundos (duración)
int valveDelay[7] = {0, 0, 0, 0, 0, 0, 0}; // segundos (retardo antes de activar)
bool valveState[7] = {false, false, false, false, false, false, false};
bool valveEnabled[7] = {true, true, true, true, true, true, true};

// ========== MENÚ ==========
int menuIndex = 0;
int subMenuIndex = 0;
int valveParamIndex = 0; // 0=duración, 1=retardo
bool inSubMenu = false;
bool confirmChange = false;

// ========== ANTIRREBOTE ==========
unsigned long lastButtonTime = 0;
const unsigned long debounceDelay = 250;

// ========== TEMPORIZACIÓN ==========
unsigned long valveStartTime[7] = {0, 0, 0, 0, 0, 0, 0};

// ==========================================================
//                    SETUP PRINCIPAL
// ==========================================================
void setup() {
  Serial.begin(115200);
  SerialBT.begin("ESP32_TempControl");

  // Configurar botones de menú
  pinMode(BTN_UP, INPUT_PULLUP);
  pinMode(BTN_DOWN, INPUT_PULLUP);
  pinMode(BTN_NEXT, INPUT_PULLUP);
  pinMode(BTN_BACK, INPUT_PULLUP);
  pinMode(BTN_CONFIRM, INPUT_PULLUP);

  // Configurar entradas manuales de válvulas
  pinMode(VALVE_INPUT_0, INPUT_PULLUP);
  pinMode(VALVE_INPUT_1, INPUT_PULLUP);

  pinMode(SSR_PIN, OUTPUT);
  pinMode(LED_SSR, OUTPUT);
  pinMode(LED_SYSTEM, OUTPUT);

  for (int i = 0; i < 7; i++) {
    pinMode(valvePins[i], OUTPUT);
    pinMode(valveLEDs[i], OUTPUT);
    digitalWrite(valvePins[i], LOW);
    digitalWrite(valveLEDs[i], LOW);
  }

  digitalWrite(LED_SYSTEM, HIGH); // Indica que el sistema está activo

  // Inicializar sensor de temperatura
  sensors.begin();
  sensors.setResolution(12); // Resolución 12 bits (0.0625°C)
  Serial.println("Sensor DS18B20 inicializado");

  // Inicializar pantalla
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("Error al inicializar OLED");
    while (1);
  }
  display.clearDisplay();
  display.display();
}

// ==========================================================
//                    LOOP PRINCIPAL
// ==========================================================
void loop() {
  readButtons();              // Lectura del menú
  readValveInputs();          // Lectura de entradas manuales de válvulas
  controlTemperature();       // Control del SSR
  controlValves();            // Control de válvulas
  receiveBluetoothCommands(); // Recibir comandos de la app
  sendBluetoothData();        // Enviar datos a la app
}

// ==========================================================
//                    LECTURA DE BOTONES
// ==========================================================
void readButtons() {
  unsigned long currentMillis = millis();
  if (currentMillis - lastButtonTime < debounceDelay) return;

  if (digitalRead(BTN_UP) == LOW) {
    lastButtonTime = currentMillis;
    if (!inSubMenu) {
      menuIndex--;
      if (menuIndex < 0) menuIndex = 2;
    } else {
      if (menuIndex == 0) {
        // Ajustar temperatura
        setTemperature += 0.5;
      } else if (menuIndex == 1) {
        // Ajustar parámetro de válvula
        if (valveParamIndex == 0) valveTime[subMenuIndex] += 1;
        else if (valveParamIndex == 1) valveDelay[subMenuIndex] += 1;
      }
    }
  }

  if (digitalRead(BTN_DOWN) == LOW) {
    lastButtonTime = currentMillis;
    if (!inSubMenu) {
      menuIndex++;
      if (menuIndex > 2) menuIndex = 0;
    } else {
      if (menuIndex == 0) {
        // Ajustar temperatura
        if (setTemperature > 0) setTemperature -= 0.5;
      } else if (menuIndex == 1) {
        // Ajustar parámetro de válvula
        if (valveParamIndex == 0 && valveTime[subMenuIndex] > 1) valveTime[subMenuIndex] -= 1;
        else if (valveParamIndex == 1 && valveDelay[subMenuIndex] > 0) valveDelay[subMenuIndex] -= 1;
      }
    }
  }

  if (digitalRead(BTN_NEXT) == LOW) {
    lastButtonTime = currentMillis;
    if (!inSubMenu) {
      inSubMenu = true;
      subMenuIndex = 0;
      valveParamIndex = 0;
    } else {
      if (menuIndex == 1) {
        // En menú de válvulas: cambiar entre válvulas o parámetros
        valveParamIndex++;
        if (valveParamIndex > 1) {
          valveParamIndex = 0;
          subMenuIndex++;
          if (subMenuIndex > 6) subMenuIndex = 0;
        }
      }
    }
  }

  if (digitalRead(BTN_BACK) == LOW) {
    lastButtonTime = currentMillis;
    if (inSubMenu) inSubMenu = false;
    else menuIndex = 0;
  }

  if (digitalRead(BTN_CONFIRM) == LOW) {
    lastButtonTime = currentMillis;
    confirmChange = true;
    Serial.println("Cambios confirmados");
  }

  showMenu();
}

// ==========================================================
//                    MOSTRAR EN OLED
// ==========================================================
void showMenu() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  if (!inSubMenu) {
    // ===== MENÚ PRINCIPAL =====
    display.setCursor(0, 0);
    display.println("=== MENU PRINCIPAL ===");

    // Opción 1: Control Temperatura
    if (menuIndex == 0) display.print(">");
    else display.print(" ");
    display.println(" Control Temp");

    // Opción 2: Electroválvulas
    if (menuIndex == 1) display.print(">");
    else display.print(" ");
    display.println(" Electrovalvulas");

    // Opción 3: Estado del Sistema
    if (menuIndex == 2) display.print(">");
    else display.print(" ");
    display.println(" Estado Sistema");

    // Mostrar información rápida en la parte inferior
    display.setCursor(0, 48);
    display.print("T:");
    display.print(currentTemperature, 1);
    display.print("C ");
    if (relayState) display.print("[SSR:ON]");
    else display.print("[SSR:--]");

  } else {
    // ===== SUBMENÚS =====
    if (menuIndex == 0) {
      // Submenú: Control de Temperatura
      display.setCursor(0, 0);
      display.println("--- TEMPERATURA ---");
      display.println();
      display.print("Actual: ");
      display.print(currentTemperature, 1);
      display.println(" C");
      display.print("Objetivo: ");
      display.print(setTemperature, 1);
      display.println(" C");
      display.println();
      display.print("SSR: ");
      if (relayState) display.println("ENCENDIDO");
      else display.println("APAGADO");
      display.println();
      display.println("UP/DOWN: ajustar");

    } else if (menuIndex == 1) {
      // Submenú: Electroválvulas
      display.setCursor(0, 0);
      display.print("-- VALVULA ");
      display.print(subMenuIndex + 1);
      display.println(" --");
      display.println();

      // Mostrar duración con indicador de selección
      if (valveParamIndex == 0) display.print(">");
      else display.print(" ");
      display.print("Duracion: ");
      display.print(valveTime[subMenuIndex]);
      display.println(" s");

      // Mostrar retardo con indicador de selección
      if (valveParamIndex == 1) display.print(">");
      else display.print(" ");
      display.print("Retardo: ");
      display.print(valveDelay[subMenuIndex]);
      display.println(" s");

      display.print("Estado: ");
      if (valveState[subMenuIndex]) display.println("ACTIVA");
      else display.println("INACTIVA");
      display.print("Habilitada: ");
      if (valveEnabled[subMenuIndex]) display.println("SI");
      else display.println("NO");

    } else if (menuIndex == 2) {
      // Submenú: Estado del Sistema
      display.setCursor(0, 0);
      display.println("-- ESTADO --");
      display.println();
      display.print("Temp: ");
      display.print(currentTemperature, 1);
      display.print("C/");
      display.print(setTemperature, 1);
      display.println("C");
      display.print("SSR: ");
      display.println(relayState ? "ON" : "OFF");

      // Mostrar válvulas activas
      int activeValves = 0;
      for (int i = 0; i < 7; i++) {
        if (valveState[i]) activeValves++;
      }
      display.print("Valvulas: ");
      display.print(activeValves);
      display.println("/7 ON");

      display.println();
      display.println("BT: Conectado");
    }
  }

  display.display();
}

// ==========================================================
//                    CONTROL DE TEMPERATURA
// ==========================================================
void controlTemperature() {
  // Leer temperatura del sensor DS18B20
  static unsigned long lastRead = 0;
  if (millis() - lastRead >= 1000) { // Leer cada 1 segundo
    lastRead = millis();
    sensors.requestTemperatures();
    float tempC = sensors.getTempCByIndex(0);

    // Verificar si la lectura es válida
    if (tempC != DEVICE_DISCONNECTED_C && tempC > -50 && tempC < 125) {
      currentTemperature = tempC;
    } else {
      Serial.println("Error al leer sensor DS18B20");
    }
  }

  // Control ON/OFF con histéresis
  if (currentTemperature < setTemperature - 0.5) {
    digitalWrite(SSR_PIN, HIGH);
    digitalWrite(LED_SSR, HIGH);
    relayState = true;
  } else if (currentTemperature > setTemperature + 0.5) {
    digitalWrite(SSR_PIN, LOW);
    digitalWrite(LED_SSR, LOW);
    relayState = false;
  }
}

// ==========================================================
//                    LECTURA DE ENTRADAS MANUALES
// ==========================================================
void readValveInputs() {
  unsigned long currentTime = millis();
  const unsigned long debounce = 50; // 50ms debounce

  // Leer entrada manual válvula 0
  if (currentTime - valveInputDebounce[0] > debounce) {
    bool currentState = !digitalRead(VALVE_INPUT_0); // Invertido por pull-up
    if (currentState && !valveInputState[0] && valveEnabled[0]) {
      // Flanco ascendente detectado - activar válvula
      valveState[0] = true;
      valveStartTime[0] = millis() + (valveDelay[0] * 1000); // Aplicar delay
      digitalWrite(valvePins[0], HIGH);
      digitalWrite(valveLEDs[0], HIGH);
      Serial.println("Válvula 0 activada manualmente");
    }
    valveInputState[0] = currentState;
    valveInputDebounce[0] = currentTime;
  }

  // Leer entrada manual válvula 1
  if (currentTime - valveInputDebounce[1] > debounce) {
    bool currentState = !digitalRead(VALVE_INPUT_1); // Invertido por pull-up
    if (currentState && !valveInputState[1] && valveEnabled[1]) {
      // Flanco ascendente detectado - activar válvula
      valveState[1] = true;
      valveStartTime[1] = millis() + (valveDelay[1] * 1000); // Aplicar delay
      digitalWrite(valvePins[1], HIGH);
      digitalWrite(valveLEDs[1], HIGH);
      Serial.println("Válvula 1 activada manualmente");
    }
    valveInputState[1] = currentState;
    valveInputDebounce[1] = currentTime;
  }

  // TODO: Implementar lectura de válvulas 2-6 usando expansor I2C
}

// ==========================================================
//                    CONTROL DE VALVULAS
// ==========================================================
void controlValves() {
  for (int i = 0; i < 7; i++) {
    if (valveState[i]) {
      if (millis() - valveStartTime[i] >= (valveTime[i] * 1000)) {
        valveState[i] = false;
        digitalWrite(valvePins[i], LOW);
        digitalWrite(valveLEDs[i], LOW);
      }
    }
  }
}

// ==========================================================
//                    RECEPCIÓN DE COMANDOS BLUETOOTH
// ==========================================================
void receiveBluetoothCommands() {
  if (SerialBT.available()) {
    String command = SerialBT.readStringUntil('\n');
    command.trim();

    Serial.println("Comando recibido: " + command);

    // Procesar comandos
    if (command == "GET_STATUS") {
      // Enviar estado inmediatamente
      sendBluetoothData();
    }
    else if (command == "PING") {
      SerialBT.println("PONG");
    }
    else if (command == "CONFIRM") {
      confirmChange = true;
      SerialBT.println("OK");
    }
    else if (command.startsWith("SET_TEMP=")) {
      float newTemp = command.substring(9).toFloat();
      if (newTemp >= 0 && newTemp <= 100) {
        setTemperature = newTemp;
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Temperature out of range");
      }
    }
    else if (command.startsWith("START_VALVE=")) {
      int valveNum = command.substring(12).toInt();
      if (valveNum >= 0 && valveNum < 7 && valveEnabled[valveNum]) {
        valveState[valveNum] = true;
        valveStartTime[valveNum] = millis();
        digitalWrite(valvePins[valveNum], HIGH);
        digitalWrite(valveLEDs[valveNum], HIGH);
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Invalid valve or disabled");
      }
    }
    else if (command.startsWith("STOP_VALVE=")) {
      int valveNum = command.substring(11).toInt();
      if (valveNum >= 0 && valveNum < 7) {
        valveState[valveNum] = false;
        digitalWrite(valvePins[valveNum], LOW);
        digitalWrite(valveLEDs[valveNum], LOW);
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Invalid valve");
      }
    }
    else if (command.startsWith("SET_VALVE_") && command.indexOf("_DELAY=") > 0) {
      int valveNum = command.substring(10, command.indexOf("_DELAY=")).toInt();
      int delayValue = command.substring(command.indexOf("=") + 1).toInt();
      if (valveNum >= 0 && valveNum < 7 && delayValue >= 0) {
        valveDelay[valveNum] = delayValue;
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Invalid parameters");
      }
    }
    else if (command.startsWith("SET_VALVE_") && command.indexOf("_TIME=") > 0) {
      int valveNum = command.substring(10, command.indexOf("_TIME=")).toInt();
      int timeValue = command.substring(command.indexOf("=") + 1).toInt();
      if (valveNum >= 0 && valveNum < 7 && timeValue > 0) {
        valveTime[valveNum] = timeValue;
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Invalid parameters");
      }
    }
    else if (command.startsWith("ENABLE_VALVE_") && command.indexOf("=") > 0) {
      int valveNum = command.substring(13, command.indexOf("=")).toInt();
      int enableValue = command.substring(command.indexOf("=") + 1).toInt();
      if (valveNum >= 0 && valveNum < 7) {
        valveEnabled[valveNum] = (enableValue == 1);
        SerialBT.println("OK");
      } else {
        SerialBT.println("ERROR: Invalid valve");
      }
    }
    else {
      SerialBT.println("ERROR: Unknown command");
    }
  }
}

// ==========================================================
//                    ENVÍO DE DATOS POR BLUETOOTH
// ==========================================================
void sendBluetoothData() {
  static unsigned long lastSend = 0;
  if (millis() - lastSend > 1000) {
    lastSend = millis();

    // Formato: TEMP_ACT=24.5;TEMP_SET=25.0;RELE=ON;VALVE0=ON,0,5,1;...
    String data = "TEMP_ACT=" + String(currentTemperature, 1) + ";";
    data += "TEMP_SET=" + String(setTemperature, 1) + ";";
    data += "RELE=" + String(relayState ? "ON" : "OFF") + ";";

    for (int i = 0; i < 7; i++) {
      data += "VALVE" + String(i) + "=";
      data += String(valveState[i] ? "ON" : "OFF") + ",";
      data += String(valveDelay[i]) + ",";
      data += String(valveTime[i]) + ",";
      data += String(valveEnabled[i] ? "1" : "0");
      if (i < 6) data += ";";
    }

    SerialBT.println(data);
  }
}
