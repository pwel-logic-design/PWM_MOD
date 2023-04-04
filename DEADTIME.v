`default_nettype none

module DEADTIME (
    input wire CLK,
    input wire ARESETN,
    input wire CARRIER_PEAK,
    input wire[15:0] PRM_DEADTIME,
    input wire PWM_U,
    input wire PWM_V,
    input wire PWM_W,
    input wire LOAD,

    output wire U,V,W,X,Y,Z
);

reg [15:0] TMP_DEADTIME;

// DEADTIME paramter load
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        TMP_DEADTIME <= 16'd50;
    end
    else begin
        if (CARRIER_PEAK | LOAD) TMP_DEADTIME <= PRM_DEADTIME;
    end
end

wire PWM_X = !PWM_U;
wire PWM_Y = !PWM_V;
wire PWM_Z = !PWM_W;
wire COMPARE_U;
wire COMPARE_V;
wire COMPARE_W;
wire COMPARE_X;
wire COMPARE_Y;
wire COMPARE_Z;

TIMER TIMER_U( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_U), .COMPARE(COMPARE_U));
TIMER TIMER_V( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_V), .COMPARE(COMPARE_V));
TIMER TIMER_W( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_W), .COMPARE(COMPARE_W));
TIMER TIMER_X( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_X), .COMPARE(COMPARE_X));
TIMER TIMER_Y( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_Y), .COMPARE(COMPARE_Y));
TIMER TIMER_Z( .CLK(CLK), .ARESETN(ARESETN), .DELAY(TMP_DEADTIME), .PWM_IN(PWM_Z), .COMPARE(COMPARE_Z));

DT DT_U(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_U), .COMPARE(COMPARE_U), .PWM_OUT(U));
DT DT_V(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_V), .COMPARE(COMPARE_V), .PWM_OUT(V));
DT DT_W(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_W), .COMPARE(COMPARE_W), .PWM_OUT(W));
DT DT_X(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_X), .COMPARE(COMPARE_X), .PWM_OUT(X));
DT DT_Y(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_Y), .COMPARE(COMPARE_Y), .PWM_OUT(Y));
DT DT_Z(.CLK(CLK),.ARESETN(ARESETN),.PWM_IN(PWM_Z), .COMPARE(COMPARE_Z), .PWM_OUT(Z));

endmodule

module TIMER(
    input wire CLK,
    input wire ARESETN,
    input wire[15:0] DELAY,
    input wire PWM_IN,
    output wire COMPARE
);

reg PWM_IN0, PWM_IN1;
wire POSEDGE_DETECT;
wire NEGEDGE_DETECT;

// POS edge & NEG edge detection.
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        PWM_IN0 <= 1'b0;
        PWM_IN1 <= 1'b0;
    end
    else begin
        PWM_IN0 <= PWM_IN;
        PWM_IN1 <= PWM_IN0;
    end
end
assign POSEDGE_DETECT = PWM_IN0 & (!PWM_IN1);
assign NEGEDGE_DETECT = (!PWM_IN0) & PWM_IN1;

reg [15:0] COUNT;
reg EN_COUNTUP;

// Enable countup generator.
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        EN_COUNTUP <= 1'b0;
    end
    else begin
        if (POSEDGE_DETECT) EN_COUNTUP <= 1'b1;
        else if ((COUNT == DELAY) | NEGEDGE_DETECT) EN_COUNTUP <= 1'b0;            
    end
end

// countup & compare count with deadtime the paramter.
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        COUNT <= 16'b0;
    end
    else begin
        if (COUNT == DELAY) COUNT <= 16'b0; 
        else if (EN_COUNTUP) COUNT <= COUNT + 1'b1;
        else COUNT <= 16'b0;
    end
end
assign COMPARE = (COUNT == DELAY);

endmodule


// ON DELAY dead time generator
module DT(
    input wire CLK,
    input wire ARESETN,
    input wire PWM_IN,
    input wire COMPARE,
    output wire PWM_OUT
);

reg PWM_TMP;

// Generate ON-delay pulse 
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        PWM_TMP <= 1'b0;
    end
    else begin
        if (!PWM_IN) PWM_TMP <= 1'b0;
        else if ((PWM_IN & COMPARE) | PWM_TMP ) PWM_TMP <= 1'b1;
    end
end
assign PWM_OUT = PWM_IN & PWM_TMP;

endmodule
`default_nettype wire
