// Temperature Screen - Pantalla de control de temperatura (placeholder)
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class TemperatureScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const TemperatureScreen({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
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
        title: const Text('Control de Temperatura'),
        actions: [
          IconButton(
            onPressed: () => widget.bluetoothService.getStatus(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Control de Temperatura',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Temperatura Actual',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latestData?.currentTemp != null
                            ? '${_latestData!.currentTemp!.toStringAsFixed(1)}°C'
                            : '--°C',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 40),
                      Text(
                        'Temperatura Objetivo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latestData?.setTemp != null
                            ? '${_latestData!.setTemp!.toStringAsFixed(1)}°C'
                            : '--°C',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SSR:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _latestData?.relayOn == true
                                ? Icons.power
                                : Icons.power_off,
                            color: _latestData?.relayOn == true
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Pantalla en desarrollo\nMás funciones próximamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
