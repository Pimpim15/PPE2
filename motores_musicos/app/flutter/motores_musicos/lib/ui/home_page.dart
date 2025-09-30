import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'controls_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final isConnected = st.isConnected;
    return Scaffold(
      appBar: AppBar(title: const Text('Motores Musicos')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${st.status.name}'),
              if (st.deviceName.isNotEmpty)
                Text('Dispositivo: ${st.deviceName}'),
            ],
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: st.isBusy ? null : () async { await st.scanAndConnect(); },
              child: const Text('Procurar e conectar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isConnected ? () async { await st.disconnect(); } : null,
              child: const Text('Desconectar'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isConnected
                  ? () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ControlsPage()));
                    }
                  : null,
              child: const Text('Controles'),
            ),
            if (st.isBusy) ...[
              const SizedBox(width: 12),
              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(child: Text(st.log))),
      ]),
    );
  }
}
