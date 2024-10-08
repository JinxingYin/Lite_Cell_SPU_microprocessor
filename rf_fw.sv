/* Register File and forward unit */

module regFileForward (

input clock, 
input [1:0] wr_en, 			// input write enable that write data into register file, from write back stage
input [1:0] wr_back_in, 		// write back in signal is from testbench, represent this instruction need to write back after processing it
input [1:0][6:0] opcode_in, 
input signed [1:0][17:0] immediateIn,
input signed[1:0][127:0] data_in,	
input unsigned [1:0][6:0] rt, 		// 2-D array  [1:0] used for odd or even, obtained from tb
input unsigned [1:0][6:0] rt_wb, 	// write back to register file, previous instrution write back
input unsigned [1:0][6:0] ra, 		
input unsigned [1:0][6:0] rb,  
input unsigned [1:0][6:0] rc, 
input unsigned [1:0][3:0] forwardStage_in,	// input to tell you when to forward
input signed [5:0][127:0] OddregisterValue, 
input unsigned [5:0][6:0] OddregisterAddress,  
input unsigned [5:0][3:0] OddforwardStage, 
input [5:0] OddwriteBack,
input signed [5:0][127:0] EvenregisterValue, 
input unsigned [5:0][6:0] EvenregisterAddress, 
input unsigned [5:0][3:0] EvenforwardStage, 
input [5:0] EvenwriteBack, 
output logic signed[2:0][127:0] regOdd,
output logic signed[2:0][127:0] regEven,
output logic [1:0] wr_back_out, 
output logic unsigned [1:0][6:0] rt_out, 
output logic unsigned [1:0][3:0] forwardStage_out,
output logic [1:0][6:0] opcode_out,
output logic [1:0][17:0] immediateOut); 
logic unsigned [31:0][127:0] rf_0;
logic unsigned [31:0][127:0] rf_1;
logic unsigned [31:0][127:0] rf_2;
logic unsigned [31:0][127:0] rf_3;
logic flag = 0;
always_ff @(posedge clock) begin
	if (flag == 0) begin
	rf_0[0] <= 0;
	rf_0[1] <= 1;
	rf_0[2] <= 2;
	rf_0[3] <= 3;
	rf_0[4] <= 99;
	rf_0[5] <= 5;
	rf_0[6] <= 6;
	rf_0[7] <= 7;
	rf_0[8] <= 8;
	rf_0[9] <= 9;
	rf_0[10] <= 10;
	rf_0[11] <= 11;
	rf_0[12] <= 12;
	rf_0[13] <= 13;
	rf_0[14] <= 14;
	rf_0[15] <= 15;
	rf_0[16] <= 16;
	rf_0[17] <= 17;
	rf_0[18] <= 18;
	rf_0[19] <= 19;
	rf_0[20] <= 20;
	rf_0[21] <= 21;
	rf_0[22] <= 22;
	rf_0[23] <= 23;
	rf_0[24] <= 24;
	rf_0[25] <= 25;
	rf_0[26] <= 26;
	rf_0[27] <= 27;
	rf_0[28] <= 28;
	rf_0[29] <= 29;
	rf_0[30] <= 30;
	rf_0[31] <= 31;

	rf_1[0] <= 32;
	rf_1[1] <= 33;
	rf_1[2] <= 34;
	rf_1[3] <= 35;
	rf_1[4] <= 36;
	rf_1[5] <= 37;
	rf_1[6] <= 38;
	rf_1[7] <= 39;
	rf_1[8] <= 40;
	rf_1[9] <= 41;
	rf_1[10] <= 42;
	rf_1[11] <= 43;
	rf_1[12] <= 44;
	rf_1[13] <= 45;
	rf_1[14] <= 46;
	rf_1[15] <= 47;
	rf_1[16] <= 48;
	rf_1[17] <= 49;
	rf_1[18] <= 50;
	rf_1[19] <= 51;
	rf_1[20] <= 52;
	rf_1[21] <= 53;
	rf_1[22] <= 54;
	rf_1[23] <= 55;
	rf_1[24] <= 56;
	rf_1[25] <= 57;
	rf_1[26] <= 58;
	rf_1[27] <= 59;
	rf_1[28] <= 60;
	rf_1[29] <= 61;
	rf_1[30] <= 62;
	rf_1[31] <= 63;

	rf_2[0] <= 64;
	rf_2[1] <= 65;
	rf_2[2] <= 66;
	rf_2[3] <= 67;
	rf_2[4] <= 68;
	rf_2[5] <= 69;
	rf_2[6] <= 70;
	rf_2[7] <= 71;
	rf_2[8] <= 72;
	rf_2[9] <= 73;
	rf_2[10] <= 74;
	rf_2[11] <= 75;
	rf_2[12] <= 76;
	rf_2[13] <= 77;
	rf_2[14] <= 78;
	rf_2[15] <= 79;
	rf_2[16] <= 80;
	rf_2[17] <= 81;
	rf_2[18] <= 82;
	rf_2[19] <= 83;
	rf_2[20] <= 84;
	rf_2[21] <= 85;
	rf_2[22] <= 86;
	rf_2[23] <= 87;
	rf_2[24] <= 88;
	rf_2[25] <= 89;
	rf_2[26] <= 90;
	rf_2[27] <= 91;
	rf_2[28] <= 92;
	rf_2[29] <= 93;
	rf_2[30] <= 94;
	rf_2[31] <= 95;

	rf_3[0] <= 96;
	rf_3[1] <= 97;
	rf_3[2] <= 98;
	rf_3[3] <= 99;
	rf_3[4] <= 100;
	rf_3[5] <= 101;
	rf_3[6] <= 102;
	rf_3[7] <= 103;
	rf_3[8] <= 104;
	rf_3[9] <= 105;
	rf_3[10] <= 106;
	rf_3[11] <= 107;
	rf_3[12] <= 108;
	rf_3[13] <= 109;
	rf_3[14] <= 110;
	rf_3[15] <= 111;
	rf_3[16] <= 112;
	rf_3[17] <= 113;
	rf_3[18] <= 114;
	rf_3[19] <= 115;
	rf_3[20] <= 116;
	rf_3[21] <= 117;
	rf_3[22] <= 118;
	rf_3[23] <= 119;
	rf_3[24] <= 120;
	rf_3[25] <= 121;
	rf_3[26] <= 122;
	rf_3[27] <= 123;
	rf_3[28] <= 124;
	rf_3[29] <= 125;
	rf_3[30] <= 126;
	rf_3[31] <= 127;

	flag = 1;
	end
	else begin
	end
end


always_ff @(posedge clock) begin
if(wr_en[0] == 1) begin
	if (rt_wb[0] <= 31) begin
	rf_0[rt_wb[0]] <= data_in[0];
	end
	else if (31 < rt_wb[0] &&  rt_wb[0]  <= 63) begin
	rf_1[rt_wb[0] - 32] <= data_in[0];
	end
	else if (63 < rt_wb[0]  &&  rt_wb[0] <= 95) begin
	rf_2[rt_wb[0] - 64] <= data_in[0];
	end
	else if (95 < rt_wb[0]&&  rt_wb[0]  <= 127) begin
	rf_3[rt_wb[0] - 96] <= data_in[0];
	end
	else begin
	end
end

else begin
end

if (wr_en[1] == 1) begin
	if (0 <= rt_wb[1] && rt_wb[1] <= 31) begin
	rf_0[rt_wb[1]] <= data_in[1];
	end
	else if (32 <= rt_wb[1] && rt_wb[1] <= 63) begin
	rf_1[rt_wb[1] - 32] <= data_in[1];
	end
	else if (64 <= rt_wb[1] && rt_wb[1] <= 95) begin
	rf_2[rt_wb[1] - 64] <= data_in[1];
	end
	else if (96 <= rt_wb[1] && rt_wb[1] <= 127) begin
	rf_3[rt_wb[1] - 96] <= data_in[1];
	end
	else begin
	end
end

else begin
end

end

always_ff @(posedge clock) begin 

/* values for odd pipe*/
    if(ra[1]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regOdd[0] <= OddregisterValue[0];
    end

    else if(ra[1]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regOdd[0] <= OddregisterValue[1];
    end

    else if(ra[1]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regOdd[0] <= OddregisterValue[2];
    end

    else if(ra[1]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regOdd[0] <= OddregisterValue[3];
    end

    else if(ra[1]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regOdd[0] <= OddregisterValue[4];
    end

    else if(ra[1]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regOdd[0] <= OddregisterValue[5];
    end

    else if(ra[1]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regOdd[0] <= EvenregisterValue[0];
    end

    else if(ra[1]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regOdd[0] <= EvenregisterValue[1];
    end

    else if(ra[1]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regOdd[0] <= EvenregisterValue[2];
    end

    else if(ra[1]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regOdd[0] <= EvenregisterValue[3];
    end

    else if(ra[1]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regOdd[0] <= EvenregisterValue[4];
    end

    else if(ra[1]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regOdd[0] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= ra[1] && ra[1] <= 31) begin
     	regOdd[0] <= rf_0[ra[1]];
	end
	else if (32 <= ra[1] && ra[1] <= 63) begin
     	regOdd[0] <= rf_1[ra[1] - 32];
	end
	else if (64 <= ra[1] && ra[1] <= 95) begin
     	regOdd[0] <= rf_2[ra[1] - 64];
	end
	else if (96 <= ra[1] && ra[1] <= 127) begin
     	regOdd[0] <= rf_3[ra[1] - 96];
	end
	else begin
	end
    end


    if(rb[1]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regOdd[1] <= OddregisterValue[0];
    end

    else if(rb[1]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regOdd[1] <= OddregisterValue[1];
    end

    else if(rb[1]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regOdd[1] <= OddregisterValue[2];
    end

    else if(rb[1]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regOdd[1] <= OddregisterValue[3];
    end

    else if(rb[1]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regOdd[1] <= OddregisterValue[4];
    end

    else if(rb[1]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regOdd[1] <= OddregisterValue[5];
    end

    else if(rb[1]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regOdd[1] <= EvenregisterValue[0];
    end

    else if(rb[1]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regOdd[1] <= EvenregisterValue[1];
    end

    else if(rb[1]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regOdd[1] <= EvenregisterValue[2];
    end

    else if(rb[1]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regOdd[1] <= EvenregisterValue[3];
    end

    else if(rb[1]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regOdd[1] <= EvenregisterValue[4];
    end

    else if(rb[1]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regOdd[1] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= rb[1]&& rb[1] <= 31) begin
     	regOdd[1] <= rf_0[rb[1]];
	end
	else if (32 <= rb[1] && rb[1] <= 63) begin
     	regOdd[1] <= rf_1[rb[1] - 32];
	end
	else if (64 <= rb[1] && rb[1] <= 95) begin
     	regOdd[1] <= rf_2[rb[1] - 64];
	end
	else if (96 <= rb[1] && rb[1] <= 127) begin
     	regOdd[1] <= rf_3[rb[1] - 96];
	end
	else begin
	end
    end

    if(rc[1]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regOdd[2] <= OddregisterValue[0];
    end

    else if(rc[1]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regOdd[2] <= OddregisterValue[1];
    end

    else if(rc[1]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regOdd[2] <= OddregisterValue[2];
    end

    else if(rc[1]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regOdd[2] <= OddregisterValue[3];
    end

    else if(rc[1]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regOdd[2] <= OddregisterValue[4];
    end

    else if(rc[1]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regOdd[2] <= OddregisterValue[5];
    end

    else if(rc[1]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regOdd[2] <= EvenregisterValue[0];
    end

    else if(rc[1]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regOdd[2] <= EvenregisterValue[1];
    end

    else if(rc[1]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regOdd[2] <= EvenregisterValue[2];
    end

    else if(rc[1]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regOdd[2] <= EvenregisterValue[3];
    end

    else if(rc[1]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regOdd[2] <= EvenregisterValue[4];
    end

    else if(rc[1]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regOdd[2] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= rc[1] && rc[1] <= 31) begin
     	regOdd[2] <= rf_0[rc[1]];
	end
	else if (32 <= rc[1] && rc[1] <= 63) begin
     	regOdd[2] <= rf_1[rc[1] - 32];
	end
	else if (64 <= rc[1] && rc[1] <= 95) begin
     	regOdd[2] <= rf_2[rc[1] - 64];
	end
	else if (96 <= rc[1] && rc[1] <= 127) begin
     	regOdd[2] <= rf_3[rc[1] - 96];
	end
	else begin
	end
    end

/* values for even pipe */

    if(ra[0]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regEven[0] <= OddregisterValue[0];
    end

    else if(ra[0]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regEven[0] <= OddregisterValue[1];
    end

    else if(ra[0]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regEven[0] <= OddregisterValue[2];
    end

    else if(ra[0]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regEven[0] <= OddregisterValue[3];
    end

    else if(ra[0]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regEven[0] <= OddregisterValue[4];
    end

    else if(ra[0]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regEven[0] <= OddregisterValue[5];
    end

    else if(ra[0]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regEven[0] <= EvenregisterValue[0];
    end

    else if(ra[0]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regEven[0] <= EvenregisterValue[1];
    end

    else if(ra[0]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regEven[0] <= EvenregisterValue[2];
    end

    else if(ra[0]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regEven[0] <= EvenregisterValue[3];
    end

    else if(ra[0]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regEven[0] <= EvenregisterValue[4];
    end

    else if(ra[0]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regEven[0] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= ra[0] && ra[0] <= 31) begin
     	regEven[0] <= rf_0[ra[0]];
	end
	else if (32 <= ra[0] && ra[0] <= 63) begin
     	regEven[0] <= rf_1[ra[0] - 32];
	end
	else if (64 <= ra[0] && ra[0] <= 95) begin
     	regEven[0] <= rf_2[ra[0] - 64];
	end
	else if (96 <= ra[0] && ra[0] <= 127) begin
     	regEven[0] <= rf_3[ra[0] - 96];
	end
	else begin
	end
    end

    if(rb[0]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regEven[1] <= OddregisterValue[0];
    end

    else if(rb[0]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regEven[1] <= OddregisterValue[1];
    end

    else if(rb[0]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regEven[1] <= OddregisterValue[2];
    end

    else if(rb[0]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regEven[1] <= OddregisterValue[3];
    end

    else if(rb[0]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regEven[1] <= OddregisterValue[4];
    end

    else if(rb[0]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regEven[1] <= OddregisterValue[5];
    end

    else if(rb[0]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regEven[1] <= EvenregisterValue[0];
    end

    else if(rb[0]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regEven[1] <= EvenregisterValue[1];
    end

    else if(rb[0]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regEven[1] <= EvenregisterValue[2];
    end

    else if(rb[0]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regEven[1] <= EvenregisterValue[3];
    end

    else if(rb[0]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regEven[1] <= EvenregisterValue[4];
    end

    else if(rb[0]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regEven[1] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= rb[0] && rb[0] <= 31) begin
     	regEven[1] <= rf_0[rb[0]];
	end
	else if (32 <= rb[0] && rb[0]<= 63) begin
     	regEven[1] <= rf_1[rb[0] - 32];
	end
	else if (64 <= rb[0] && rb[0] <= 95) begin
     	regEven[1] <= rf_2[rb[0] - 64];
	end
	else if (96 <= rb[0] && rb[0] <= 127) begin
     	regEven[1] <= rf_3[rb[0] - 96];
	end
	else begin
	end
    end

    if(rc[0]== OddregisterAddress[0] && OddforwardStage[0] <= 2 && OddwriteBack[0] == 1)begin
        regEven[2] <= OddregisterValue[0];
    end

    else if(rc[0]== OddregisterAddress[1] && OddforwardStage[1] <= 3 && OddwriteBack[1] == 1)begin
        regEven[2] <= OddregisterValue[1];
    end

    else if(rc[0]== OddregisterAddress[2] && OddforwardStage[2] <= 4 && OddwriteBack[2] == 1)begin
        regEven[2] <= OddregisterValue[2];
    end

    else if(rc[0]== OddregisterAddress[3] && OddforwardStage[3] <= 5 && OddwriteBack[3] == 1)begin
        regEven[2] <= OddregisterValue[3];
    end

    else if(rc[0]== OddregisterAddress[4] && OddforwardStage[4] <= 6 && OddwriteBack[4] == 1)begin
        regEven[2] <= OddregisterValue[4];
    end

    else if(rc[0]== OddregisterAddress[5] && OddforwardStage[5] <= 7 && OddwriteBack[5] == 1)begin
        regEven[2] <= OddregisterValue[5];
    end

    else if(rc[0]== EvenregisterAddress[0] && EvenforwardStage[0]<= 2 && EvenwriteBack[0] == 1)begin
        regEven[2] <= EvenregisterValue[0];
    end

    else if(rc[0]== EvenregisterAddress[1] && EvenforwardStage[1]<= 3 && EvenwriteBack[1] == 1)begin
        regEven[2] <= EvenregisterValue[1];
    end

    else if(rc[0]== EvenregisterAddress[2] && EvenforwardStage[2]<= 4 && EvenwriteBack[2] == 1)begin
        regEven[2] <= EvenregisterValue[2];
    end

    else if(rc[0]== EvenregisterAddress[3] && EvenforwardStage[3]<= 5 && EvenwriteBack[3] == 1)begin
        regEven[2] <= EvenregisterValue[3];
    end

    else if(rc[0]== EvenregisterAddress[4] && EvenforwardStage[4]<= 6 && EvenwriteBack[4] == 1)begin
        regEven[2] <= EvenregisterValue[4];
    end

    else if(rc[0]== EvenregisterAddress[5] && EvenforwardStage[5]<= 7 && EvenwriteBack[5] == 1)begin
        regEven[2] <= EvenregisterValue[5];
    end

    else begin
	if (0 <= rc[0]  &&  rc[0]<= 31) begin
     	regEven[2] <= rf_0[rc[0]];
	end
	else if (32 <= rc[0] &&  rc[0] <= 63) begin
     	regEven[2] <= rf_1[rc[0] - 32];
	end
	else if (64 <= rc[0] &&  rc[0] <= 95) begin
     	regEven[2] <= rf_2[rc[0] - 64];
	end
	else if (96 <= rc[0]  &&  rc[0]<= 127) begin
     	regEven[2] <= rf_3[rc[0] - 96];
	end
	else begin
	end
    end
    
	immediateOut <= immediateIn;
    wr_back_out <= wr_back_in;
    rt_out <= rt;
    forwardStage_out <= forwardStage_in;
    opcode_out <=  opcode_in;
    
end
   
endmodule



/*module test();
logic clock;
logic [1:0] wr_en; 			// input write enable that write data into register file, from write back stage
logic [1:0] wr_back_in; 		// write back in signal is from testbench, represent this instruction need to write back after processing it
logic signed[1:0][127:0] data_in;	
logic unsigned [1:0][6:0] rt; 	// 2-D array  [1:0] used for odd or even, obtained from tb
logic unsigned [1:0][6:0] rt_wb; 	// write back to register file, previous instrution write back
logic unsigned [1:0][6:0] ra;		
logic unsigned [1:0][6:0] rb;  
logic unsigned [1:0][6:0] rc; 
logic unsigned [1:0][3:0] forwardStage_in;	// input to tell you when to forward
logic signed [5:0][127:0] OddregisterValue; 
logic unsigned [5:0][6:0] OddregisterAddress;  
logic unsigned [5:0][3:0] OddforwardStage;
logic [5:0] OddwriteBack;
logic signed [5:0][127:0] EvenregisterValue; 
logic unsigned [5:0][6:0] EvenregisterAddress; 
logic unsigned [5:0][3:0] EvenforwardStage;
logic [5:0] EvenwriteBack; 
logic signed[2:0][127:0] regOdd;
logic signed[2:0][127:0] regEven;
logic [1:0] wr_back_out;
logic unsigned [1:0][6:0] rt_out;
logic unsigned [1:0][3:0] forwardStage_out;

regFileForward dut (clock,wr_en,wr_back_in,data_in,rt,rt_wb,ra,rb,rc,forwardStage_in,OddregisterValue,OddregisterAddress,OddforwardStage,
OddwriteBack,EvenregisterValue,EvenregisterAddress,EvenforwardStage,EvenwriteBack,regOdd,regEven,wr_back_out,rt_out,forwardStage_out);



initial begin
	
	clock = 0;
	wr_en = 2'b11;
	wr_back_in = 2'b00;
	data_in[0] = 3;
	data_in[1] = 4;
	rt[0] = 23;
	rt[1] = 26;
	rt_wb[0] = 31;
	rt_wb[1] = 32;
	ra[1] = 6;
	ra[1] = 10;
	rb[1] = 2;
	rb[1] = 3;
	rc[1] = 8;
	rc[1] = 9;
	forwardStage_in[0] = 3;
	forwardStage_in[1] = 4;
	OddregisterValue[0] = 14;
	OddregisterValue[1] = 15;
	OddregisterValue[2] = 16;
	OddregisterValue[3] = 17;
	OddregisterValue[4] = 18;
	OddregisterValue[5] = 19;
	EvenregisterValue[0] = 20;
	EvenregisterValue[1] = 21;
	EvenregisterValue[2] = 22;
	EvenregisterValue[3] = 23;
	EvenregisterValue[4] = 24;
	EvenregisterValue[5] = 25;

	OddregisterAddress[0] = 31;
	OddregisterAddress[1] = 32;
	OddregisterAddress[2] = 33;
	OddregisterAddress[3] = 34;
	OddregisterAddress[4] = 35;
	OddregisterAddress[5] = 36;

	EvenregisterAddress[0] = 37;
	EvenregisterAddress[1] = 38;
	EvenregisterAddress[2] = 39;
	EvenregisterAddress[3] = 40;
	EvenregisterAddress[4] = 41;
	EvenregisterAddress[5] = 42;
	
	OddforwardStage[0] = 3;
	OddforwardStage[1] = 4;
	OddforwardStage[2] = 5;
	OddforwardStage[3] = 4;
	OddforwardStage[4] = 2;
	OddforwardStage[5] = 4;

	EvenforwardStage[0] = 3;
	EvenforwardStage[1] = 5;
	EvenforwardStage[2] = 1;
	EvenforwardStage[3] = 4;
	EvenforwardStage[4] = 7;
	EvenforwardStage[5] = 6;

	OddwriteBack = 6'b101011;
	EvenwriteBack = 6'b111000;






	#5;
	clock = 1;
	#5;

	clock = 0;
	wr_en = 2'b11;
	wr_back_in = 2'b11;
	data_in[0] = 5;
	data_in[1] = 6;
	rt[0] = 45;
	rt[1] = 12;
	rt_wb[0] = 63;
	rt_wb[1] = 127;
	ra[1] = 14;
	ra[1] = 5;
	rb[1] = 32;
	rb[1] = 1;
	rc[1] = 55;
	rc[1] = 6;
	forwardStage_in[0] = 3;
	forwardStage_in[1] = 4;
	OddregisterValue[0] = 64;
	OddregisterValue[1] = 15;
	OddregisterValue[2] = 16;
	OddregisterValue[3] = 17;
	OddregisterValue[4] = 18;
	OddregisterValue[5] = 19;
	EvenregisterValue[0] = 20;
	EvenregisterValue[1] = 21;
	EvenregisterValue[2] = 22;
	EvenregisterValue[3] = 23;
	EvenregisterValue[4] = 24;
	EvenregisterValue[5] = 25;

	OddregisterAddress[0] = 14;
	OddregisterAddress[1] = 32;
	OddregisterAddress[2] = 31;
	OddregisterAddress[3] = 34;
	OddregisterAddress[4] = 55;
	OddregisterAddress[5] = 36;

	EvenregisterAddress[0] = 5;
	EvenregisterAddress[1] = 1;
	EvenregisterAddress[2] = 8;
	EvenregisterAddress[3] = 40;
	EvenregisterAddress[4] = 6;
	EvenregisterAddress[5] = 42;
	
	OddforwardStage[0] = 2;
	OddforwardStage[1] = 2;
	OddforwardStage[2] = 2;
	OddforwardStage[3] = 2;
	OddforwardStage[4] = 2;
	OddforwardStage[5] = 2;

	EvenforwardStage[0] = 2;
	EvenforwardStage[1] = 2;
	EvenforwardStage[2] = 2;
	EvenforwardStage[3] = 2;
	EvenforwardStage[4] = 2;
	EvenforwardStage[5] = 2;

	OddwriteBack = 6'b010111;
	EvenwriteBack = 6'b111011;

	#5;
	clock = 1;

	#5;
	clock = 0;


	#5;
	clock = 1;

	#5;
	clock = 0;

	#5;
	clock = 1;

	#5;
	clock = 0;

	#5;
	clock = 1;

	#5;
	$finish;
	end

endmodule */


