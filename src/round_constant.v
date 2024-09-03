`timescale 1ns / 1ps
module round_constant(
    input clk, //Tín hiệu xung nhịp (clock) điều khiển hoạt động của module.
    input start, //Tín hiệu bắt đầu, khi start được kích hoạt, quá trình tạo hằng số vòng bắt đầu.
    input rst, // Tín hiệu đặt lại (reset), khi rst được kích hoạt, module sẽ khởi động lại và reset các giá trị.
    input [3:0] rounds, //Đầu vào chứa số vòng (rounds) sẽ được thực hiện.
    output reg [7:0] r_con, // Hằng số vòng được tạo ra (8-bit).
    output reg done, //Tín hiệu báo hiệu khi quá trình hoàn thành.
    output reg init // Tín hiệu báo hiệu khi bắt đầu một vòng mới.
);
    reg [3:0] count; //khai báo biến bên trong, dùng để đếm số vòng hiện tại.

    always @ (posedge clk) begin //kích hoạt theo cạnh dương của clk
        if (rst) // Khi rst được kích hoạt, bộ đếm (count) và hằng số vòng (r_con) được đặt lại về 0.       
        begin
            count = 0;
            r_con = 0;
        end
        else if (start)
        begin
          if (count == 0) //Nếu count bằng 0, init được kích hoạt và done được đặt lại.
          begin
              init = start;
              done = 0;
          end
          else
              init = 0;

          count = count + 1; //Tăng count lên 1.
          r_con = 4'hf0 - 15*(count + 12 - rounds) - 1; //Tính giá trị mới cho r_con: r_con = 4'hf0 - 15*(count + 12 - rounds) - 1;. Đây là cách tính hằng số vòng cho thuật toán Ascon.
          
          // Rounds are done - 1 clock cycle to reset
          if (count == rounds + 1) //Khi số vòng hoàn thành (count == rounds + 1), bộ đếm và r_con được đặt lại, và done được kích hoạt.
          begin
              count = 0;
              r_con = 0;
              done = start;
          end          
        end          
    end
    
    always @(rounds) //Khi giá trị của rounds thay đổi, bộ đếm và r_con được đặt lại và hằng số vòng mới được tính toán dựa trên rounds.
    begin
        count = 0;
        r_con = 0;
        init = 0;
        r_con = 4'hf0 - 15*(count + 13 - rounds) - 1;
    end    
    initial begin //Khi module bắt đầu hoạt động, các giá trị của count, done, init và r_con được khởi tạo về giá trị ban đầu.
        count = 0;
        done = 0;
        init = 0;
        r_con = 4'hf0 - 15*(count + 13 - rounds) - 1;
    end
endmodule

