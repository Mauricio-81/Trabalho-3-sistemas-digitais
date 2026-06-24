module top_fpga (
    input  logic clock,
    input  logic reset,
    input  logic ssl,
    input  logic ssr,

    input  logic [15:0] SW,
    output logic [15:0] LED,

    output logic [7:0] DDP,
    output logic [7:0] AN
);

    logic rst_n;
    logic ready_tb;
    logic start_tb;
    logic [1:0] reg_id_tb;

    logic clk_15mhz;
    logic clk_25mhz;
    logic clk_40mhz;
    logic clk_50mhz;
    logic clk_100mhz;

    logic locked;

    clk_wiz_0 clk_gen (
        .clk_in1  (clock),
        .reset    (reset),

        .clk_out1 (clk_15mhz),
        .clk_out2 (clk_25mhz),
        .clk_out3 (clk_40mhz),
        .clk_out4 (clk_50mhz),
        .clk_out5 (clk_100mhz),

        .locked   (locked)
    );

    assign rst_n = locked & ~reset;

    assign start_tb  = ssl;
    assign reg_id_tb = SW[1:0];

    top u_top (
        .rst        (rst_n),

        .clk_15mhz  (clk_15mhz),
        .clk_25mhz  (clk_25mhz),
        .clk_40mhz  (clk_40mhz),
        .clk_50mhz  (clk_50mhz),
        .clk_100mhz (clk_100mhz),

        .ready_tb  (ready_tb),
        .start_tb  (start_tb),
        .reg_id_tb (reg_id_tb)
    );

    assign LED[0]    = ready_tb;
    assign LED[1]    = start_tb;
    assign LED[3:2]  = reg_id_tb;
    assign LED[4]    = ssr;
    assign LED[15:5] = SW[15:5];

    assign DDP = 8'hFF;
    assign AN  = 8'hFF;

endmodule
