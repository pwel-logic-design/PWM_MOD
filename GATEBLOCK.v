`default_nettype none

module GATEBLOCK (
    input wire U_IN,V_IN,W_IN,X_IN,Y_IN,Z_IN,
    input wire EN_OUTPUT,
    output wire U_OUT,V_OUT,W_OUT,X_OUT,Y_OUT,Z_OUT
);

assign U_OUT = U_IN & EN_OUTPUT;
assign V_OUT = V_IN & EN_OUTPUT;
assign W_OUT = W_IN & EN_OUTPUT;
assign X_OUT = X_IN & EN_OUTPUT;
assign Y_OUT = Y_IN & EN_OUTPUT;
assign Z_OUT = Z_IN & EN_OUTPUT;

endmodule

`default_nettype wire