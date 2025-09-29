import 'package:flutter/foundation.dart';
import '../ble/ble_client.dart';

enum AppStatus { disconnected, scanning, connecting, connected, playing, paused }

class AppState extends ChangeNotifier {
  AppStatus status = AppStatus.disconnected;
  String log = '';
  String deviceName = '';
  BleClient? client;

  void addLog(String s) { log = '${DateTime.now().toIso8601String()} - $s\n$log'; notifyListeners(); }

  Future<void> startScan() async {
    status = AppStatus.scanning; notifyListeners();
    client = BleClient();
    await client!.startScan((s) { addLog(s); });
    status = AppStatus.disconnected; notifyListeners();
  }

  Future<void> connect() async {
    if (client==null) return;
    status = AppStatus.connecting; notifyListeners();
    await client!.connect((s) => addLog(s));
    status = AppStatus.connected; notifyListeners();
  }

  Future<void> send(String cmd) async {
    if (client==null) { addLog('No client'); return; }
    try {
      await client!.writeLine(cmd);
      addLog('Sent: $cmd');
    } catch (e) { addLog('Write error: $e'); }
  }
}
