// Menu Screen - Pantalla Principal con Menú
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import 'temperature_screen.dart';
import 'valves_screen.dart';
import 'connection_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final BluetoothService _bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de conexión
    _bluetoothService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }

  void _showConnectionScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConnectionScreen(
          bluetoothService: _bluetoothService,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desconectar'),
        content: const Text('¿Deseas desconectar el dispositivo actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _bluetoothService.disconnect();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text(
              'Desconectar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _bluetoothService.isConnected;
    final deviceName = _bluetoothService.connectedDeviceName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TWF Control'),
        actions: [
          // Indicador de conexión Bluetooth
          StreamBuilder<bool>(
            stream: _bluetoothService.connectionStream,
            initialData: false,
            builder: (context, snapshot) {
              final connected = snapshot.data ?? false;
              return IconButton(
                onPressed: connected ? _showDisconnectDialog : _showConnectionScreen,
                icon: Icon(
                  connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: connected ? Colors.green : Colors.red,
                ),
                tooltip: connected
                    ? 'Conectado a $deviceName'
                    : 'No conectado - Toca para conectar',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Estado de conexión
              _buildConnectionCard(isConnected, deviceName),

              const SizedBox(height: 30),

              // Título del menú
              Text(
                'Menú Principal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 20),

              // Opciones del menú
              _buildMenuOption(
                context,
                title: 'Control de Temperatura',
                subtitle: 'Monitorear y ajustar temperatura objetivo',
                icon: Icons.thermostat,
                iconColor: Colors.orange,
                enabled: isConnected,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TemperatureScreen(
                        bluetoothService: _bluetoothService,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildMenuOption(
                context,
                title: 'Control de Electroválvulas',
                subtitle: 'Gestionar 7 electroválvulas independientes',
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                enabled: isConnected,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ValvesScreen(
                        bluetoothService: _bluetoothService,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Botón de conexión/desconexión
              if (!isConnected)
                ElevatedButton.icon(
                  onPressed: _showConnectionScreen,
                  icon: const Icon(Icons.bluetooth_searching),
                  label: const Text('Conectar Dispositivo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _showDisconnectDialog,
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('Desconectar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),

              const SizedBox(height: 40),

              // Información adicional
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Información',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Versión de la App: 2.0.0\n'
                        '• Compatible con Firmware ESP32 v2.0.0\n'
                        '• 7 Electroválvulas AC\n'
                        '• Control de temperatura con sensor DS18B20\n'
                        '• Comunicación Bluetooth',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(bool isConnected, String? deviceName) {
    return Card(
      color: isConnected
          ? Colors.green.shade50
          : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: isConnected ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected
                        ? deviceName ?? 'ESP32_TempControl'
                        : 'Toca el ícono para conectar',
                    style: TextStyle(
                      fontSize: 14,
                      color: isConnected ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final opacity = enabled ? 1.0 : 0.4;

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: enabled ? 2 : 0,
        child: ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle),
          ),
          trailing: Icon(
            enabled ? Icons.arrow_forward_ios : Icons.lock,
            size: 16,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
