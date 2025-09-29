import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'controls_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Motores Musicos')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Status: ${st.status}')),
        Row(children: [
          ElevatedButton(onPressed: () async { await st.startScan(); }, child: const Text('Procurar HM-10')),
          const SizedBox(width:8),
          ElevatedButton(onPressed: st.client!=null ? () async { await st.connect(); } : null, child: const Text('Conectar')),
          const SizedBox(width:8),
          ElevatedButton(onPressed: st.status==AppStatus.connected ? () { Navigator.push(context, MaterialPageRoute(builder: (_) => const ControlsPage())); } : null, child: const Text('Controles')),
        ],),
        Expanded(child: SingleChildScrollView(child: Text(st.log))),
      ],),
    );
  }
}
