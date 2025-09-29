import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleClient {
  final _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSub;
  DiscoveredDevice? _device;
  late QualifiedCharacteristic _txChar; // write
  late QualifiedCharacteristic _rxChar; // notify
  StreamController<String> _lines = StreamController.broadcast();

  Stream<String> get lines => _lines.stream;

  Future<void> startScan(Function(String) onLog) async {
    onLog('Scanning for HM-10...');
    _scanSub = _ble.scanForDevices(withServices: []).listen((d) {
      final name = d.name;
      if (name != null && (name.contains('HM') || name.contains('HMSoft') || name.contains('HM-10'))) {
        onLog('Found ${d.name} ${d.id}');
        _device = d;
        _scanSub.cancel();
      }
    }, onError: (e) => onLog('Scan error: $e'));
  }

  Future<void> connect(Function(String) onLog) async {
    if (_device == null) throw Exception('No device');
    onLog('Connecting to ${_device!.name}');
    final conn = _ble.connectToDevice(id: _device!.id, servicesWithCharacteristicsToDiscover: {}).listen((event) async {
      if (event.connectionState == DeviceConnectionState.connected) {
        onLog('Connected, discovering services...');
        final services = await _ble.discoverServices(_device!.id);
        onLog('Services: ' + services.map((s) => s.serviceId.toString()).join(','));
        // Find a service with a writable characteristic and a notify characteristic
        for (final s in services) {
          for (final c in s.characteristics) {
            onLog('Char ${c.characteristicId} properties ${c.isWritableWithResponse} ${c.isNotifiable}');
          }
        }
        // heuristic: try FFE0/FFE1
        final ffeService = services.firstWhere(
            (s) => s.serviceId.toString().toUpperCase().contains('FFE0') || s.serviceId.toString().toUpperCase().contains('FFE0'),
            orElse: () => services.isNotEmpty ? services[0] : throw Exception('No services'));
        final chars = ffeService.characteristics;
        // pick write and notify
        QualifiedCharacteristic? writeC;
        QualifiedCharacteristic? notifyC;
        for (final c in chars) {
          if (c.isWritableWithResponse == true && writeC==null) writeC = QualifiedCharacteristic(serviceId: ffeService.serviceId, characteristicId: c.characteristicId, deviceId: _device!.id);
          if (c.isNotifiable == true && notifyC==null) notifyC = QualifiedCharacteristic(serviceId: ffeService.serviceId, characteristicId: c.characteristicId, deviceId: _device!.id);
        }
        if (writeC==null && chars.isNotEmpty) {
          writeC = QualifiedCharacteristic(serviceId: ffeService.serviceId, characteristicId: chars[0].characteristicId, deviceId: _device!.id);
        }
        _txChar = writeC!;
        if (notifyC != null) {
          _rxChar = notifyC;
          _ble.subscribeToCharacteristic(_rxChar).listen((data) {
            final s = utf8.decode(data);
            _lines.add(s);
          });
        }
        onLog('Ready to write');
      }
    });
  }

  Future<void> writeLine(String s) async {
    final bytes = utf8.encode(s + '\n');
    await _ble.writeCharacteristicWithResponse(_txChar, value: bytes);
  }

  void dispose() {
    _lines.close();
  }
}
