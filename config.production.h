/**
 * Archivo de Configuración de Producción
 * TWF ESP32 Control v2.0.0
 *
 * Este archivo contiene todas las configuraciones para el entorno de producción.
 * Copia este archivo y renómbralo a "config.h" antes de compilar.
 */

#ifndef CONFIG_PRODUCTION_H
#define CONFIG_PRODUCTION_H

// ============================================
// INFORMACIÓN DEL SISTEMA
// ============================================
#define FIRMWARE_VERSION "2.0.0"
#define FIRMWARE_DATE "2025-10-31"
#define DEVICE_NAME "TWF_ESP32_Control"

// ============================================
// CONFIGURACIÓN BLUETOOTH
// ============================================
#define BT_DEVICE_NAME "ESP32_TempControl"  // Nombre visible en dispositivos
#define BT_PIN_CODE "1234"                   // PIN de emparejamiento (si se requiere)
#define BT_SERIAL_BAUD 115200                // Velocidad

// ============================================
// CONFIGURACIÓN DE TEMPERATURA
// ============================================
#define TEMP_MIN 0.0                         // Temperatura mínima (°C)
#define TEMP_MAX 100.0                       // Temperatura máxima (°C)
#define TEMP_DEFAULT 25.0                    // Temperatura por defecto (°C)
#define TEMP_CALIBRATION_OFFSET 0.0          // Offset de calibración (±5.0°C)
#define TEMP_READ_INTERVAL 2000              // Intervalo de lectura (ms)
#define TEMP_HYSTERESIS 1.0                  // Histéresis del control (°C)

// ============================================
// CONFIGURACIÓN SSR (Solid State Relay)
// ============================================
#define SSR_LOGIC_INVERTED false             // true = lógica invertida (ON=LOW)
#define SSR_MIN_ON_TIME 1000                 // Tiempo mínimo encendido (ms)
#define SSR_MIN_OFF_TIME 1000                // Tiempo mínimo apagado (ms)

// ============================================
// CONFIGURACIÓN DE VÁLVULAS
// ============================================
#define NUM_VALVES 7                         // Número de electroválvulas
#define VALVE_DELAY_MIN 0                    // Retardo mínimo (segundos)
#define VALVE_DELAY_MAX 60                   // Retardo máximo (segundos)
#define VALVE_TIME_MIN 1                     // Duración mínima (segundos)
#define VALVE_TIME_MAX 300                   // Duración máxima (5 minutos)

// Valores por defecto para válvulas
#define VALVE_DEFAULT_DELAY 0                // Retardo por defecto (s)
#define VALVE_DEFAULT_TIME 5                 // Duración por defecto (s)
#define VALVE_DEFAULT_ENABLED true           // Habilitadas por defecto

// ============================================
// CONFIGURACIÓN DISPLAY OLED
// ============================================
#define OLED_WIDTH 128                       // Ancho en pixeles
#define OLED_HEIGHT 64                       // Alto en pixeles
#define OLED_I2C_ADDRESS 0x3C                // Dirección I2C (probar 0x3D si no funciona)
#define OLED_REFRESH_RATE 30                 // FPS de actualización
#define OLED_TEXT_SIZE 1                     // Tamaño de texto por defecto

// ============================================
// CONFIGURACIÓN DE PINES GPIO
// ============================================

// Sensor de temperatura DS18B20
#define ONE_WIRE_BUS 36                      // GPIO36 (ADC1_CH0)

// SSR Control
#define RELAY_PIN 26                         // GPIO26 (DAC2)

// Display OLED I2C
#define OLED_SDA 21                          // GPIO21 (SDA)
#define OLED_SCL 22                          // GPIO22 (SCL)

// Botones de control
#define BUTTON_UP 39                         // GPIO39 (VN - Input only)
#define BUTTON_DOWN 37                       // GPIO37 (No disponible en algunos modelos)
#define BUTTON_SELECT 27                     // GPIO27

// Electroválvulas (salidas digitales)
const int VALVE_PINS[NUM_VALVES] = {
    2,   // Válvula 1 - GPIO2
    15,  // Válvula 2 - GPIO15
    13,  // Válvula 3 - GPIO13
    12,  // Válvula 4 - GPIO12
    16,  // Válvula 5 - GPIO16 (RX2)
    17,  // Válvula 6 - GPIO17 (TX2)
    0    // Válvula 7 - GPIO0 (BOOT - usar con precaución)
};

// ============================================
// CONFIGURACIÓN DE SEGURIDAD
// ============================================
#define WATCHDOG_TIMEOUT 8000                // Timeout del watchdog (ms)
#define MAX_COMMAND_LENGTH 128               // Longitud máxima de comando BT
#define COMMAND_TIMEOUT 5000                 // Timeout para comandos (ms)
#define SAFETY_TEMP_MAX 95.0                 // Temperatura de seguridad máxima
#define SAFETY_SHUTDOWN_ENABLE true          // Habilitar apagado de seguridad

// ============================================
// CONFIGURACIÓN DE DEBUG
// ============================================
#define DEBUG_MODE false                     // Habilitar mensajes de debug
#define SERIAL_DEBUG_BAUD 115200             // Velocidad Serial debug
#define DEBUG_VERBOSE false                  // Debug verbose (más detalle)

// ============================================
// CONFIGURACIÓN DE PERSISTENCIA
// ============================================
#define EEPROM_SIZE 512                      // Tamaño EEPROM (bytes)
#define SAVE_CONFIG_ON_CHANGE true           // Guardar config automáticamente
#define CONFIG_SAVE_DELAY 5000               // Delay antes de guardar (ms)

// ============================================
// TIMEOUTS Y TIEMPOS
// ============================================
#define BT_CONNECTION_TIMEOUT 30000          // Timeout conexión BT (ms)
#define SENSOR_READ_TIMEOUT 2000             // Timeout lectura sensor (ms)
#define DISPLAY_UPDATE_INTERVAL 100          // Actualización display (ms)
#define STATUS_SEND_INTERVAL 1000            // Envío de estado por BT (ms)
#define BUTTON_DEBOUNCE_TIME 50              // Debounce de botones (ms)

// ============================================
// CONFIGURACIÓN DE LEDS INDICADORES
// ============================================
#define LED_BUILTIN 2                        // LED integrado del ESP32
#define LED_INDICATE_BT true                 // Usar LED para indicar BT
#define LED_INDICATE_ERROR true              // Usar LED para indicar errores
#define LED_BLINK_INTERVAL 500               // Intervalo de parpadeo (ms)

// ============================================
// CONFIGURACIÓN DE PROTOCOLO BLUETOOTH
// ============================================
#define BT_DATA_SEPARATOR ";"                // Separador de datos
#define BT_KEY_VALUE_SEPARATOR "="           // Separador clave=valor
#define BT_COMMAND_PREFIX ""                 // Prefijo de comandos (opcional)
#define BT_SEND_CHECKSUM false               // Enviar checksum (CRC)

// ============================================
// CONFIGURACIÓN DE NOTIFICACIONES
// ============================================
#define ENABLE_SOUND false                   // Buzzer para notificaciones
#define BUZZER_PIN -1                        // GPIO del buzzer (si aplica)
#define BUZZER_FREQUENCY 2000                // Frecuencia del buzzer (Hz)

// ============================================
// OPTIMIZACIONES
// ============================================
#define USE_HARDWARE_TIMERS true             // Usar timers por hardware
#define OPTIMIZE_POWER false                 // Optimizar consumo de energía
#define WIFI_DISABLED true                   // Deshabilitar WiFi para ahorrar energía

// ============================================
// FEATURES OPCIONALES
// ============================================
#define FEATURE_WEB_SERVER false             // Servidor web (requiere WiFi)
#define FEATURE_OTA_UPDATES false            // Actualizaciones OTA
#define FEATURE_SD_LOGGING false             // Logging a SD card
#define FEATURE_NTP_TIME false               // Sincronización de tiempo NTP

// ============================================
// VALIDACIONES
// ============================================
#if TEMP_MIN >= TEMP_MAX
    #error "TEMP_MIN debe ser menor que TEMP_MAX"
#endif

#if TEMP_DEFAULT < TEMP_MIN || TEMP_DEFAULT > TEMP_MAX
    #error "TEMP_DEFAULT fuera de rango"
#endif

#if NUM_VALVES > 10
    #error "NUM_VALVES no puede ser mayor a 10"
#endif

#if VALVE_DELAY_MAX > 300
    #warning "VALVE_DELAY_MAX muy alto, podría causar problemas"
#endif

// ============================================
// MACROS DE UTILIDAD
// ============================================
#define DEBUG_PRINT(x) if(DEBUG_MODE) Serial.print(x)
#define DEBUG_PRINTLN(x) if(DEBUG_MODE) Serial.println(x)
#define DEBUG_PRINTF(format, ...) if(DEBUG_MODE) Serial.printf(format, ##__VA_ARGS__)

// ============================================
// INFORMACIÓN DE BUILD
// ============================================
#define BUILD_DATE __DATE__
#define BUILD_TIME __TIME__
#define COMPILER_VERSION __VERSION__

#endif // CONFIG_PRODUCTION_H

/**
 * NOTAS IMPORTANTES:
 *
 * 1. GPIO0 (Válvula 7): Este GPIO se usa para entrar en modo bootloader.
 *    No conectar dispositivos que lo mantengan en LOW durante el inicio.
 *
 * 2. GPIO36 y 39: Son input-only, no se pueden usar como salidas.
 *
 * 3. I2C: Si el OLED no funciona con 0x3C, probar con 0x3D.
 *
 * 4. SSR: Si la lógica está invertida (enciende cuando debería apagar),
 *    cambiar SSR_LOGIC_INVERTED a true.
 *
 * 5. Calibración: Si la temperatura lee incorrectamente, ajustar
 *    TEMP_CALIBRATION_OFFSET (valores negativos o positivos).
 *
 * 6. Seguridad: SAFETY_TEMP_MAX actúa como límite de seguridad.
 *    Si se alcanza, el SSR se apagará automáticamente.
 *
 * 7. Debug: Habilitar DEBUG_MODE solo durante desarrollo.
 *    En producción debe estar en false para mejor rendimiento.
 *
 * 8. Persistencia: Las configuraciones se guardan en EEPROM.
 *    Sobreviven a reinicios pero no a reflash del firmware.
 */
