// Valves Screen - Pantalla de control de electroválvulas (placeholder)
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class ValvesScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const ValvesScreen({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<ValvesScreen> createState() => _ValvesScreenState();
}

class _ValvesScreenState extends State<ValvesScreen> {
  ESP32Data? _latestData;

  @override
  void initState() {
    super.initState();
    // Escuchar datos del ESP32
    widget.bluetoothService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestData = data;
        });
      }
    });

    // Solicitar estado actual
    widget.bluetoothService.getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Electroválvulas'),
        actions: [
          IconButton(
            onPressed: () => widget.bluetoothService.getStatus(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 Electroválvulas AC',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Control independiente con temporización',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lista de válvulas
          ...List.generate(7, (index) {
            final isActive = _latestData?.valveStates[index] ?? false;
            final isEnabled = _latestData?.valveEnabled[index] ?? true;
            final delay = _latestData?.valveDelays[index] ?? 0;
            final time = _latestData?.valveTimes[index] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Válvula ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: isActive ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        const Spacer(),
                        Icon(
                          isEnabled ? Icons.check_circle : Icons.cancel,
                          color: isEnabled ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Retardo: ${delay}s',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Duración: ${time}s',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isEnabled
                              ? () => widget.bluetoothService.startValve(index)
                              : null,
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Iniciar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: isEnabled
                              ? () => widget.bluetoothService.stopValve(index)
                              : null,
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text('Detener'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Nota informativa
          Card(
            color: Colors.amber.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pantalla en desarrollo\n'
                      'Configuración de parámetros próximamente',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
