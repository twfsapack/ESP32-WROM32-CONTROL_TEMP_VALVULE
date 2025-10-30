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
#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

// ========== CONFIGURACIÓN OLED ==========
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// ========== BOTONES ==========
#define BTN_UP       34
#define BTN_DOWN     35
#define BTN_NEXT     32
#define BTN_BACK     33
#define BTN_CONFIRM  25

// ========== SALIDAS ==========
#define SSR_PIN      26      // Relé SSR (control temperatura)
#define LED_SSR      27      // LED indicador del SSR
#define LED_SYSTEM   14      // LED sistema encendido

// LEDs de válvulas (uno por válvula)
int valveLEDs[7] = {4, 5, 18, 19, 21, 22, 23};

// Salidas de electroválvulas (optoacopladores/triacs)
int valvePins[7] = {2, 15, 13, 12, 27, 33, 25};

// ========== VARIABLES GLOBALES ==========
float setTemperature = 25.0;
float currentTemperature = 0.0;

bool relayState = false;
bool systemOn = true;

int valveTime[7] = {5, 5, 5, 5, 5, 5, 5}; // segundos
bool valveState[7] = {false, false, false, false, false, false, false};

// ========== MENÚ ==========
int menuIndex = 0;
int subMenuIndex = 0;
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

  pinMode(BTN_UP, INPUT_PULLUP);
  pinMode(BTN_DOWN, INPUT_PULLUP);
  pinMode(BTN_NEXT, INPUT_PULLUP);
  pinMode(BTN_BACK, INPUT_PULLUP);
  pinMode(BTN_CONFIRM, INPUT_PULLUP);

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
  readButtons();       // Lectura del menú
  controlTemperature(); // Control del SSR
  controlValves();     // Control de válvulas
  sendBluetoothData(); // Enviar datos a la app
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
      if (menuIndex == 0) setTemperature += 0.5;
      if (menuIndex == 1) valveTime[subMenuIndex] += 1;
    }
  }

  if (digitalRead(BTN_DOWN) == LOW) {
    lastButtonTime = currentMillis;
    if (!inSubMenu) {
      menuIndex++;
      if (menuIndex > 2) menuIndex = 0;
    } else {
      if (menuIndex == 0) setTemperature -= 0.5;
      if (menuIndex == 1 && valveTime[subMenuIndex] > 0) valveTime[subMenuIndex] -= 1;
    }
  }

  if (digitalRead(BTN_NEXT) == LOW) {
    lastButtonTime = currentMillis;
    if (!inSubMenu) {
      inSubMenu = true;
      subMenuIndex = 0;
    } else {
      subMenuIndex++;
      if (menuIndex == 1 && subMenuIndex > 6) subMenuIndex = 0;
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
    display.setCursor(0, 0);
    display.println("=== MENU PRINCIPAL ===");
    if (menuIndex == 0) display.println("> Control Temperatura");
    else display.println("  Control Temperatura");

    if (menuIndex == 1) display.println("> Electroválvulas");
    else display.println("  Electroválvulas");

    if (menuIndex == 2) display.println("> Estado del Sistema");
    else display.println("  Estado del Sistema");
  } else {
    if (menuIndex == 0) {
      display.setCursor(0, 0);
      display.println("Temperatura");
      display.print("Set: ");
      display.print(setTemperature);
      display.println(" °C");
    } else if (menuIndex == 1) {
      display.setCursor(0, 0);
      display.print("Valvula ");
      display.println(subMenuIndex + 1);
      display.print("Tiempo: ");
      display.print(valveTime[subMenuIndex]);
      display.println(" s");
    }
  }

  display.display();
}

// ==========================================================
//                    CONTROL DE TEMPERATURA
// ==========================================================
void controlTemperature() {
  // Simular lectura de sensor (aquí puedes usar DS18B20, DHT22, etc.)
  currentTemperature = 24.5 + random(-10, 10) / 10.0;

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
//                    DATOS POR BLUETOOTH
// ==========================================================
void sendBluetoothData() {
  static unsigned long lastSend = 0;
  if (millis() - lastSend > 1000) {
    lastSend = millis();
    String data = "TEMP:" + String(currentTemperature) +
                  ",SET:" + String(setTemperature) +
                  ",SSR:" + String(relayState) + ",";
    for (int i = 0; i < 7; i++) {
      data += "V" + String(i + 1) + ":" + String(valveState[i]) + ",";
    }
    SerialBT.println(data);
  }
}
