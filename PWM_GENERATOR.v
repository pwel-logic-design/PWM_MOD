`default_nettype none

module PWM_GENERATOR(
    input wire CLK, 
    input wire ARESETN,
    input wire[15:0] PRM_RATE,
    input wire[7:0] PRM_MODE,
    input wire [15:0] VU_REF,
    input wire [15:0] VV_REF,
    input wire [15:0] VW_REF,
    input wire LOAD,
    output wire PWM_U,
    output wire PWM_V,
    output wire PWM_W,
    output wire CARRIER_PEAK,
    output reg MAIN_INTR,
    output wire MAIN_INTR_T
);

reg         EN_COUNTUP;
reg [16:0]  CARRIER_REF;
reg [16:0]  BASE_RATE;
reg [16:0]  CARRIER_COUNT;
wire [15:0] TRIANGULAR_WAVE;
reg [15:0]  RATE_TMP;
reg [7:0]   MODE_TMP;
reg         INTR_TMP;

reg signed [15:0] VU_TMP, VV_TMP, VW_TMP;

////////////////////////////////////////


always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        CARRIER_REF <= 17'b0;
    end else begin
        CARRIER_REF <= CARRIER_REF + 1;
    end
end

// for upcount carrier counter uniformly rate
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        BASE_RATE <= 17'b0;
    end else begin
        BASE_RATE[16]   <= (CARRIER_REF[0]    == 1'b0);
        BASE_RATE[15]   <= (CARRIER_REF[1:0]  == 2'b01);
        BASE_RATE[14]   <= (CARRIER_REF[2:0]  == 3'b011);
        BASE_RATE[13]   <= (CARRIER_REF[3:0]  == 4'b0111);
        BASE_RATE[12]   <= (CARRIER_REF[4:0]  == 5'b01111);
        BASE_RATE[11]   <= (CARRIER_REF[5:0]  == 6'b011111);
        BASE_RATE[10]   <= (CARRIER_REF[6:0]  == 7'b0111111);
        BASE_RATE[9]    <= (CARRIER_REF[7:0]  == 8'b01111111);
        BASE_RATE[8]    <= (CARRIER_REF[8:0]  == 9'b011111111);
        BASE_RATE[7]    <= (CARRIER_REF[9:0]  == 10'b0111111111);
        BASE_RATE[6]    <= (CARRIER_REF[10:0] == 11'b01111111111);
        BASE_RATE[5]    <= (CARRIER_REF[11:0] == 12'b011111111111);
        BASE_RATE[4]    <= (CARRIER_REF[12:0] == 13'b0111111111111);
        BASE_RATE[3]    <= (CARRIER_REF[13:0] == 14'b01111111111111);
        BASE_RATE[2]    <= (CARRIER_REF[14:0] == 15'b011111111111111);
        BASE_RATE[1]    <= (CARRIER_REF[15:0] == 16'b0111111111111111);
        BASE_RATE[0]    <= (CARRIER_REF[15:0] == 17'b01111111111111111);
    end
end

always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin 
        EN_COUNTUP <= 1'b0;
    end
    else begin 
        EN_COUNTUP <= &CARRIER_REF | (BASE_RATE & RATE_TMP) != 0;
    end
end


always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        CARRIER_COUNT <= 17'b0;
    end
    else begin
        if (EN_COUNTUP) begin 
            CARRIER_COUNT <= CARRIER_COUNT + MODE_TMP + 1;
        end
    end
end

// A part of generate triangular waveform.
assign TRIANGULAR_WAVE[15] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[15]);
assign TRIANGULAR_WAVE[14] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[14]);
assign TRIANGULAR_WAVE[13] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[13]);
assign TRIANGULAR_WAVE[12] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[12]);
assign TRIANGULAR_WAVE[11] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[11]);
assign TRIANGULAR_WAVE[10] = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[10]);
assign TRIANGULAR_WAVE[9]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[9]);
assign TRIANGULAR_WAVE[8]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[8]);
assign TRIANGULAR_WAVE[7]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[7]);  
assign TRIANGULAR_WAVE[6]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[6]);
assign TRIANGULAR_WAVE[5]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[5]);
assign TRIANGULAR_WAVE[4]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[4]);
assign TRIANGULAR_WAVE[3]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[3]);
assign TRIANGULAR_WAVE[2]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[2]);
assign TRIANGULAR_WAVE[1]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[1]);
assign TRIANGULAR_WAVE[0]  = !(!CARRIER_COUNT[16] ^ CARRIER_COUNT[0]);

assign CARRIER_PEAK =  EN_COUNTUP &  (&(CARRIER_COUNT[15:0] | MODE_TMP));



always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        MAIN_INTR <= 1'b0;
    end
    else begin
        MAIN_INTR <= !INTR_TMP;
    end
end

always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        INTR_TMP <= 1'b0;
    end
    else begin
        INTR_TMP <= CARRIER_COUNT[15];
    end
end

assign MAIN_INTR_T = !INTR_TMP & !MAIN_INTR;





// Compare Voltage_reference and trianglar carrier wave
always @(posedge CLK or negedge ARESETN) begin
    if (!ARESETN) begin
        VU_TMP <= 16'b0;
        VV_TMP <= 16'b0;
        VW_TMP <= 16'b0;
        RATE_TMP <= 16'hFFFF;
        MODE_TMP <= 8'hFF;
    end
    else begin
        if (CARRIER_PEAK | LOAD) begin 
            VU_TMP <= VU_REF ^ 16'h8000;
            VV_TMP <= VV_REF ^ 16'h8000;
            VW_TMP <= VW_REF ^ 16'h8000;
            RATE_TMP <= PRM_RATE;
            MODE_TMP <= PRM_MODE;
        end
    end
end

assign PWM_U = (VU_TMP == 16'hFFFF) ? 1'b1 : (VU_TMP > TRIANGULAR_WAVE);
assign PWM_V = (VV_TMP == 16'hFFFF) ? 1'b1 : (VV_TMP > TRIANGULAR_WAVE);
assign PWM_W = (VW_TMP == 16'hFFFF) ? 1'b1 : (VW_TMP > TRIANGULAR_WAVE);


endmodule

`default_nettype wire