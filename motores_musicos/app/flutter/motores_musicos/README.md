# Motores Musicos - Flutter app

Aplicativo Flutter que se conecta via BLE a um módulo HM-10 para enviar comandos ASCII (terminados em `\n`) ao firmware dos motores.

## Pré-requisitos

- Flutter SDK instalado (3.x ou superior). Siga as instruções oficiais: <https://docs.flutter.dev/get-started/install>.
- Android SDK / ferramentas de linha de comando (instaladas com o Android Studio ou `sdkmanager`).
- Dispositivo Android com modo desenvolvedor e depuração USB ativados.
- Variável de ambiente `PATH` configurada com o diretório `flutter/bin`.

## Configuração do projeto

1. No diretório `motores_musicos/app/flutter/motores_musicos` execute:
	```bash
	flutter doctor
	flutter pub get
	```
	Resolva qualquer alerta exibido pelo `flutter doctor` (permissões USB, licenças do Android SDK etc.).

2. Para rodar no Android, aceite as licenças do SDK:
	```bash
	flutter doctor --android-licenses
	```

3. Conecte um dispositivo Android por USB ou inicie um emulador, depois execute:
	```bash
	flutter run -d <id_do_dispositivo>
	```

## Permissões

O app solicita automaticamente as permissões necessárias em tempo de execução (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `ACCESS_FINE_LOCATION`). Certifique-se de aceitá-las ao iniciar o app no Android 12+.

## Funcionamento

1. Na tela inicial toque em **Procurar e conectar**. O app buscará um dispositivo cujo nome contenha `HM`, `HMSoft` ou `HM-10` e conectará automaticamente.
2. Após a conexão, toque em **Controles** para acessar a tela de comandos (play, pause, stop, velocidade etc.).
3. A área de log mostra todo o tráfego BLE (TX/RX) com carimbo de data/hora para facilitar depuração.

## Estrutura

- `lib/ble/ble_client.dart`: lógica central de BLE (scan, conexão, notificações e envio).
- `lib/state/app_state.dart`: gerenciamento de estado, permissões, logs e integração com UI.
- `lib/ui/…`: telas do app (home e painel de controles).

## Próximos passos sugeridos

- Configurar builds para iOS (Info.plist com mensagens de uso de Bluetooth e ajustes no Podfile).
- Criar testes widget/unit para validar o fluxo de estado e comandos.
- Automatizar o build com GitHub Actions ou pipelines semelhantes para Flutter.
