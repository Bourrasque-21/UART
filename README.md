# UART

## Overview

SystemVerilog로 구현한 UART RX/TX 기반 Loopback 설계. UART로 수신한 데이터를 RX FIFO와 TX FIFO를 통해 전달한 후 동일한 데이터를 다시 송신함.

100 MHz 시스템 클럭과 16배 oversampling을 기준으로 UART 8N1 통신을 수행하며, UVM testbench에서 random data, corner pattern 및 baud rate 오차 조건을 검증함.

## Specifications

- UART 8N1 통신
- 8비트 data
- LSB First 전송
- 1 Start bit 및 1 Stop bit
- Parity 없음
- 16배 oversampling
- 기본 Baud Rate 115,200 bps
- RX input 2-FF synchronizer
- RX FIFO 및 TX FIFO
- Parameter 기반 Baud Rate와 FIFO 설정
- Synopsys VCS/Verdi 및 UVM 기반 기능 검증
- 입력 baud period `+2%`, `-2%`, `+4%`, `-4%` 검증

## System Architecture

`uart_top`에서 UART RX, RX FIFO, TX FIFO, UART TX 및 Baud Generator를 통합함.

`uart_rx`에서 한 byte 수신이 완료되면 데이터를 RX FIFO에 저장함. RX FIFO에 데이터가 존재하고 TX FIFO가 Full 상태가 아니면 데이터를 TX FIFO로 이동함. `uart_tx`가 Idle 상태이고 TX FIFO에 데이터가 존재하면 자동으로 다음 byte를 송신함.

## Top Module

`rtl/uart_top.sv`의 parameter는 다음과 같음.

| Parameter | 기본값 | 설명 |
| --- | --- | --- |
| `BAUDRATE` | `115200` | UART Baud Rate |
| `DEPTH` | `4` | RX/TX FIFO Depth |
| `D_WIDTH` | `8` | FIFO Data Width |

| 신호 | 방향 | 설명 |
| --- | --- | --- |
| `clk` | Input | 100 MHz 시스템 클럭 |
| `rst` | Input | Active-High Reset |
| `rx` | Input | UART Serial Input |
| `tx` | Output | UART Serial Output |

## UART Transmitter

`rtl/uart_tx.sv`는 `IDLE`, `START`, `DATA`, `STOP` 상태로 구성함.

`tx_start` 입력 시 `tx_data`를 내부 buffer에 저장함. Start bit를 Low로 출력한 후 8비트 데이터를 LSB First 방식으로 전송하고 Stop bit를 High로 출력함.

각 bit는 16개의 `b_tick` 동안 유지함. 전송 중에는 `tx_busy`를 출력하고 Stop bit 전송이 완료되면 `tx_done`을 출력함.

## UART Receiver

`rtl/uart_rx.sv`는 RX 입력을 2-FF synchronizer로 동기화한 후 Start bit를 검출함.

Start bit 진입 후 8번째 `b_tick`에서 bit 중앙값을 확인함. 이후 16개의 `b_tick` 간격으로 8개의 data bit를 sampling함. Stop bit가 High인 경우 수신 데이터를 `rx_data`에 저장하고 `rx_done`을 출력함.

## Baud Generator

`rtl/baud_gen.sv`에서 100 MHz 시스템 클럭을 기준으로 UART Baud Rate의 16배 주파수를 갖는 `b_tick`을 생성함.

```text
F_COUNT = 100_000_000 / (BAUDRATE x 16)
```

기본 `BAUDRATE`가 115,200 bps인 경우 TX와 RX는 동일한 `b_tick`을 이용하여 frame timing을 제어함.

## FIFO Architecture

`rtl/fifo.sv`는 `fifo`, `fifo_mem`, `fifo_ctrl` 모듈로 구성함.

| 모듈 | 기능 |
| --- | --- |
| `fifo` | FIFO top 및 memory/control 연결 |
| `fifo_mem` | Data 저장 및 read 출력 |
| `fifo_ctrl` | Read/Write pointer와 Full/Empty 상태 관리 |

Read와 Write가 동시에 발생하는 경우 두 pointer를 함께 증가시킴. FIFO가 Full 상태이더라도 동일 cycle에 정상적인 Read가 발생하면 Write를 함께 수행함.

## UART Frame

```text
Idle(1) -> Start(0) -> D0 -> D1 -> D2 -> D3 -> D4 -> D5 -> D6 -> D7 -> Stop(1)
```

| 항목 | 설정 |
| --- | --- |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Bit Order | LSB First |

## Verification

Synopsys VCS에서 UVM testbench를 실행하고 FSDB 파형을 생성하여 Verdi에서 동작과 Coverage를 확인함. UVM Driver에서 UART frame을 생성하여 DUT의 `rx`에 입력하고, Monitor에서 DUT의 `tx` frame을 복원하여 Scoreboard에서 입력 데이터와 출력 데이터를 순서대로 비교함.

| Test | 검증 내용 |
| --- | --- |
| `uart_smoke_test` | 256개의 Random Data |
| `uart_corner_test` | `00`, `FF`, `55`, `AA`, `01`, `80`, `7F` |
| `uart_alt_test` | `55`, `AA` Alternating Pattern |
| `uart_baud_plus2_test` | RX 입력 bit period `+2%` |
| `uart_baud_minus2_test` | RX 입력 bit period `-2%` |
| `uart_baud_plus4_test` | RX 입력 bit period `+4%` |
| `uart_baud_minus4_test` | RX 입력 bit period `-4%` |

Functional Coverage에서 `00`, `FF`, `AA`, `55`와 Low, Mid, High data 영역을 검증함.

## Verification Results

모든 시뮬레이션은 100 MHz 시스템 클럭과 115,200 bps를 기준으로 수행함.

Random data를 이용한 Smoke Test, 경계값 중심의 Corner Test 및 `0x55`, `0xAA` 반복 패턴을 이용한 Alternating Test를 수행함.

각 테스트에서 UART RX로 입력한 데이터와 Loopback 이후 UART TX로 출력된 데이터를 Scoreboard에서 비교함. 기본 기능 및 패턴 검증에서는 모든 transaction이 데이터 유실이나 변형 없이 일치하여 100% Pass 결과를 확인함.

| 검증 대상 | Test | 결과 | Coverage |
| --- | --- | --- | --- |
| UART Loopback | `uart_smoke_test` | Pass | ≈ 71% |
| UART Loopback | `uart_corner_test` | Pass | - |
| UART Loopback | `uart_alt_test` | Pass | - |

Smoke Test는 256개의 Random Data를 검증하여 ≈ 71%의 Functional Coverage를 달성함. Corner Test에서는 경계값과 주요 bit pattern을, Alternating Test에서는 `0x55`, `0xAA` 반복 전환 패턴을 검증함.

### Baud Rate Mismatch Test

RX 입력 frame의 bit period에 인위적인 오차를 적용하여 송신측과 수신측의 baud timing이 일치하지 않는 조건을 검증함.

| 입력 Bit Period | Test | 결과 |
| --- | --- | --- |
| 기준값 | `uart_smoke_test` | Pass |
| `+2%` | `uart_baud_plus2_test` | Pass |
| `-2%` | `uart_baud_minus2_test` | Pass |
| `+4%` | `uart_baud_plus4_test` | Pass |
| `-4%` | `uart_baud_minus4_test` | Fail |

`+2%`, `-2%` 및 `+4%` 조건에서는 입력 데이터와 Loopback 출력이 일치함. `-4%` 조건에서는 256개의 frame을 연속 입력할 때 RX 입력 속도가 DUT의 TX 출력 속도보다 빨라져 FIFO에 데이터가 누적되고, 버퍼 포화로 일부 수신 바이트가 저장되지 않아 54건의 Mismatch와 3건의 Pending이 발생함.

`-4%` 조건의 Mismatch와 Pending은 RX 복원 오류가 아니라, 입력 속도 증가로 FIFO가 포화되어 일부 바이트가 유실되고 Scoreboard 비교 순서가 어긋나 발생함. 각 frame은 Start bit마다 수신 시점을 다시 판별하므로, 해당 결과는 frame 간 timing 오차 누적보다 연속 Loopback 환경의 처리율과 FIFO 수용 범위에 따른 결과임.

`-4%` 조건의 초기 frame은 정상적으로 처리되었고 Fail 원인이 RX sampling 오류가 아닌 FIFO 포화로 분석됨. 이에 따라 FIFO 영향을 제외한 단일 frame 환경에서는 `±4%` baud rate 오차까지 수신 가능할 것으로 예상됨.

## Directory Structure

```text
UART/
├── rtl/
│   ├── uart_top.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   ├── baud_gen.sv
│   └── fifo.sv
└── tb/
    ├── tb_uart_top.sv
    ├── uart_pkg.sv
    ├── uart_if.sv
    ├── uart_seq_item.sv
    ├── uart_seq.sv
    ├── uart_drv.sv
    ├── uart_mon.sv
    ├── uart_agt.sv
    ├── uart_scb.sv
    ├── uart_cov.sv
    ├── uart_env.sv
    └── uart_test.sv
```
