# Firmware (Arduino UNO) - motores_musicos

Use PlatformIO in VS Code.

Build: `pio run`
Upload: `pio run -t upload`

Serial monitor: 115200 bps. HM-10 uses 9600 bps on SoftwareSerial (D10 RX, D11 TX).

Protocol: ASCII lines terminated with \n. Commands: PING, PLAY IMP, DEMO, PAUSE, RESUME, STOP, SPD <0..100>.
