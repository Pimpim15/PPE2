import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleClient {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  StreamSubscription<List<int>>? _notifySub;

  DiscoveredDevice? _device;
  QualifiedCharacteristic? _txChar;

  final StreamController<String> _lines = StreamController<String>.broadcast();
  String _rxBuffer = '';

  Stream<String> get lines => _lines.stream;
  DiscoveredDevice? get device => _device;

  Future<DiscoveredDevice> startScan(
    void Function(String) onLog, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    await _scanSub?.cancel();
    final completer = Completer<DiscoveredDevice>();
    onLog('Iniciando busca por HM-10...');
    _scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      final name = device.name;
      if (name.contains('HM') || name.contains('HMSoft') || name.contains('HM-10')) {
        onLog('Dispositivo encontrado: $name (${device.id})');
        _device = device;
        if (!completer.isCompleted) {
          completer.complete(device);
        }
        _scanSub?.cancel();
      }
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      onLog('Erro ao escanear: $error');
    });

    Future<void>.delayed(timeout, () {
      if (!completer.isCompleted) {
        onLog('Tempo limite atingido ao procurar HM-10.');
        completer.completeError(TimeoutException('Nenhum dispositivo HM-10 encontrado em $timeout.'));
        _scanSub?.cancel();
      }
    });
    return completer.future;
  }

  Future<void> connect(
    void Function(String) onLog, {
    required VoidCallback onDisconnected,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final selected = _device;
    if (selected == null) {
      throw Exception('Nenhum dispositivo selecionado');
    }

    await _connSub?.cancel();
    await _notifySub?.cancel();
  _txChar = null;
    _rxBuffer = '';

    final completer = Completer<void>();
    bool ready = false;

  onLog('Conectando em ${selected.name}...');
    _connSub = _ble
        .connectToDevice(
          id: selected.id,
          connectionTimeout: timeout,
        )
        .listen((event) async {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          onLog('Conectado. Descobrindo serviços...');
          try {
            await _prepareCharacteristics(selected, onLog);
            ready = true;
            if (!completer.isCompleted) {
              completer.complete();
            }
            onLog('Pronto para enviar comandos.');
          } catch (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
            onLog('Erro ao preparar características: $error');
          }
          break;
  case DeviceConnectionState.disconnected:
          onLog('Conexão encerrada.');
          if (ready) {
            onDisconnected();
          }
          await _notifySub?.cancel();
          _notifySub = null;
          if (!completer.isCompleted) {
            completer.completeError(Exception('Desconectado antes de finalizar preparação.'));
          }
          break;
        default:
          break;
      }
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      onLog('Erro de conexão: $error');
    });

    return completer.future;
  }

  Future<void> _prepareCharacteristics(DiscoveredDevice device, void Function(String) onLog) async {
  // ignore: deprecated_member_use
  final services = await _ble.discoverServices(device.id);
    onLog('Serviços GATT: ${services.map((s) => s.serviceId).join(', ')}');

    QualifiedCharacteristic? writeChar;
    QualifiedCharacteristic? notifyChar;

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (writeChar == null && (characteristic.isWritableWithResponse || characteristic.isWritableWithoutResponse)) {
          writeChar = QualifiedCharacteristic(
            serviceId: service.serviceId,
            characteristicId: characteristic.characteristicId,
            deviceId: device.id,
          );
        }
        if (notifyChar == null && characteristic.isNotifiable) {
          notifyChar = QualifiedCharacteristic(
            serviceId: service.serviceId,
            characteristicId: characteristic.characteristicId,
            deviceId: device.id,
          );
        }
      }
    }

    if (writeChar == null) {
      throw Exception('Nenhuma característica de escrita encontrada.');
    }
    _txChar = writeChar;

    if (notifyChar != null) {
      _notifySub = _ble.subscribeToCharacteristic(notifyChar).listen((data) {
        _onNotifyData(data);
      }, onError: (error) {
        onLog('Erro no stream BLE: $error');
      });
      onLog('Inscrito para notificações BLE.');
    } else {
      onLog('Aviso: característica de notificação não encontrada. Apenas envio disponível.');
    }
  }

  void _onNotifyData(List<int> data) {
    final chunk = utf8.decode(data, allowMalformed: true);
    _rxBuffer += chunk;
    while (true) {
      final newlineIndex = _rxBuffer.indexOf(RegExp(r'[\r\n]'));
      if (newlineIndex == -1) {
        break;
      }
      final line = _rxBuffer.substring(0, newlineIndex).trim();
      if (line.isNotEmpty) {
        _lines.add(line);
      }
      _rxBuffer = _rxBuffer.substring(newlineIndex + 1);
    }
  }

  Future<void> writeLine(String command) async {
    final characteristic = _txChar;
    if (characteristic == null) {
      throw Exception('Canal de escrita BLE ainda não pronto.');
    }
    final payload = utf8.encode('$command\n');
    await _ble.writeCharacteristicWithResponse(characteristic, value: payload);
  }

  Future<void> disconnect() async {
    await _scanSub?.cancel();
    await _notifySub?.cancel();
    await _connSub?.cancel();
    _scanSub = null;
    _notifySub = null;
    _connSub = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _lines.close();
  }
}
