/***************************************************************************
 * Module: neural_accelerator_unit
 * Description: Interface sequencial com registradores internos para o
 *              miniacelerador combinacional neural_accelerator.
 *              - acc_load_i: armazena sequencialmente (x1, w1) e depois
 *                (x2, w2) a partir dos 8 bits menos significativos de
 *                op_a_i (rs1) e op_b_i (rs2).
 *              - acc_clear_i (opcional): reseta o seletor de par para 0.
 *              - result_o: saida de 32 bits com sinal vinda da ReLU.
 ***************************************************************************/
module neural_accelerator_unit
(
    input  logic               clk_i,
    input  logic               reset_i,
    input  logic               acc_load_i,
    input  logic signed [31:0] op_a_i,
    input  logic signed [31:0] op_b_i,
    output logic signed [31:0] result_o
);

    logic signed [7:0] x1_reg, w1_reg;
    logic signed [7:0] x2_reg, w2_reg;
    logic              pair_sel; // 0 = carrega par 1 (x1, w1), 1 = carrega par 2 (x2, w2)

    always_ff @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            x1_reg   <= 8'sd0;
            w1_reg   <= 8'sd0;
            x2_reg   <= 8'sd0;
            w2_reg   <= 8'sd0;
            pair_sel <= 1'b0;
        end else if (acc_load_i) begin
            if (!pair_sel) begin
                x1_reg   <= op_a_i[7:0];
                w1_reg   <= op_b_i[7:0];
                pair_sel <= 1'b1;
            end else begin
                x2_reg   <= op_a_i[7:0];
                w2_reg   <= op_b_i[7:0];
                pair_sel <= 1'b0;
            end
        end
    end

    neural_accelerator u_accel (
        .x1_i (x1_reg),
        .w1_i (w1_reg),
        .x2_i (x2_reg),
        .w2_i (w2_reg),
        .y_o  (result_o)
    );

endmodule