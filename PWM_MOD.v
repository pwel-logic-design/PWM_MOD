`default_nettype none

module PWM_MOD (
    input wire CLK,
    input wire ARESETN,
    input wire signed [15:0] VU_REF,
    input wire signed [15:0] VV_REF,
    input wire signed [15:0] VW_REF,
    input wire EN_OUTPUT,
    input wire [15:0] PRM_RATE,
    input wire [7:0] PRM_MODE,
    input wire [15:0] PRM_DEADTIME,    
    output wire CARRIER_PEAK,
    output wire U,
    output wire V,
    output wire W,
    output wire X,
    output wire Y,
    output wire Z,
    output wire MAIN_INTR,
    output wire MAIN_INTR_T
);
    
wire PWM_U, PWM_V, PWM_W;
wire U_tmp, V_tmp, W_tmp, X_tmp, Y_tmp, Z_tmp;


PWM_GENERATOR PWM_GENERATOR(
    // INPUT
    .CLK(CLK),
    .ARESETN(ARESETN),
    .VU_REF(VU_REF),
    .VV_REF(VV_REF),
    .VW_REF(VW_REF),
    .LOAD(1'b0),
    //OUTPUT
    .PWM_U(PWM_U),
    .PWM_V(PWM_V),
    .PWM_W(PWM_W),
    .CARRIER_PEAK(CARRIER_PEAK),
    .MAIN_INTR(MAIN_INTR),
    .MAIN_INTR_T(MAIN_INTR_T),
    // PARAMETER
    .PRM_RATE(PRM_RATE),
    .PRM_MODE(PRM_MODE)
);

DEADTIME DEADTIME(
    // INPUT
    .CLK(CLK),
    .ARESETN(ARESETN),
    .CARRIER_PEAK(MAIN_INTR_T),
    .PWM_U(PWM_U),
    .PWM_V(PWM_V),
    .PWM_W(PWM_W),
    .LOAD(1'b0),
    // OUTPUT
    .U(U_tmp),
    .V(V_tmp),
    .W(W_tmp),
    .X(X_tmp),
    .Y(Y_tmp),
    .Z(Z_tmp),
    // PARAMETER
    .PRM_DEADTIME(PRM_DEADTIME)
);

GATEBLOCK GATEBLOCK(
    .U_IN(U_tmp),
    .V_IN(V_tmp),
    .W_IN(W_tmp),
    .X_IN(X_tmp),
    .Y_IN(Y_tmp),
    .Z_IN(Z_tmp),
    .EN_OUTPUT(EN_OUTPUT),
    .U_OUT(U),
    .V_OUT(V),
    .W_OUT(W),
    .X_OUT(X),
    .Y_OUT(Y),
    .Z_OUT(Z)
);


endmodule

`default_nettype wire