// Bluetooth Service - Servicio de comunicación con ESP32 v2.0.0
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Instancia de Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Conexión actual
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  // Stream controllers
  final _connectionController = StreamController<bool>.broadcast();
  final _dataController = StreamController<ESP32Data>.broadcast();
  final _logController = StreamController<String>.broadcast();

  // Buffer para datos recibidos
  String _rxBuffer = '';

  // Getters
  bool get isConnected => _connection != null && _connection!.isConnected;
  String? get connectedDeviceName => _connectedDevice?.name;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<ESP32Data> get dataStream => _dataController.stream;
  Stream<String> get logStream => _logController.stream;

  // ==================================================================
  //                     CONEXIÓN Y DESCONEXIÓN
  // ==================================================================

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _log('Conectando a ${device.name ?? device.address}...');

      // Desconectar conexión previa si existe
      if (_connection != null) {
        await disconnect();
      }

      // Establecer nueva conexión
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;

      _log('Conectado exitosamente a ${device.name ?? device.address}');
      _connectionController.add(true);

      // Escuchar datos entrantes
      _connection!.input!.listen(
        _onDataReceived,
        onDone: () {
          _log('Conexión cerrada');
          _handleDisconnect();
        },
        onError: (error) {
          _log('Error en conexión: $error');
          _handleDisconnect();
        },
      );

      // Solicitar estado inicial
      await Future.delayed(const Duration(milliseconds: 500));
      send('GET_STATUS');

      return true;
    } catch (e) {
      _log('Error al conectar: $e');
      _connectionController.add(false);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _log('Desconectando...');
      await _connection?.close();
      _connection = null;
      _connectedDevice = null;
      _connectionController.add(false);
      _log('Desconectado');
    } catch (e) {
      _log('Error al desconectar: $e');
    }
  }

  void _handleDisconnect() {
    _connection = null;
    _connectedDevice = null;
    _connectionController.add(false);
  }

  // ==================================================================
  //                     ENVÍO DE COMANDOS
  // ==================================================================

  void send(String command) {
    if (!isConnected) {
      _log('No conectado - no se puede enviar: $command');
      return;
    }

    try {
      _connection!.output.add(utf8.encode('$command\n'));
      _log('TX: $command');
    } catch (e) {
      _log('Error al enviar: $e');
    }
  }

  // Comandos específicos del firmware v2.0.0
  void setTemperature(double temp) => send('SET_TEMP=${temp.toStringAsFixed(1)}');
  void startValve(int index) => send('START_VALVE=$index');
  void stopValve(int index) => send('STOP_VALVE=$index');
  void setValveDelay(int index, int delay) => send('SET_VALVE_${index}_DELAY=$delay');
  void setValveTime(int index, int time) => send('SET_VALVE_${index}_TIME=$time');
  void enableValve(int index, bool enabled) => send('ENABLE_VALVE_$index=${enabled ? 1 : 0}');
  void confirm() => send('CONFIRM');
  void ping() => send('PING');
  void getStatus() => send('GET_STATUS');

  // ==================================================================
  //                     RECEPCIÓN Y PARSEO DE DATOS
  // ==================================================================

  void _onDataReceived(Uint8List data) {
    try {
      final str = utf8.decode(data, allowMalformed: true);
      _rxBuffer += str;

      // Procesar líneas completas
      int idx;
      while ((idx = _rxBuffer.indexOf('\n')) >= 0) {
        final line = _rxBuffer.substring(0, idx).trim();
        _rxBuffer = _rxBuffer.substring(idx + 1);

        if (line.isNotEmpty) {
          _processLine(line);
        }
      }
    } catch (e) {
      _log('Error al procesar datos: $e');
    }
  }

  void _processLine(String line) {
    _log('RX: $line');

    try {
      // Parsear respuesta según protocolo v2.0.0
      // Formato: TEMP_ACT=24.5;TEMP_SET=25.0;RELE=ON;VALVE0=ON,0,5,1;...

      final data = ESP32Data();
      final parts = line.split(';');

      for (final part in parts) {
        if (part.isEmpty) continue;

        final keyValue = part.split('=');
        if (keyValue.length < 2) continue;

        final key = keyValue[0].trim();
        final value = keyValue.sublist(1).join('=').trim();

        switch (key) {
          case 'TEMP_ACT':
            data.currentTemp = double.tryParse(value);
            break;

          case 'TEMP_SET':
            data.setTemp = double.tryParse(value);
            break;

          case 'RELE':
            data.relayOn = value.toUpperCase() == 'ON';
            break;

          default:
            if (key.startsWith('VALVE')) {
              final indexStr = key.substring(5);
              final index = int.tryParse(indexStr);

              if (index != null && index >= 0 && index < 7) {
                final valveParts = value.split(',');
                if (valveParts.length >= 4) {
                  data.valveStates[index] = valveParts[0] == 'ON';
                  data.valveDelays[index] = int.tryParse(valveParts[1]) ?? 0;
                  data.valveTimes[index] = int.tryParse(valveParts[2]) ?? 0;
                  data.valveEnabled[index] = valveParts[3] == '1';
                }
              }
            }
            break;
        }
      }

      // Emitir datos parseados
      _dataController.add(data);
    } catch (e) {
      _log('Error al parsear línea: $e');
    }
  }

  // ==================================================================
  //                     ESCANEO DE DISPOSITIVOS
  // ==================================================================

  Future<List<BluetoothDevice>> getDevicesList() async {
    try {
      // Obtener dispositivos emparejados
      final bondedDevices = await _bluetooth.getBondedDevices();
      return bondedDevices;
    } catch (e) {
      _log('Error al obtener dispositivos: $e');
      return [];
    }
  }

  Stream<BluetoothDiscoveryResult> startDiscovery() {
    _log('Iniciando escaneo de dispositivos...');
    return _bluetooth.startDiscovery();
  }

  Future<void> cancelDiscovery() async {
    try {
      await _bluetooth.cancelDiscovery();
      _log('Escaneo cancelado');
    } catch (e) {
      _log('Error al cancelar escaneo: $e');
    }
  }

  // ==================================================================
  //                     LOGGING
  // ==================================================================

  void _log(String message) {
    final timestamp = DateTime.now();
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    _logController.add('[$formattedTime] $message');
  }

  // ==================================================================
  //                     DISPOSE
  // ==================================================================

  void dispose() {
    _connection?.close();
    _connectionController.close();
    _dataController.close();
    _logController.close();
  }
}

// ==================================================================
//                     CLASE DE DATOS ESP32
// ==================================================================

class ESP32Data {
  double? currentTemp;
  double? setTemp;
  bool relayOn = false;

  final List<bool> valveStates = List.filled(7, false);
  final List<int> valveDelays = List.filled(7, 0);
  final List<int> valveTimes = List.filled(7, 0);
  final List<bool> valveEnabled = List.filled(7, true);

  ESP32Data();

  @override
  String toString() {
    return 'ESP32Data(temp: $currentTemp/$setTemp°C, relay: $relayOn, valves: $valveStates)';
  }
}
