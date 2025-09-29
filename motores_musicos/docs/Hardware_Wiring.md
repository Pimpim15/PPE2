# Hardware wiring e pinagem

Resumo rápido das ligações para Arduino UNO R3 + CNC Shield V3 + 4 drivers A4988 + HM-10 (BLE):

Componentes:
- Arduino UNO R3
- CNC Shield V3 (montado sobre o UNO)
- 4x drivers A4988 (com dissipadores)
- 4x motores de passo NEMA (2 fases)
- HM-10 (módulo BLE 4.0 GATT/UART)
- Fonte 12 V (≥5 A) para os motores

Conexões HM-10 (pinos): STATE, VCC, GND, TXD, RXD, BRK/KEY

- VCC -> 5V (do UNO)
- GND -> GND (comum)
- TXD (HM-10) -> D10 (SoftwareSerial RX)
- RXD (HM-10) <- D11 (SoftwareSerial TX) via divisor 5V->3V3 (ex.: 1k série + 2k para GND)
- STATE (opcional) -> D9 (input para detectar estado de conexão). OBS: D12 foi evitado aqui pois muitas CNC shields usam D12 para A STEP — usar D9 evita conflito.
- BRK/KEY -> deixar solto

CNC Shield (pinos padrão UNO+CNC Shield):
- Eixo X: STEP D2, DIR D5
- Eixo Y: STEP D3, DIR D6
- Eixo Z: STEP D4, DIR D7
- Eixo A: STEP D12, DIR D13
- EN: D8 (ativo em LOW)

Alimentação motores:
- Conectar 12 V (≥5 A) ao borne de alimentação do CNC Shield.
- GND da fonte 12 V deve ser comum com o GND do UNO.

Notas de segurança e calibração:
- Ajuste a corrente dos A4988 girando o potenciômetro enquanto mede a tensão no pino Vref conforme o datasheet do driver; mantenha motores mornos.
- Use dissipadores e ventilação.
- Verifique microstepping (jumpers) no CNC Shield para comportamento esperado.

Diagrama lógico (texto):

- UNO D2 -> CNC X STEP
- UNO D5 -> CNC X DIR
- UNO D3 -> CNC Y STEP
- UNO D6 -> CNC Y DIR
- UNO D4 -> CNC Z STEP
- UNO D7 -> CNC Z DIR
- UNO D12 -> CNC A STEP AND HM-10 STATE (note: if used, avoid conflict; here D12 used for A STEP on many CNC shields so ensure routing)
- UNO D13 -> CNC A DIR
- UNO D8 -> CNC EN (LOW to enable)

Importante: Alguns shields usam D12/D13 para SPI/LED; confirme que não conflita com outros shields/peripherals.
