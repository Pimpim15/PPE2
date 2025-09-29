import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});
  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  double _spd = 100;
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Controles')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Wrap(spacing:8, children: [
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('PING') : null, child: const Text('PING')),
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('PLAY IMP') : null, child: const Text('PLAY IMP')),
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('DEMO') : null, child: const Text('DEMO')),
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('PAUSE') : null, child: const Text('PAUSE')),
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('RESUME') : null, child: const Text('RESUME')),
            ElevatedButton(onPressed: st.status==AppStatus.connected? () => st.send('STOP') : null, child: const Text('STOP')),
          ]),
          const SizedBox(height:12),
          Row(children: [const Text('SPD'), Expanded(child: Slider(value: _spd, min:0, max:100, divisions:100, label: _spd.round().toString(), onChanged: (v) { setState(() { _spd=v; }); }, onChangeEnd: (v) { st.send('SPD ${v.round()}'); }))]),
          const SizedBox(height:12),
          Expanded(child: SingleChildScrollView(child: Text(st.log)))
        ]),
      ),
    );
  }
}
