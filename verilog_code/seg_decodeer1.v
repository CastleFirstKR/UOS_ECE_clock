module seg_decoder1(bcd, seg_data);
 input [3:0] bcd;
 output [7:0] seg_data;
 reg [7:0] seg_data;
 always @(bcd) begin
 case(bcd)
 4'H0 : seg_data=8'b1111_1101; // 'HFC
 4'H1 : seg_data=8'b0110_0001; // 'H60
 4'H2 : seg_data=8'b1101_1011; // 'HDA
 4'H3 : seg_data=8'b1111_0011; // 'HF2
 4'H4 : seg_data=8'b0110_0111; // 'H66
 4'H5 : seg_data=8'b1011_0111; // 'HB6
 4'H6 : seg_data=8'b1011_1111; // 'HBE
 4'H7 : seg_data=8'b1110_0001; // 'HE0
 4'H8 : seg_data=8'b1111_1111; // 'HFE
 4'H9 : seg_data=8'b1111_0111; // 'HF6
 4'Ha : seg_data=8'b1110_1110; // 'HEE
 4'Hb : seg_data=8'b0011_1110; // 'H3E
 4'Hc : seg_data=8'b1001_1100; // 'H9C
 4'Hd : seg_data=8'b0111_1010; // 'H7A
 4'He : seg_data=8'b1001_1110; // 'H9E
 4'Hf : seg_data=8'b1000_1110; // 'H8E
 endcase
 end
endmodule
