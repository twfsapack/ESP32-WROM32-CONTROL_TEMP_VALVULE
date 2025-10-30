// Valves Screen - Pantalla de control de electroválvulas v2.0.0
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'dart:async';

class ValvesScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const ValvesScreen({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<ValvesScreen> createState() => _ValvesScreenState();
}

class _ValvesScreenState extends State<ValvesScreen> with TickerProviderStateMixin {
  ESP32Data? _latestData;

  // Configuración local de válvulas (editable)
  final List<ValveConfig> _localValveConfigs = List.generate(
    7,
    (index) => ValveConfig(
      index: index,
      delay: 0,
      time: 5,
      enabled: true,
    ),
  );

  // Controles de expansión
  final List<bool> _expandedStates = List.generate(7, (index) => false);

  // Cambios pendientes
  bool _hasUnsavedChanges = false;

  // Animaciones para válvulas activas
  late List<AnimationController> _valveAnimationControllers;
  late List<Animation<double>> _valveAnimations;

  // Timer para actualización automática
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _valveAnimationControllers = List.generate(
      7,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      ),
    );

    _valveAnimations = _valveAnimationControllers.map((controller) {
      return Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Escuchar datos del ESP32
    widget.bluetoothService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestData = data;

          // Sincronizar configuración local con ESP32 si no hay cambios pendientes
          if (!_hasUnsavedChanges) {
            for (int i = 0; i < 7; i++) {
              _localValveConfigs[i].delay = data.valveDelays[i];
              _localValveConfigs[i].time = data.valveTimes[i];
              _localValveConfigs[i].enabled = data.valveEnabled[i];
            }
          }

          // Animar válvulas activas
          for (int i = 0; i < 7; i++) {
            if (data.valveStates[i]) {
              if (!_valveAnimationControllers[i].isAnimating) {
                _valveAnimationControllers[i].repeat(reverse: true);
              }
            } else {
              _valveAnimationControllers[i].stop();
              _valveAnimationControllers[i].reset();
            }
          }
        });
      }
    });

    // Solicitar estado inicial
    widget.bluetoothService.getStatus();

    // Timer para actualizar cada 2 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        widget.bluetoothService.getStatus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _valveAnimationControllers) {
      controller.dispose();
    }
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateLocalConfig(int index, {int? delay, int? time, bool? enabled}) {
    setState(() {
      if (delay != null) _localValveConfigs[index].delay = delay;
      if (time != null) _localValveConfigs[index].time = time;
      if (enabled != null) _localValveConfigs[index].enabled = enabled;
      _hasUnsavedChanges = true;
    });
  }

  void _sendConfigToESP32(int index) {
    final config = _localValveConfigs[index];
    widget.bluetoothService.configValve(
      index,
      config.delay,
      config.time,
      config.enabled,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuración de Válvula ${index + 1} enviada al ESP32'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendAllConfigsToESP32() {
    for (int i = 0; i < 7; i++) {
      final config = _localValveConfigs[i];
      widget.bluetoothService.configValve(
        i,
        config.delay,
        config.time,
        config.enabled,
      );
    }

    setState(() => _hasUnsavedChanges = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las configuraciones enviadas al ESP32'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startValve(int index) {
    if (_localValveConfigs[index].enabled) {
      widget.bluetoothService.startValve(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Válvula ${index + 1} iniciada'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _stopValve(int index) {
    widget.bluetoothService.stopValve(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Válvula ${index + 1} detenida'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _startAllValves() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Todas las Válvulas'),
        content: const Text(
          '¿Estás seguro de que deseas iniciar todas las válvulas habilitadas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              for (int i = 0; i < 7; i++) {
                if (_localValveConfigs[i].enabled) {
                  widget.bluetoothService.startValve(i);
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las válvulas habilitadas han sido iniciadas'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _stopAllValves() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detener Todas las Válvulas'),
        content: const Text(
          '¿Estás seguro de que deseas detener todas las válvulas activas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              for (int i = 0; i < 7; i++) {
                widget.bluetoothService.stopValve(i);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las válvulas han sido detenidas'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Detener'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 Electroválvulas AC',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Control independiente con temporización',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botones de control masivo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _startAllValves,
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Iniciar Todas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _stopAllValves,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text('Detener Todas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de válvulas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(7, (index) {
                return _buildValveCard(index, colorScheme);
              }),
            ),
          ),

          // Botón de guardar cambios (sticky bottom)
          if (_hasUnsavedChanges)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tienes cambios sin guardar',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendAllConfigsToESP32,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Todos los Cambios'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
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

  Widget _buildValveCard(int index, ColorScheme colorScheme) {
    final isActive = _latestData?.valveStates[index] ?? false;
    final config = _localValveConfigs[index];
    final isExpanded = _expandedStates[index];

    // Determinar color según estado
    Color cardColor;
    Color borderColor;
    if (!config.enabled) {
      cardColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade400;
    } else if (isActive) {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green;
    } else {
      cardColor = Colors.white;
      borderColor = Colors.grey.shade300;
    }

    return ScaleTransition(
      scale: _valveAnimations[index],
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isActive ? 4 : 2,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            // Header (siempre visible)
            InkWell(
              onTap: () {
                setState(() {
                  _expandedStates[index] = !_expandedStates[index];
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icono y número de válvula
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: config.enabled
                                ? (isActive ? Colors.green : colorScheme.primary)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nombre y estado
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Válvula ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green
                                          : (config.enabled ? Colors.grey : Colors.red),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isActive
                                          ? 'ACTIVA'
                                          : (config.enabled ? 'INACTIVA' : 'DESHABILITADA'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isActive)
                                    Icon(
                                      Icons.water,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Icono de expansión
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Info rápida
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickInfo(
                          Icons.schedule,
                          'Retardo',
                          '${config.delay}s',
                          Colors.orange,
                        ),
                        _buildQuickInfo(
                          Icons.timer,
                          'Duración',
                          '${config.time}s',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contenido expandible
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Switch de habilitación
                    _buildEnabledSwitch(index, config),

                    const SizedBox(height: 20),

                    // Control de retardo
                    _buildDelayControl(index, config, colorScheme),

                    const SizedBox(height: 20),

                    // Control de duración
                    _buildTimeControl(index, config, colorScheme),

                    const SizedBox(height: 20),

                    // Botones de control
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: config.enabled
                                ? () => _startValve(index)
                                : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Iniciar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: config.enabled
                                ? () => _stopValve(index)
                                : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Detener'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Botón de guardar individual
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _sendConfigToESP32(index),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar Solo Esta Válvula'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnabledSwitch(int index, ValveConfig config) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.enabled ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.enabled ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            config.enabled ? Icons.check_circle : Icons.cancel,
            color: config.enabled ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Válvula ${config.enabled ? "Habilitada" : "Deshabilitada"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  config.enabled
                      ? 'Puede ser activada manual o automáticamente'
                      : 'No responderá a comandos de inicio',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: config.enabled,
            onChanged: (value) {
              _updateLocalConfig(index, enabled: value);
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDelayControl(int index, ValveConfig config, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Retardo de Inicio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tiempo de espera antes de activar la válvula',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: config.delay > 0
                  ? () => _updateLocalConfig(index, delay: config.delay - 1)
                  : null,
              icon: const Icon(Icons.remove_circle),
              color: Colors.orange,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${config.delay} segundos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Slider(
                    value: config.delay.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 60,
                    label: '${config.delay}s',
                    onChanged: (value) {
                      _updateLocalConfig(index, delay: value.toInt());
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: config.delay < 60
                  ? () => _updateLocalConfig(index, delay: config.delay + 1)
                  : null,
              icon: const Icon(Icons.add_circle),
              color: Colors.orange,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0s', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text('60s', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeControl(int index, ValveConfig config, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Duración de Activación',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tiempo que permanecerá activa la válvula',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: config.time > 1
                  ? () => _updateLocalConfig(index, time: config.time - 1)
                  : null,
              icon: const Icon(Icons.remove_circle),
              color: Colors.blue,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${config.time} segundos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Slider(
                    value: config.time.toDouble(),
                    min: 1,
                    max: 300,
                    divisions: 299,
                    label: '${config.time}s',
                    onChanged: (value) {
                      _updateLocalConfig(index, time: value.toInt());
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: config.time < 300
                  ? () => _updateLocalConfig(index, time: config.time + 1)
                  : null,
              icon: const Icon(Icons.add_circle),
              color: Colors.blue,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1s', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text('5min', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// Clase para configuración local de válvula
class ValveConfig {
  final int index;
  int delay;
  int time;
  bool enabled;

  ValveConfig({
    required this.index,
    required this.delay,
    required this.time,
    required this.enabled,
  });
}
