# Sistema de Coleta de Dados com Comunicação SPI

## Descrição

Este projeto implementa um sistema de aquisição de dados em SystemVerilog composto por um Coletor de Dados (CD), quatro Emuladores de Sensores (ES), uma memória RAM e um Testbench para validação do funcionamento do sistema.

O objetivo é realizar a leitura periódica dos sensores através de um barramento SPI e armazenar os dados recebidos em uma memória RAM para posterior verificação.

---

## Arquitetura do Sistema

O sistema é composto pelos seguintes módulos:

### Coletor de Dados (coletor_dados.sv)

Responsável por:

* Selecionar um dos sensores através do sinal `se`.
* Gerar o clock SPI (`sclk`).
* Receber os dados serializados pelo sinal `miso`.
* Reconstruir os dados recebidos utilizando um registrador de deslocamento.
* Escrever os dados recebidos na memória RAM.
* Informar ao Testbench quando está pronto para uma nova operação através do sinal `ready`.

### Emuladores de Sensores (sensor.sv)

Cada sensor possui:

* Clock próprio e independente.
* Registradores internos contendo os dados simulados.
* Interface SPI do tipo Slave.
* Transmissão serial dos dados através do sinal `miso`.

Os sensores são parametrizados através dos parâmetros:

* `SENSOR_ID`
* `REG_COUNT`
* `REG_WIDTH`

### Memória RAM (ram.sv)

Memória síncrona de:

* 256 posições.
* 8 bits por posição.

Sinais principais:

* `addr` – endereço de acesso.
* `data_i` – dado de entrada.
* `data_o` – dado de saída.
* `we` – habilitação de escrita.

### Módulo Top (top.sv)

Responsável pela integração de todos os componentes:

* Coletor de Dados.
* RAM.
* Quatro sensores.
* Interface com o Testbench.

### Testbench (tb.sv)

Responsável por:

* Gerar todos os clocks do sistema.
* Aplicar reset.
* Solicitar leituras dos sensores.
* Verificar os dados armazenados na memória.
* Validar o funcionamento do sistema.

---

## Frequências Utilizadas

| Sinal      | Frequência |
| ---------- | ---------- |
| clk_100mhz | 100 MHz    |
| clk_50mhz  | 50 MHz     |
| clk_40mhz  | 40 MHz     |
| clk_25mhz  | 25 MHz     |
| clk_15mhz  | 15 MHz     |

---

## Fluxo de Operação

1. O Testbench solicita a leitura de um sensor.
2. O Coletor de Dados seleciona o sensor desejado.
3. O sensor transmite seus dados através da interface SPI.
4. O Coletor recebe os bits serialmente.
5. Os dados recebidos são armazenados na memória RAM.
6. O processo é repetido para os demais sensores.

---

## Arquivos do Projeto

* `top.sv`
* `coletor_dados.sv`
* `sensor.sv`
* `ram.sv`
* `tb.sv`

---

## Como Executar

1. Compilar todos os arquivos SystemVerilog.
2. Executar a simulação.
3. Abrir o Waveform Viewer.
4. Verificar os sinais:

   * `sclk`
   * `se`
   * `miso`
   * `ram_we`
   * `ram_addr`
   * `ram_data`
5. Conferir os valores gravados na memória RAM.

---

## Resultados

Durante a simulação foi possível observar:

* Seleção correta dos sensores.
* Comunicação SPI funcional.
* Recepção serial dos dados.
* Escrita correta dos dados na memória RAM.
* Funcionamento das máquinas de estados dos módulos.

O sistema demonstrou a integração entre múltiplos domínios de clock, comunicação serial SPI e armazenamento dos dados recebidos em memória.
