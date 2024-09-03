`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2023 10:34:31 PM
// Design Name: 
// Module Name: permutation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Mục đích: Module permutation thực hiện nhiều vòng hoán vị trên dữ liệu đầu vào in, 
// dựa trên số vòng hoán vị rounds. Nó sử dụng S-box, khuếch tán tuyến tính, 
// và các hằng số vòng để tạo ra dữ liệu đầu ra out.
// Quá trình: Dữ liệu được xử lý qua nhiều vòng, mỗi vòng có thêm hằng số vòng, áp dụng S-box, 
// và khuếch tán tuyến tính. Kết quả cuối cùng được lưu trữ và xuất ra khi hoàn thành tất cả các vòng hoán vị.
module DFF //D Flip-Flop 
(
   input [319:0] D, // dữ liệu đầu ra 320-bit, là giá trị của trạng thái (state).
   input clk,
   output [319:0] Q, // dữ liệu đầu ra 320-bit, là giá trị của trạng thái (state).
   output [319:0] \~Q //phần bù của Q, tức là phần bù nhị phân của trạng thái.
);
    reg [319:0] state;

    assign Q = state;
    assign \~Q = ~state;

    always @(posedge clk) begin
        state <= D;
    end

    initial begin
        state = 0;
    end
endmodule

module Mux_2x1 //Bộ Mux 2 vào, 1 ra
(
    input [0:0] sel,
    input [319:0] in_0,
    input [319:0] in_1,
    output reg [319:0] out
);
    always @ (*) begin
        case (sel)
            1'h0: out = in_0;
            1'h1: out = in_1;
            default:
                out = 'h0;
        endcase
    end
endmodule

module permutation(
    input [319:0] in, 
    output [319:0] out,
    input start,
    input clk,
    input [3:0] rounds
 );
 
  wire [7:0] r_con; //Hằng số vòng (round constant)
  wire done;  //báo hiệu khi vòng hoán vị hoàn tất.
  wire init;
  wire [319:0] round_in;
  wire [319:0] round_out;
  wire [319:0] round_r_con;
  wire [319:0] round_sbox;
  wire [319:0] round_linear;
  
  // Round Constant module này tạo ra hằng số vòng (r_con) dựa trêns
  // số vòng (rounds) và được điều khiển bởi tín hiệu start và clk.
  round_constant r_constant(
    .start( start ),
    .rst(0),
    .clk( clk ),
    .rounds(rounds),
    .r_con(r_con),
    .done(done),
    .init(init)
  );
  
  
  // Select Round Input Data - Data In or Round Out
  // Mux này chọn giá trị đầu vào cho vòng hoán vị. 
  // Nếu init là 1, giá trị đầu vào là in, nếu 0 thì là round_out.
   Mux_2x1 sel_input(
    .sel( init ),
    .in_0( round_out ),
    .in_1( in ),
    .out( round_in )
  );
  
  // add round constant - x2 LSB 8 bits
  //{} (dấu ngoặc nhọn) phép nối
  //^: Đây là toán tử XOR 
  // giũ nguyên tín hiệu round_in[319:136], XOR  hai tín hiệu này round_in[135:128] ^ r_con, 
  //giũ nguyên round_in[127:0]. Sau đó nối lại với nhau và gán cho round_r_con
  assign round_r_con = {round_in[319:136], round_in[135:128] ^ r_con, round_in[127:0]};
  
  // S-Layer
  //Module này thực hiện lớp hoán vị S-box trên round_r_con và cho kết quả là round_sbox.
  s_box_layer s_layer(
    .x(round_r_con),
    .y(round_sbox)
  );
  
  // Linear Diffusion Layer
  // Module này thực hiện khuếch tán tuyến tính (linear diffusion) trên round_sbox 
  // và cho kết quả là round_linear.
  linear l_layer(
    .x(round_sbox),
    .y(round_linear)
  );
  
  // Store Round Output
  // Kết quả round_linear được lưu trữ vào thanh ghi DFF, sau đó gán cho round_out.
   DFF store_out (
    .D( round_linear ),
    .clk( clk ),
    .Q(round_out)
  );
  
  // Assign Permutation Output
  // Khi quá trình hoán vị hoàn thành (done), đầu ra là round_out. 
  // Nếu chưa hoàn thành, đầu ra là in.
  Mux_2x1 permutation_output (
    .sel( done ),
    .in_0( in ),
    .in_1( round_out ),
    .out(out)
  );
endmodule