module switch(clk, rst,in,out);
    input clk, rst, in;
    output reg out;
    reg q; 
    always@(posedge clk) begin 
        if(rst) begin
            q = 0;
            out = 0;
        end
        else begin
            out = in &(q^in);
            q = in;
        end
    end
endmodule
