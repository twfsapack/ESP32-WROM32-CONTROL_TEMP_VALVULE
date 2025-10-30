// Temperature Screen - Pantalla de control de temperatura v2.0.0
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/bluetooth_service.dart';
import 'dart:async';

class TemperatureScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const TemperatureScreen({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> with SingleTickerProviderStateMixin {
  ESP32Data? _latestData;

  // Historial de temperatura para el gráfico (últimos 50 puntos)
  final List<FlSpot> _temperatureHistory = [];
  final int _maxHistoryPoints = 50;
  int _timeCounter = 0;

  // Control de temperatura objetivo
  double _targetTemperature = 25.0;
  bool _hasUnsavedChanges = false;

  // Animación del SSR
  late AnimationController _ssrAnimationController;
  late Animation<double> _ssrAnimation;

  // Timer para actualización automática
  Timer? _updateTimer;

  // Alertas
  bool _showHighTempAlert = false;
  bool _showLowTempAlert = false;

  @override
  void initState() {
    super.initState();

    // Configurar animación del SSR
    _ssrAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _ssrAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _ssrAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Escuchar datos del ESP32
    widget.bluetoothService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _latestData = data;

          // Actualizar temperatura objetivo si es diferente
          if (data.setTemp != null && !_hasUnsavedChanges) {
            _targetTemperature = data.setTemp!;
          }

          // Agregar punto al historial
          if (data.currentTemp != null) {
            _addTemperaturePoint(data.currentTemp!);
            _checkTemperatureAlerts(data.currentTemp!);
          }

          // Animar SSR si está encendido
          if (data.relayOn == true) {
            if (!_ssrAnimationController.isAnimating) {
              _ssrAnimationController.repeat(reverse: true);
            }
          } else {
            _ssrAnimationController.stop();
            _ssrAnimationController.reset();
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
    _ssrAnimationController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _addTemperaturePoint(double temp) {
    setState(() {
      _temperatureHistory.add(FlSpot(_timeCounter.toDouble(), temp));
      _timeCounter++;

      // Mantener solo los últimos puntos
      if (_temperatureHistory.length > _maxHistoryPoints) {
        _temperatureHistory.removeAt(0);
      }
    });
  }

  void _checkTemperatureAlerts(double currentTemp) {
    // Alerta si la diferencia es mayor a 5°C
    if (_latestData?.setTemp != null) {
      double diff = (currentTemp - _latestData!.setTemp!).abs();

      if (currentTemp > _latestData!.setTemp! + 5) {
        setState(() => _showHighTempAlert = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showHighTempAlert = false);
        });
      } else if (currentTemp < _latestData!.setTemp! - 5) {
        setState(() => _showLowTempAlert = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showLowTempAlert = false);
        });
      }
    }
  }

  void _sendTemperatureToESP32() {
    widget.bluetoothService.setTemperature(_targetTemperature);
    setState(() => _hasUnsavedChanges = false);

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Temperatura objetivo: ${_targetTemperature.toStringAsFixed(1)}°C enviada al ESP32'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _incrementTemperature() {
    if (_targetTemperature < 100) {
      setState(() {
        _targetTemperature += 0.5;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _decrementTemperature() {
    if (_targetTemperature > 0) {
      setState(() {
        _targetTemperature -= 0.5;
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alertas de temperatura
            if (_showHighTempAlert)
              _buildAlert(
                'Temperatura Alta',
                'La temperatura actual supera el objetivo en más de 5°C',
                Colors.red,
                Icons.warning_amber,
              ),
            if (_showLowTempAlert)
              _buildAlert(
                'Temperatura Baja',
                'La temperatura actual está 5°C por debajo del objetivo',
                Colors.blue,
                Icons.warning_amber,
              ),

            // Card de temperatura actual
            _buildCurrentTemperatureCard(colorScheme),

            const SizedBox(height: 16),

            // Indicador SSR
            _buildSSRIndicator(colorScheme),

            const SizedBox(height: 16),

            // Gráfico de temperatura
            _buildTemperatureChart(colorScheme),

            const SizedBox(height: 16),

            // Control de temperatura objetivo
            _buildTemperatureControl(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(String title, String message, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTemperatureCard(ColorScheme colorScheme) {
    final currentTemp = _latestData?.currentTemp;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.thermostat,
                  size: 48,
                  color: _getTemperatureColor(currentTemp),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperatura Actual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTemp != null
                          ? '${currentTemp.toStringAsFixed(1)}°C'
                          : '--°C',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: _getTemperatureColor(currentTemp),
                        fontWeight: FontWeight.bold,
                        fontSize: 56,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 20) return Colors.blue;
    if (temp < 25) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSSRIndicator(ColorScheme colorScheme) {
    final relayOn = _latestData?.relayOn ?? false;

    return Card(
      elevation: 2,
      color: relayOn ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Estado del SSR:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 16),
            ScaleTransition(
              scale: _ssrAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: relayOn ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: relayOn ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      relayOn ? Icons.power : Icons.power_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      relayOn ? 'ENCENDIDO' : 'APAGADO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Historial de Temperatura',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _temperatureHistory.isEmpty
                  ? Center(
                      child: Text(
                        'Esperando datos...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 5,
                          verticalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 10,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}s',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}°C',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        minX: _temperatureHistory.first.x,
                        maxX: _temperatureHistory.last.x,
                        minY: _getMinY() - 2,
                        maxY: _getMaxY() + 2,
                        lineBarsData: [
                          // Línea de temperatura actual
                          LineChartBarData(
                            spots: _temperatureHistory,
                            isCurved: true,
                            color: colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          // Línea de temperatura objetivo
                          if (_latestData?.setTemp != null)
                            LineChartBarData(
                              spots: [
                                FlSpot(_temperatureHistory.first.x, _latestData!.setTemp!),
                                FlSpot(_temperatureHistory.last.x, _latestData!.setTemp!),
                              ],
                              isCurved: false,
                              color: Colors.orange,
                              barWidth: 2,
                              dashArray: [5, 5],
                              dotData: FlDotData(show: false),
                            ),
                        ],
                      ),
                    ),
            ),
            if (_temperatureHistory.isNotEmpty && _latestData?.setTemp != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(colorScheme.primary, 'Temperatura Actual'),
                    const SizedBox(width: 24),
                    _buildLegendItem(Colors.orange, 'Temperatura Objetivo', dashed: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool dashed = false}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: dashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  double _getMinY() {
    if (_temperatureHistory.isEmpty) return 0;
    double min = _temperatureHistory.first.y;
    for (var spot in _temperatureHistory) {
      if (spot.y < min) min = spot.y;
    }
    if (_latestData?.setTemp != null && _latestData!.setTemp! < min) {
      min = _latestData!.setTemp!;
    }
    return min;
  }

  double _getMaxY() {
    if (_temperatureHistory.isEmpty) return 100;
    double max = _temperatureHistory.first.y;
    for (var spot in _temperatureHistory) {
      if (spot.y > max) max = spot.y;
    }
    if (_latestData?.setTemp != null && _latestData!.setTemp! > max) {
      max = _latestData!.setTemp!;
    }
    return max;
  }

  Widget _buildTemperatureControl(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ajustar Temperatura Objetivo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Display de temperatura objetivo
            Center(
              child: Column(
                children: [
                  Text(
                    'Temperatura Objetivo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_targetTemperature.toStringAsFixed(1)}°C',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasUnsavedChanges)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.edit,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Slider
            Row(
              children: [
                IconButton(
                  onPressed: _decrementTemperature,
                  icon: const Icon(Icons.remove_circle),
                  color: colorScheme.primary,
                  iconSize: 36,
                ),
                Expanded(
                  child: Slider(
                    value: _targetTemperature,
                    min: 0,
                    max: 100,
                    divisions: 200,
                    label: '${_targetTemperature.toStringAsFixed(1)}°C',
                    onChanged: (value) {
                      setState(() {
                        _targetTemperature = value;
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: _incrementTemperature,
                  icon: const Icon(Icons.add_circle),
                  color: colorScheme.primary,
                  iconSize: 36,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rango
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0°C', style: TextStyle(color: Colors.grey[600])),
                  Text('100°C', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón de enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hasUnsavedChanges ? _sendTemperatureToESP32 : null,
                icon: const Icon(Icons.send),
                label: Text(
                  _hasUnsavedChanges
                      ? 'Enviar al ESP32'
                      : 'Sin cambios pendientes',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _hasUnsavedChanges ? colorScheme.primary : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tienes cambios sin guardar',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom painter para línea punteada en la leyenda
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 3;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
