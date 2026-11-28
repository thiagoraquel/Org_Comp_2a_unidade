/***************************************************************************
 * Module: tb_neural_accelerator
 * Description: Testbench para validar o modulo combinacional neural_accelerator.
 *              Testa casos positivos, negativos com ReLU (virando 0), zero
 *              e valores extremos de 8 bits com sinal (-128 a +127).
 ***************************************************************************/
`timescale 1ns/1ps

module tb_neural_accelerator;

    logic signed [7:0]  x1_tb;
    logic signed [7:0]  w1_tb;
    logic signed [7:0]  x2_tb;
    logic signed [7:0]  w2_tb;
    logic signed [31:0] y_tb;

    // Instancia o modulo a ser testado (DUT = Device Under Test)
    neural_accelerator dut (
        .x1_i (x1_tb),
        .w1_i (w1_tb),
        .x2_i (x2_tb),
        .w2_i (w2_tb),
        .y_o  (y_tb)
    );

    integer erros = 0;

    // Task auxiliar para aplicar um caso de teste e conferir o resultado
    task automatic testar_caso(
        input string             nome_caso,
        input logic signed [7:0]  x1,
        input logic signed [7:0]  w1,
        input logic signed [7:0]  x2,
        input logic signed [7:0]  w2,
        input logic signed [31:0] esperado
    );
        begin
            x1_tb = x1;
            w1_tb = w1;
            x2_tb = x2;
            w2_tb = w2;

            #10; // Espera 10ns para a logica combinacional estabilizar

            if (y_tb !== esperado) begin
                $display("[ERRO] %s | x1=%0d, w1=%0d, x2=%0d, w2=%0d -> Obtido=%0d, Esperado=%0d",
                         nome_caso, x1, w1, x2, w2, y_tb, esperado);
                erros = erros + 1;
            end else begin
                $display("[OK]   %s | x1=%0d, w1=%0d, x2=%0d, w2=%0d -> y=%0d",
                         nome_caso, x1, w1, x2, w2, y_tb);
            end
        end
    endtask

    initial begin
        $display("=== Iniciando testes do neural_accelerator ===");

        // 1. Soma positiva: (3*4) + (2*5) = 12 + 10 = 22 -> ReLU = 22
        testar_caso("Soma positiva", 8'sd3, 8'sd4, 8'sd2, 8'sd5, 32'sd22);

        // 2. Soma negativa: (2*-3) + (1*-4) = -6 + (-4) = -10 -> ReLU zera = 0
        testar_caso("Soma negativa (ReLU -> 0)", 8'sd2, -8'sd3, 8'sd1, -8'sd4, 32'sd0);

        // 3. Soma exatamente zero: (5*2) + (-5*2) = 10 + (-10) = 0 -> ReLU = 0
        testar_caso("Soma zero", 8'sd5, 8'sd2, -8'sd5, 8'sd2, 32'sd0);

        // 4. Um termo negativo e outro positivo maior: (-4*3) + (5*4) = -12 + 20 = 8
        testar_caso("Misto positivo", -8'sd4, 8'sd3, 8'sd5, 8'sd4, 32'sd8);

        // 5. Um termo positivo e outro negativo maior: (2*3) + (-6*4) = 6 + (-24) = -18 -> ReLU = 0
        testar_caso("Misto negativo (ReLU -> 0)", 8'sd2, 8'sd3, -8'sd6, 8'sd4, 32'sd0);

        // 6. Valores extremos positivos: (127*127) + (127*127) = 16129 + 16129 = 32258
        testar_caso("Maximo positivo", 8'sd127, 8'sd127, 8'sd127, 8'sd127, 32'sd32258);

        // 7. Valores extremos negativos multiplicando entre si: (-128*-128) + (-128*-128) = 16384 + 16384 = 32768
        testar_caso("Minimo x Minimo", -8'sd128, -8'sd128, -8'sd128, -8'sd128, 32'sd32768);

        // 8. Extremo negativo x positivo: (-128*127) + (-128*1) = -16256 + (-128) = -16384 -> ReLU = 0
        testar_caso("Extremo negativo (ReLU -> 0)", -8'sd128, 8'sd127, -8'sd128, 8'sd1, 32'sd0);

        $display("=============================================");
        if (erros == 0) begin
            $display("SUCESSO! Todos os testes passaram sem erros.");
        end else begin
            $display("FALHA! Total de erros encontrados: %0d", erros);
        end
        $display("=============================================");

        $stop;
    end

endmodule