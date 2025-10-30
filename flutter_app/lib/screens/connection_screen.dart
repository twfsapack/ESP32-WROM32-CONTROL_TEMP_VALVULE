// Connection Screen - Pantalla de selección y conexión de dispositivos
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';

class ConnectionScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const ConnectionScreen({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _selectedDeviceAddress;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await widget.bluetoothService.getDevicesList();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      widget.bluetoothService.startDiscovery().listen(
        (result) {
          final device = result.device;
          if (!_devices.any((d) => d.address == device.address)) {
            setState(() {
              _devices.add(device);
            });
          }
        },
        onDone: () {
          setState(() {
            _isScanning = false;
          });
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en escaneo: $error')),
            );
          }
          setState(() {
            _isScanning = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _cancelDiscovery() async {
    await widget.bluetoothService.cancelDiscovery();
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _selectedDeviceAddress = device.address;
    });

    try {
      final success = await widget.bluetoothService.connect(device);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conectado a ${device.name ?? device.address}'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver al menú principal con éxito
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _selectedDeviceAddress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar Dispositivo'),
        actions: [
          if (_isScanning)
            IconButton(
              onPressed: _cancelDiscovery,
              icon: const Icon(Icons.stop),
              tooltip: 'Detener escaneo',
            )
          else
            IconButton(
              onPressed: _startDiscovery,
              icon: const Icon(Icons.refresh),
              tooltip: 'Buscar dispositivos',
            ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de escaneo
          if (_isScanning)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Buscando dispositivos...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

          // Banner informativo
          if (_devices.isEmpty && !_isScanning)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay dispositivos disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toca el ícono de actualizar para buscar dispositivos',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Lista de dispositivos
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _devices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isConnecting = _isConnecting &&
                    _selectedDeviceAddress == device.address;

                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bluetooth,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      device.name ?? 'Dispositivo desconocido',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(device.address),
                    trailing: isConnecting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: isConnecting ? null : () => _connectToDevice(device),
                  ),
                );
              },
            ),
          ),

          // Instrucciones en la parte inferior
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Busca "ESP32_TempControl" en la lista',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
