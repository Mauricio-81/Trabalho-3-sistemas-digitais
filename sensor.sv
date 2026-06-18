module sensor #(
    parameter SENSOR_ID = 0,
    parameter REG_COUNT = 2,
    parameter REG_WIDTH = 8
)(
    input  logic clock,
    input  logic reset,

    input  logic se,
    output logic miso,
    input  logic mosi,
    input  logic sclk
);

    // Lista de registradores
    logic [REG_WIDTH-1:0] regs [REG_COUNT-1:0];

    // Registrador de deslocamento
    logic [(REG_WIDTH * REG_COUNT)-1:0] temp_reg;

    // Contador de bits
    logic [4:0] bit_counter;

    logic [31:0] clk_div;
    
    // FSM SPI
    typedef enum logic [2:0] {
        IDLE,
        SETUP,
        RECEIVE,
        SEND,
        CLEANUP
    } state_t;

    state_t EA, PE;

    //--------------------------------------------------
    // Atualização dos registradores internos do sensor
    //--------------------------------------------------
    always_ff @(posedge clock or negedge reset) begin
        if (reset == 0) begin
            clk_div <= 0;

            for (int i = 0; i < REG_COUNT; i++) begin
                regs[i] <= SENSOR_ID + i;
            end
        end
        else begin
            clk_div <= clk_div + 1;

            if (clk_div == 32'd100_000) begin
                clk_div <= 0;

                regs[0] <= regs[0] + 1'b1;
                regs[1] <= SENSOR_ID;
            end
        end
    end

    //--------------------------------------------------
    // Atualização do estado atual
    //--------------------------------------------------
    always_ff @(posedge sclk or negedge reset) begin
        if (reset == 0)
            EA <= IDLE;
        else
            EA <= PE;
    end

    //--------------------------------------------------
    // Lógica de próximo estado
    //--------------------------------------------------
    always_comb begin
        PE = EA;

        case (EA)

            IDLE: begin
                if (se == 1'b1)
                    PE = SETUP;
            end

            SETUP: begin
                PE = SEND;
            end

            SEND: begin
                if (bit_counter == 0)
                    PE = CLEANUP;
            end

            CLEANUP: begin
                if (se == 1'b0)
                    PE = IDLE;
            end

            default: begin
                PE = IDLE;
            end

        endcase
    end

    //--------------------------------------------------
    // Transmissão SPI
    //--------------------------------------------------
    always_ff @(negedge sclk or negedge reset) begin

        if (reset == 0) begin

            temp_reg    <= '0;
            bit_counter <= (REG_WIDTH * REG_COUNT) - 1;
            miso        <= 1'b0;

        end
        else begin

            case (EA)

                IDLE: begin

                    miso <= 1'b0;

                    bit_counter <= (REG_WIDTH * REG_COUNT) - 1;

                end

                SETUP: begin

                    temp_reg <= {regs[1], regs[0]};

                    // Disponibiliza o primeiro bit imediatamente
                    miso <= {regs[1], regs[0]}[(REG_WIDTH * REG_COUNT)-1];

                    // Reinicia o contador para uma nova transmissão
                    bit_counter <= (REG_WIDTH * REG_COUNT) - 1;

                end

                SEND: begin

                    // Envia o MSB atual
                    miso <= temp_reg[(REG_WIDTH * REG_COUNT)-1];

                    // Desloca para o próximo bit
                    temp_reg <= {
                        temp_reg[(REG_WIDTH * REG_COUNT)-2:0],
                        1'b0
                    };

                    if (bit_counter > 0)
                        bit_counter <= bit_counter - 1;

                end

                CLEANUP: begin

                    miso <= 1'b0;

                end

            endcase

        end

    end

endmodule
