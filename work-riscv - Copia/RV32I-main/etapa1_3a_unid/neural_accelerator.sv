/***************************************************************************
 * Module: neural_accelerator
 * Description: Miniacelerador combinacional de neuronio artificial com
 *              2 multiplicadores de 8 bits com sinal, soma e ativacao ReLU.
 *              Calcula y = max(0, x1*w1 + x2*w2) com saida de 32 bits.
 ***************************************************************************/
module neural_accelerator
(
    input  logic signed [7:0]  x1_i,
    input  logic signed [7:0]  w1_i,
    input  logic signed [7:0]  x2_i,
    input  logic signed [7:0]  w2_i,
    output logic signed [31:0] y_o
);

    logic signed [15:0] prod1;
    logic signed [15:0] prod2;
    logic signed [31:0] acc_sum;

    // 1. Duas multiplicacoes em paralelo (8b x 8b com sinal -> 16b com sinal)
    always_comb begin
        prod1 = x1_i * w1_i;
        prod2 = x2_i * w2_i;
    end

    // 2. Soma dos produtos em 32 bits com sinal
    always_comb begin
        acc_sum = 32'(prod1) + 32'(prod2);
    end

    // 3. Funcao de ativacao ReLU: max(0, acc_sum)
    always_comb begin
        if (acc_sum < 32'sd0) begin
            y_o = 32'sd0;
        end else begin
            y_o = acc_sum;
        end
    end

endmodule