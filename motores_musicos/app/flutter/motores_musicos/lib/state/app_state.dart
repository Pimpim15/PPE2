import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ble/ble_client.dart';

enum AppStatus {
  disconnected,
  requestingPermissions,
  scanning,
  connecting,
  connected,
  playing,
  paused,
  error,
}

class AppState extends ChangeNotifier {
  AppStatus status = AppStatus.disconnected;
  String log = '';
  String deviceName = '';

  BleClient? client;
  StreamSubscription<String>? _lineSub;

  bool get isConnected =>
      status == AppStatus.connected ||
      status == AppStatus.playing ||
      status == AppStatus.paused;

  bool get isBusy =>
      status == AppStatus.requestingPermissions ||
      status == AppStatus.scanning ||
      status == AppStatus.connecting;

  void addLog(String message) {
    log = '${DateTime.now().toIso8601String()} - $message\n$log';
    notifyListeners();
  }

  Future<void> scanAndConnect() async {
    if (isBusy) return;

    status = AppStatus.requestingPermissions;
    notifyListeners();
    final permissionsOk = await _ensurePermissions();
    if (!permissionsOk) {
      status = AppStatus.error;
      addLog('Permissões obrigatórias negadas.');
      notifyListeners();
      return;
    }

    client ??= BleClient();

    status = AppStatus.scanning;
    notifyListeners();

    try {
  final device = await client!.startScan(addLog);
  deviceName = device.name.isNotEmpty ? device.name : device.id;
      addLog('Selecionado: $deviceName');

      status = AppStatus.connecting;
      notifyListeners();

      await client!.connect(
        addLog,
        onDisconnected: _handleDisconnect,
      );

      await _lineSub?.cancel();
      _lineSub = client!.lines.listen(_handleIncomingLine);

      status = AppStatus.connected;
      addLog('Conexão pronta para uso.');
    } catch (error) {
      addLog('Falha no processo de conexão: $error');
      await client?.disconnect();
      status = AppStatus.disconnected;
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    await _lineSub?.cancel();
    _lineSub = null;
    await client?.disconnect();
    status = AppStatus.disconnected;
    addLog('Desconectado do HM-10.');
    notifyListeners();
  }

  Future<void> send(String command) async {
    if (!(client != null && isConnected)) {
      addLog('BLE não está conectado. Comando "$command" ignorado.');
      return;
    }
    try {
      await client!.writeLine(command);
      addLog('TX: $command');
    } catch (error) {
      addLog('Erro ao enviar "$command": $error');
    }
  }

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statusMap = await permissions.request();
    final denied = statusMap.entries.where((entry) => !entry.value.isGranted);
    if (denied.isEmpty) {
      return true;
    }

    final deniedNames = denied.map((entry) => entry.key.toString()).join(', ');
    addLog('Permissões negadas: $deniedNames');
    return false;
  }

  void _handleIncomingLine(String line) {
    addLog('RX: $line');
    if (line.startsWith('PLAYER_STATE')) {
      final parts = line.split(' ');
      final state = parts.length > 1 ? parts.last.trim().toUpperCase() : '';
      switch (state) {
        case 'PLAY':
          status = AppStatus.playing;
          break;
        case 'PAUSED':
          status = AppStatus.paused;
          break;
        case 'DONE':
        case 'STOP':
          status = AppStatus.connected;
          break;
        default:
          break;
      }
      notifyListeners();
    }
  }

  void _handleDisconnect() {
    status = AppStatus.disconnected;
    addLog('Conexão BLE perdida.');
    notifyListeners();
  }

  @override
  void dispose() {
    _lineSub?.cancel();
    _lineSub = null;
    final disposeFuture = client?.dispose();
    if (disposeFuture != null) {
      unawaited(disposeFuture);
    }
    super.dispose();
  }
}
