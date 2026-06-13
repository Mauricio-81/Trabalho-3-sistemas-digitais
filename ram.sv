module ram ( // <-- O nome do módulo mudou aqui!
    input  logic       clk,      // Clock de 100MHz
    input  logic       we,       // Write Enable (Permissão de escrita)
    input  logic [7:0] addr,     // Endereço de 8 bits (0 a 255)
    input  logic [7:0] data_i,   // Dado de entrada (vem do Coletor)
    output logic [7:0] data_o    // Dado de saída
);

    // Declaração da matriz de memória: 256 posições de 8 bits
    logic [7:0] memoria [0:255];

    // Bloco de escrita e leitura síncrona
    always_ff @(posedge clk) begin
        if (we) begin
            memoria[addr] <= data_i; // Escreve o dado no endereço se 'we' estiver ativo
        end
        data_o <= memoria[addr];     // A leitura é contínua e síncrona
    end

endmodule