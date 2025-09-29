motorres_musicos

Este repositório contém dois projetos integrados para tocar movimentos coreografados ("Marcha Imperial") em 4 motores de passo via CNC Shield + A4988 e controle por Bluetooth Low Energy (HM-10).

Estrutura:

- `firmware/` — PlatformIO (Arduino UNO) com player, parser BLE e partituras.
- `app/flutter/motores_musicos/` — App Flutter (Android) que conecta ao HM-10 via BLE e envia comandos.
- `docs/Hardware_Wiring.md` — diagrama e pinagem.
- `.vscode/` — tasks, launch e settings para facilitar build/debug no VS Code.

Rápido (resumo dos passos):
1. Abrir VS Code.
2. Instalar as extensões recomendadas (PlatformIO, Flutter, Dart).
3. Conectar o hardware: ver `docs/Hardware_Wiring.md`.
4. Subir firmware: executar a task `pio:upload` no VS Code (PlatformIO deve estar instalado).
5. Rodar app: em `app/flutter/motores_musicos/`, executar `flutter pub get` e `flutter run -d <device>` ou usar a task `flutter:run`.

Comandos rápidos (PowerShell):
```
cd .\motores_musicos\firmware; pio run
cd ..\app\flutter\motores_musicos; flutter pub get; flutter run -d <device>
```

Documentação detalhada e instruções de hardware estão em `docs/Hardware_Wiring.md`.
