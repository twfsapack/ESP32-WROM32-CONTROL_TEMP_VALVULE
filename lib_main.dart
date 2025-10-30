// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const SmartRoomApp());

class SmartRoomApp extends StatelessWidget {
  const SmartRoomApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartRoom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FlutterBluetoothSerial _bt = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  bool isConnected = false;
  BluetoothDevice? selectedDevice;

  double currentTemp = double.nan;
  double setTemp = 25.0;
  bool relayOn = false;
  List<bool> valveState = List<bool>.filled(7, false);

  final int historyLen = 60;
  final List<double?> history = List<double?>.filled(60, null);
  int historyIndex = 0;

  final TextEditingController setTempCtrl = TextEditingController();
  final List<TextEditingController> delayCtrls = List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> timeCtrls = List.generate(7, (_) => TextEditingController());
  final List<bool> enabled = List<bool>.filled(7, true);

  final List<String> logs = [];
  final ScrollController logScroll = ScrollController();

  String rxBuffer = '';

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    setTempCtrl.text = setTemp.toStringAsFixed(1);
    for (int i=0;i<7;i++){ delayCtrls[i].text='0'; timeCtrls[i].text='1'; }
    tabController = TabController(length: 3, vsync: this);
    _ensureBluetooth();
  }

  Future<void> _ensureBluetooth() async {
    bool enabled = await _bt.isEnabled ?? false;
    if (!enabled) {
      bool result = await _bt.requestEnable();
      if (!result) _appendLog('Bluetooth not enabled');
    }
  }

  void _appendLog(String s) {
    final now = DateTime.now();
    setState(() {
      logs.add('[${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}] $s');
      if (logs.length>500) logs.removeAt(0);
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (logScroll.hasClients) logScroll.jumpTo(logScroll.position.maxScrollExtent);
    });
  }

  Future<void> _openDiscovery() async {
    final BluetoothDevice? device = await Navigator.of(context).push(MaterialPageRoute(builder: (c)=>const DiscoveryPage()));
    if (device!=null) {
      setState(()=>selectedDevice=device);
      _appendLog('Selected ${device.name ?? device.address}');
    }
  }

  Future<void> _connect() async {
    if (selectedDevice==null) { _appendLog('No device selected'); return; }
    try {
      final conn = await BluetoothConnection.toAddress(selectedDevice!.address);
      connection = conn;
      isConnected = true;
      _appendLog('Connected to ${selectedDevice!.name ?? selectedDevice!.address}');
      connection!.input!.listen(_onDataReceived).onDone((){ _appendLog('Disconnected'); _disconnect(); });
    } catch (e) { _appendLog('Connection error: $e'); }
    setState(() {});
  }

  void _disconnect() {
    connection?.dispose();
    connection = null;
    setState(()=>isConnected=false);
    _appendLog('Disconnected');
  }

  void _onDataReceived(Uint8List data) {
    final s = utf8.decode(data, allowMalformed: true);
    rxBuffer += s;
    int idx;
    while ((idx = rxBuffer.indexOf('\n')) >= 0) {
      final line = rxBuffer.substring(0, idx).trim();
      rxBuffer = rxBuffer.substring(idx+1);
      if (line.isNotEmpty) _processLine(line);
    }
  }

  void _processLine(String line) {
    _appendLog('RX: $line');
    final parts = line.split(';');
    for (final p in parts) {
      if (p.isEmpty) continue;
      final kv = p.split('=');
      if (kv.length<2) continue;
      final k = kv[0].trim();
      final v = kv.sublist(1).join('=').trim();
      if (k=='TEMP_ACT') {
        final val = double.tryParse(v);
        if (val!=null) _pushHistory(val);
      } else if (k=='TEMP_SET') {
        final val = double.tryParse(v);
        if (val!=null) setState(()=>setTemp=val);
      } else if (k.startsWith('VALVE')) {
        final idx = int.tryParse(k.substring(5));
        if (idx!=null && idx>=0 && idx<7) {
          final parts2 = v.split(',');
          if (parts2.length>=4) {
            setState((){
              delayCtrls[idx].text = parts2[1];
              timeCtrls[idx].text = parts2[2];
              enabled[idx] = parts2[3]=='1';
              valveState[idx] = (parts2[0]=='ON');
            });
          }
        }
      } else if (k=='RELE') {
        setState(()=>relayOn = v.toUpperCase()=='ON');
      }
    }
  }

  void _pushHistory(double v) {
    setState(()=>{
      history[historyIndex]=v;
      historyIndex=(historyIndex+1)%historyLen;
      currentTemp = v;
    });
  }

  void _send(String cmd) {
    if (!isConnected || connection==null) { _appendLog('Not connected - cannot send'); return; }
    try {
      connection!.output.add(utf8.encode(cmd + '\n'));
      _appendLog('TX: $cmd');
    } catch (e) { _appendLog('Send error: $e'); }
  }

  List<FlSpot> _spots() {
    final spots = <FlSpot>[];
    int x=0;
    for (int i=0;i<historyLen;i++){
      final val = history[(historyIndex+i)%historyLen];
      if (val!=null) spots.add(FlSpot(x.toDouble(), val));
      x++;
    }
    return spots;
  }

  Widget _buildChart() {
    final spots = _spots();
    if (spots.isEmpty) return const Center(child: Text('No data yet'));
    final ys = spots.map((s)=>s.y);
    final minY = ys.reduce((a,b)=>a<b?a:b)-2;
    final maxY = ys.reduce((a,b)=>a>b?a:b)+2;
    return LineChart(LineChartData(
      minY: minY, maxY: maxY,
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: false),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, dotData: FlDotData(show:false), barWidth: 2)],
    ));
  }

  @override
  void dispose() {
    connection?.dispose();
    setTempCtrl.dispose();
    for (final c in delayCtrls) c.dispose();
    for (final c in timeCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartRoom'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _openDiscovery),
          IconButton(icon: Icon(isConnected?Icons.bluetooth_connected:Icons.bluetooth_disabled), onPressed: () { if (isConnected) _disconnect(); else if (selectedDevice!=null) _connect(); else _openDiscovery(); })
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Dashboard / Temperature
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Temperature', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Current: ${currentTemp.isNaN? "--": currentTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Setpoint: ${setTemp.toStringAsFixed(1)} °C'),
                    const SizedBox(height: 6),
                    Wrap(children: [
                      ElevatedButton.icon(onPressed: ()=>_send('GET_STATUS'), icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(onPressed: ()=>_send('PING'), icon: const Icon(Icons.wifi_tethering), label: const Text('Ping')),
                    ])
                  ])),
                  const SizedBox(width: 12),
                  SizedBox(width: 160, height: 120, child: Card(child: Padding(padding: const EdgeInsets.all(6), child: _buildChart())))
                ])
              ]))),
              const SizedBox(height: 12),
              Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Expanded(child: TextField(controller: setTempCtrl, keyboardType: const TextInputType.numberWithOptions(decimal:true), decoration: const InputDecoration(labelText: 'Set Temperature (°C)'))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: (){ final t = double.tryParse(setTempCtrl.text); if (t!=null) _send('SET_TEMP=${t.toStringAsFixed(1)}'); }, child: const Text('Send')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: ()=>_send('CONFIRM'), child: const Text('Confirm'))
              ])))
            ]),
          ),

          // Valves tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(children: List.generate(7, (i) {
              return Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Valve ${i+1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(valveState[i]?Icons.toggle_on:Icons.toggle_off, color: valveState[i]?Colors.green:Colors.grey),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: ()=>_send('START_VALVE=${i}'), child: const Text('Start')),
                  const SizedBox(width: 6),
                  ElevatedButton(onPressed: ()=>_send('STOP_VALVE=${i}'), child: const Text('Stop')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: delayCtrls[i], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Delay (s)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: timeCtrls[i], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (s)'))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: (){ final d=int.tryParse(delayCtrls[i].text)??0; final t=int.tryParse(timeCtrls[i].text)??1; _send('SET_VALVE_${i}_DELAY=${d}'); _send('SET_VALVE_${i}_TIME=${t}'); }, child: const Text('Send')),
                  const SizedBox(width: 8),
                  Row(children: [const Text('Enabled'), Switch(value: enabled[i], onChanged: (v){ enabled[i]=v; _send('ENABLE_VALVE_${i}=${v?1:0}'); setState((){}); })])
                ])
              ])));
            }))
          ),

          // Logs
          Padding(padding: const EdgeInsets.all(8), child: Column(children: [
            Row(children: [ElevatedButton(onPressed: ()=>_send('GET_STATUS'), child: const Text('Refresh')), const SizedBox(width:8), ElevatedButton(onPressed: ()=>_send('PING'), child: const Text('Ping'))]),
            const SizedBox(height:8),
            Expanded(child: Card(child: ListView.builder(controller: logScroll, itemCount: logs.length, itemBuilder: (c,i) => Padding(padding: const EdgeInsets.all(6), child: Text(logs[i])))))
          ]))
        ],
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.surface,
        child: TabBar(
          controller: tabController,
          tabs: const [Tab(icon: Icon(Icons.thermostat), text: 'Temp'), Tab(icon: Icon(Icons.invert_colors), text: 'Valves'), Tab(icon: Icon(Icons.list), text: 'Logs')],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
      ),
    );
  }
}

// Discovery page included (simple list of bonded devices + scan)
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});
  @override State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final FlutterBluetoothSerial _bt = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devices = [];
  @override
  void initState() { super.initState(); _getBonded(); }
  Future<void> _getBonded() async { final bonded = await _bt.getBondedDevices(); setState(()=>_devices=bonded); }
  Future<void> _startDiscovery() async { _devices.clear(); setState(()=>{}); final stream = _bt.startDiscovery(timeout: const Duration(seconds:6)); stream.listen((r){ final d = r.device; if (!_devices.any((x)=>x.address==d.address)) setState(()=>_devices.add(d)); }).onDone((){}); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Buscar dispositivos'), actions: [IconButton(icon: const Icon(Icons.search), onPressed: _startDiscovery), IconButton(icon: const Icon(Icons.refresh), onPressed: _getBonded)]),
    body: ListView.builder(itemCount: _devices.length, itemBuilder: (c,i){ final d = _devices[i]; return ListTile(title: Text(d.name ?? d.address), subtitle: Text(d.address), onTap: ()=>Navigator.of(context).pop(d)); }));
  }
}
