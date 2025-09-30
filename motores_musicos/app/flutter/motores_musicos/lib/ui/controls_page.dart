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
    final isConnected = st.isConnected;
    return Scaffold(
      appBar: AppBar(title: const Text('Controles')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Wrap(spacing:8, children: [
            ElevatedButton(onPressed: isConnected ? () => st.send('PING') : null, child: const Text('PING')),
            ElevatedButton(onPressed: isConnected ? () => st.send('PLAY IMP') : null, child: const Text('PLAY IMP')),
            ElevatedButton(onPressed: isConnected ? () => st.send('DEMO') : null, child: const Text('DEMO')),
            ElevatedButton(onPressed: st.status==AppStatus.playing ? () => st.send('PAUSE') : null, child: const Text('PAUSE')),
            ElevatedButton(onPressed: st.status==AppStatus.paused ? () => st.send('RESUME') : null, child: const Text('RESUME')),
            ElevatedButton(onPressed: isConnected ? () => st.send('STOP') : null, child: const Text('STOP')),
          ]),
          const SizedBox(height:12),
          Row(children: [
            const Text('SPD'),
            Expanded(
              child: Slider(
                value: _spd,
                min: 0,
                max: 100,
                divisions: 100,
                label: _spd.round().toString(),
                onChanged: isConnected
                    ? (value) {
                        setState(() {
                          _spd = value;
                        });
                      }
                    : null,
                onChangeEnd: isConnected
                    ? (value) {
                        st.send('SPD ${value.round()}');
                      }
                    : null,
              ),
            ),
          ]),
          const SizedBox(height:12),
          Expanded(child: SingleChildScrollView(child: Text(st.log)))
        ]),
      ),
    );
  }
}
