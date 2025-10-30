// Splash Screen - Pantalla de Bienvenida
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Inicializando...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Animaciones
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Iniciar proceso de inicialización
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Esperar animación inicial
      await Future.delayed(const Duration(milliseconds: 1000));

      // Paso 1: Verificar y solicitar permisos
      setState(() => _statusMessage = 'Solicitando permisos...');
      await _requestPermissions();

      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 2: Verificar Bluetooth
      setState(() => _statusMessage = 'Verificando Bluetooth...');
      await _checkBluetooth();

      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 3: Navegar al menú principal
      setState(() => _statusMessage = '¡Listo!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = 'Error: ${e.toString()}';
      });

      // Esperar y reintentar
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _hasError) {
        _initialize();
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Solicitar permisos necesarios para Bluetooth
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location, // Necesario para escaneo BT en Android
    ].request();

    // Verificar si se otorgaron los permisos
    bool allGranted = statuses.values.every((status) =>
        status.isGranted || status.isLimited || status.isPermanentlyDenied);

    if (!allGranted) {
      // Mostrar diálogo explicativo
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Permisos Necesarios'),
            content: const Text(
              'Esta aplicación necesita permisos de Bluetooth y Ubicación '
              'para conectarse al ESP32.\n\n'
              'Por favor, otorga los permisos en la configuración.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Abrir Configuración'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _checkBluetooth() async {
    try {
      final bluetooth = FlutterBluetoothSerial.instance;

      // Verificar si Bluetooth está disponible
      bool? isAvailable = await bluetooth.isAvailable;
      if (isAvailable != true) {
        throw Exception('Bluetooth no disponible en este dispositivo');
      }

      // Verificar si está habilitado
      bool? isEnabled = await bluetooth.isEnabled;
      if (isEnabled != true) {
        // Solicitar habilitar Bluetooth
        bool? enableResult = await bluetooth.requestEnable();
        if (enableResult != true) {
          throw Exception('Bluetooth debe estar habilitado');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo TWF
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_icon_tecnoworldfuture.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Si no se encuentra la imagen, mostrar placeholder
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.settings_input_component,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TWF',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Título
                    Text(
                      'TWF Control',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Sistema de Control ESP32',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),

                    const SizedBox(height: 60),

                    // Indicador de progreso
                    if (!_hasError) ...[
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Mensaje de estado
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _hasError ? Colors.red[100] : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Botón de reintentar si hay error
                    if (_hasError) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _statusMessage = 'Reintentando...';
                          });
                          _initialize();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Versión y créditos
                    Column(
                      children: [
                        Text(
                          'v2.0.0',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2025 TecnoWorldFuture',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
