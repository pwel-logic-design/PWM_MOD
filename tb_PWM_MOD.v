`default_nettype none
module tb_PWM_MOD (
    
);

reg CLK;
reg ARESETN;


reg [15:0]  PRM_RATE;
reg [15:0]  PRM_MODE;
reg signed[15:0] VU_REF, VV_REF, VW_REF;
reg EN_OUTPUT;
reg [15:0] PRM_DEADTIME;
wire U, V, W, X, Y, Z;

PWM_MOD PWM_MOD (
    .CLK(CLK),
    .ARESETN(ARESETN),
    .EN_OUTPUT(EN_OUTPUT),
    .VU_REF(VU_REF),
    .VV_REF(VV_REF),
    .VW_REF(VW_REF),
    .PRM_RATE(PRM_RATE),
    .PRM_MODE(PRM_MODE),
    .PRM_DEADTIME(PRM_DEADTIME),
    .U(U),
    .V(V),
    .W(W),
    .X(X),
    .Y(Y),
    .Z(Z)
);

parameter  clk_cycle = 10000; //100MHz

always #(clk_cycle/2) begin
    CLK <= ~CLK;
end

initial begin
    CLK = 0;
    ARESETN = 0;
    PRM_RATE = 16'hFFFF;
    PRM_MODE = 8'hF;
    PRM_DEADTIME = 16'd50;
    EN_OUTPUT = 1'b1;

    // リセット解除
    #100000
    ARESETN = 1;

    // 電圧指令変更確認
    #100000
    VU_REF = 16'd8191;
    VV_REF = -16'd8192;
    VW_REF = -16'd16310;

    // デッドタイム変更
    # 800000000
    PRM_DEADTIME = 16'd500;

    // キャリア周波数変更確認
    # 800000000
    PRM_RATE = 16'hFFFF;
    PRM_MODE = 8'h1F;

    // 電圧指令変更確認
    # 800000000
    VU_REF = 16'h7FFF;
    VV_REF = 16'h8000;
    VW_REF = 16'h0000;

    // 電圧指令変更確認
    # 300000000
    VU_REF = 16'h7FFE;
    VV_REF = 16'h8001;
    VW_REF = 16'h0000;

    // キャリア周波数変更確認
    # 800000000
    PRM_RATE = 16'h7FFF;
    PRM_MODE = 8'h1F;

end

endmodule
`default_nettype wire
