// opcode 66!!!
module PipeStage( 
input [5:0] PCounter,
input clock,
input [1:0][6:0] opcode,    
input signed [5:0][127:0] valueIn,       /* 0-2 even a,b,c 3-5 odd a,b,c   rt register value will be in 4 when it's used  some cares need to be taken when connect port*/
input signed [1:0][17:0] immediateIn,    /* assume uniform length we don't need to know its length operation will just take bits based on 6,7,10,16 or 18*/
input [1:0] wr_en_in,
input [1:0][6:0] RtAddress_in,
input [1:0][3:0] ready_stage_in,         /* these three are just bypassing to output*/
output logic signed [1:0][127:0] RtValue_ff,          /* 0 for even 1 for odd*/
output logic [1:0][6:0] RtAddress_out,
output logic [1:0] wr_en_out,
output logic [1:0][3:0] ready_stage_out,
output logic [5:0] branchAddress_ff,       /* new pc address */
output logic branchOrNot_ff,
output logic stop_ff
);

logic stop;
logic unsigned [6:0] evenOpcode;
logic unsigned [6:0] oddOpcode;
logic signed [15:0] immediate16;
logic signed [31:0] immediate32;
logic signed [127:0] complementValue;
logic [7:0] counter; /*  used for counting leading zeros */
logic [3:0][31:0] d_a;
logic [31:0] tempValue;
logic [31:0] tempValue2;
logic [7:0] tempValue8bit;
logic [15:0] tempValue16bit;
logic [15:0] tempValue16bit2;
logic unsigned [6:0] shiftAmount;
logic signed [32:0] floatingResult;
logic signed [63:0] floatingResult64bit;
logic signed [31:0][127:0] dataMemory1;
logic signed [31:0][127:0] dataMemory2;
logic signed[31:0][127:0] dataMemory3;
logic signed [31:0][127:0] dataMemory4;
logic signed [31:0][127:0] dataMemory5;
logic signed [31:0][127:0] dataMemory6;
logic signed[31:0][127:0] dataMemory7;
logic signed [31:0][127:0] dataMemory8;
logic signed [1:0][127:0] RtValue;
logic [5:0] branchAddress;       /* new pc address */
logic branchOrNot;

always_comb begin
/* bypassing*/
    

if(opcode[0] < 92) begin
if( opcode[0] == 1 || opcode[0] ==  2 || opcode[0] == 3 || opcode[0] == 4 || opcode[0] == 5
|| opcode[0] == 6|| opcode[0] == 57 || opcode[0] ==  58 || opcode[0] == 59 || opcode[0] == 60
|| opcode[0] == 61 || opcode[0] == 62|| opcode[0] == 63 || opcode[0] == 64|| 
opcode[0] == 81 || opcode[0] == 82|| opcode[0] == 83 || opcode[0] == 84|| opcode[0] == 91)begin
oddOpcode = opcode[0];
stop = 0;
end
else if(opcode[0] == 89)begin
    stop = 1;
end
else begin 
    evenOpcode = opcode[0];
    stop = 0;
end
end

if(opcode[1] < 92) begin
if( opcode[1] == 1 || opcode[1] ==  2 || opcode[1] == 3 || opcode[1] == 4 || opcode[1] == 5
|| opcode[1] == 6 || opcode[1] == 57 || opcode[1] ==  58 || opcode[1] == 59 || opcode[1] == 60
|| opcode[1] == 61 || opcode[1] == 62|| opcode[1] == 63 || opcode[1] == 64|| 
opcode[1] == 81 || opcode[1] == 82|| opcode[1] == 83 || opcode[1] == 84|| opcode[1] == 91)begin
oddOpcode = opcode[1];
stop = 0;
end
else if(opcode[1] == 89) begin
    stop = 1;
end
else begin 
    evenOpcode = opcode[1];
    stop = 0;
end
end

/*1.add word overflow not detect */
if(evenOpcode == 7)begin
        RtValue[0][31:0] = valueIn[0][31:0]+valueIn[1][31:0];
        RtValue[0][63:32] = valueIn[0][63:32]+valueIn[1][63:32];
        RtValue[0][95:64] = valueIn[0][95:64]+valueIn[1][95:64];
        RtValue[0][127:96] = valueIn[0][127:96]+valueIn[1][127:96];
end

/* 2 add word immediate */
else if(evenOpcode == 8) begin 

    if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'b11111111111111111111111;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'b00000000000000000000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end
        RtValue[0][31:0] = valueIn[0][31:0]+immediate32;
        RtValue[0][63:32] = valueIn[0][63:32]+immediate32;
        RtValue[0][95:64] = valueIn[0][95:64]+immediate32;
        RtValue[0][127:96] = valueIn[0][127:96]+immediate32;
end

/* 3 subtract from word*/
else if(evenOpcode == 9)begin
    for(int i = 0; i<128; i++)begin
        if(valueIn[0][i] == 0)begin
        complementValue[i] = 1;
        end
        else begin
            complementValue[i] =0;
        end
    end
     RtValue[0][31:0] = valueIn[1][31:0]+complementValue[31:0]+1;
        RtValue[0][63:32] = valueIn[1][63:32]+complementValue[63:32]+1;
        RtValue[0][95:64] = valueIn[1][95:64]+complementValue[95:64]+1;
        RtValue[0][127:96] = valueIn[1][127:96]+complementValue[127:96]+1;
    
end

/* 4 subtract from word immediate*/

else if(evenOpcode == 10)begin
    for(int i = 0; i<128; i++)begin
         if(valueIn[0][i] == 0)begin
        complementValue[i] = 1;
        end
        else begin
            complementValue[i] =0;
        end
    end
    if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'b11111111111111111111111;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'b00000000000000000000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end

     RtValue[0][31:0] = immediate32+complementValue[31:0]+1;
        RtValue[0][63:32] = immediate32+complementValue[63:32]+1;
        RtValue[0][95:64] = immediate32+complementValue[95:64]+1;
        RtValue[0][127:96] = immediate32+complementValue[127:96]+1;
    
end

/* 5 multiply */
else if(evenOpcode == 11)begin
RtValue[0][31:0] = valueIn[0][15:0]*valueIn[1][15:0];
        RtValue[0][63:32] = valueIn[0][47:32]*valueIn[1][47:32];
        RtValue[0][95:64] = valueIn[0][79:64]*valueIn[1][79:64];
        RtValue[0][127:96] = valueIn[0][111:96]*valueIn[1][111:96];
end

/* 6 multiply and add */
else if(evenOpcode == 12)begin
RtValue[0][31:0] = valueIn[0][15:0]*valueIn[1][15:0] + valueIn[2][31:0];
        RtValue[0][63:32] = valueIn[0][47:32]*valueIn[1][47:32]+valueIn[2][63:32];
        RtValue[0][95:64] = valueIn[0][79:64]*valueIn[1][79:64]+valueIn[2][95:64];
        RtValue[0][127:96] = valueIn[0][111:96]*valueIn[1][111:96]+valueIn[2][127:96];
end

/*  7 and */
else if(evenOpcode == 13)begin  // 11001  1100

    for(int i =0; i<128; i++) begin
        if(valueIn[0][i] == 1 && valueIn[1][i] == 1)begin
            RtValue[0][i] = 1;
        end
        else begin
            RtValue[0][i] = 0;
        end
    end
end

/* 8 or */
else if(evenOpcode == 14)begin

    for(int i =0; i<128; i++) begin
        if(valueIn[0][i] == 0 && valueIn[1][i] == 0)begin
            RtValue[0][i] = 0;
        end
        else begin
            RtValue[0][i] = 1;
        end
    end
end

/* 9  xor */
else if(evenOpcode == 15)begin  // 010  011 001

    for(int i =0; i<128; i++) begin
        if( valueIn[0][i] != valueIn[1][i] )begin
            RtValue[0][i] = 1;
        end
        else begin
            RtValue[0][i] = 0;
        end
    end
end

/*  10 nand */
else if(evenOpcode == 16)begin  // 010 011 101  5 

    for(int i =0; i<128; i++) begin
        if(valueIn[0][i] == 1 && valueIn[1][i] == 1)begin
            RtValue[0][i] = 0;
        end
        else begin
            RtValue[0][i] = 1;
        end
    end

end

/* 11 nor */			// 010 011 100
else if(evenOpcode == 17)begin

    for(int i =0; i<128; i++) begin
        if(valueIn[0][i] == 0 && valueIn[1][i] == 0)begin
            RtValue[0][i] = 1;
        end
        else begin
            RtValue[0][i] = 0;
        end
    end
end

/* 12 counting leading zeros*/

else if(evenOpcode == 18) begin
	d_a[0] = valueIn[0][31:0];
	d_a[1] = valueIn[0][63:32];
	d_a[2] = valueIn[0][95:64];
	d_a[3] = valueIn[0][127:96];  // 101:96      100000
    for(int j = 0; j<4; j++)begin 
        counter = 0;
        tempValue = d_a[j];
    for(int m=31; m >= 0; m--)begin
        if(tempValue[m] == 1)begin
            break;
        end
        else begin
            counter = counter+1;
        end
    if (j == 0) begin
    RtValue[0][31:0] = counter;
    end
    else if (j == 1) begin
    RtValue[0][63:32] = counter;
    end
    else if (j == 2) begin
    RtValue[0][95:64] = counter;
    end
    else begin
    RtValue[0][127:96] = counter;
    end
    end
    end

end

/* 13 select bits*/

else if(evenOpcode == 19)begin
    for(int i=0; i<128; i++)begin
    if(valueIn[2][i] == 0)begin
        RtValue[0][i] = valueIn[0][i];
    end
    else begin
        RtValue[0][i] = valueIn[1][i];    
    end
    end
end

/* 14 add halfword immediate  */
else if(evenOpcode == 20)begin

     if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];  //  010
    end
        RtValue[0][15:0] = valueIn[0][15:0]+immediate16;
        RtValue[0][31:16] = valueIn[0][31:16]+immediate16;
        RtValue[0][47:32] = valueIn[0][47:32]+immediate16;
        RtValue[0][63:48] = valueIn[0][63:48]+immediate16;
        RtValue[0][79:64] = valueIn[0][79:64]+immediate16;
        RtValue[0][95:80] = valueIn[0][95:80]+immediate16;
        RtValue[0][111:96] = valueIn[0][111:96]+immediate16;
        RtValue[0][127:112] = valueIn[0][127:112]+immediate16;
end

/* 15 add halfword   */
else if(evenOpcode == 21)begin

        RtValue[0][15:0] = valueIn[0][15:0]+valueIn[1][15:0];
        RtValue[0][31:16] = valueIn[0][31:16]+valueIn[1][31:16];
        RtValue[0][47:32] = valueIn[0][47:32]+valueIn[1][47:32];
        RtValue[0][63:48] = valueIn[0][63:48]+valueIn[1][63:48];
        RtValue[0][79:64] = valueIn[0][79:64]+valueIn[1][79:64];
        RtValue[0][95:80] = valueIn[0][95:80]+valueIn[1][95:80];
        RtValue[0][111:96] = valueIn[0][111:96]+valueIn[1][111:96];
        RtValue[0][127:112] = valueIn[0][127:112]+valueIn[1][127:112];
end

/* 17 subtract halfword immediate  */
else if(evenOpcode == 23)begin

     if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

for(int i = 0; i<128; i++)begin
        if(valueIn[0][i] == 0)begin
        complementValue[i] = 1;
        end
        else begin
            complementValue[i] =0;
        end
    end
        RtValue[0][15:0] = complementValue[15:0]+immediate16+1;
        RtValue[0][31:16] = complementValue[31:16]+immediate16+1;
        RtValue[0][47:32] = complementValue[47:32]+immediate16+1;
        RtValue[0][63:48] = complementValue[63:48]+immediate16+1;
        RtValue[0][79:64] = complementValue[79:64]+immediate16+1;
        RtValue[0][95:80] = complementValue[95:80]+immediate16+1;
        RtValue[0][111:96] = complementValue[111:96]+immediate16+1;
        RtValue[0][127:112] = complementValue[127:112]+immediate16+1;
end

/* 16 subtract halfword   */
else if(evenOpcode == 22)begin

for(int i = 0; i<128; i++)begin
        if(valueIn[0][i] == 0)begin
        complementValue[i] = 1;
        end
        else begin
            complementValue[i] =0;
        end
    end
        RtValue[0][15:0] = complementValue[15:0]+valueIn[1][15:0]+1;
        RtValue[0][31:16] = complementValue[31:16]+valueIn[1][31:16]+1;
        RtValue[0][47:32] = complementValue[47:32]+valueIn[1][47:32]+1;
        RtValue[0][63:48] = complementValue[63:48]+valueIn[1][63:48]+1;
        RtValue[0][79:64] = complementValue[79:64]+valueIn[1][79:64]+1;
        RtValue[0][95:80] = complementValue[95:80]+valueIn[1][95:80]+1;
        RtValue[0][111:96] = complementValue[111:96]+valueIn[1][111:96]+1;
        RtValue[0][127:112] = complementValue[127:112]+valueIn[1][127:112]+1;
end

/* 18 average bytes*/
else if(evenOpcode == 24)begin
        tempValue16bit[15:8] = 8'h00;
	tempValue16bit[7:0] = valueIn[0][7:0];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][7:0];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][6:0] = tempValue16bit2[7:1];
        RtValue[0][7] = 0;

	tempValue16bit[7:0] = valueIn[0][15:8];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][15:8];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][14:8] = tempValue16bit2[7:1];
        RtValue[0][15] = 0;

	tempValue16bit[7:0] = valueIn[0][23:16];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][23:16];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][22:16] = tempValue16bit2[7:1];
        RtValue[0][23] = 0;

	tempValue16bit[7:0] = valueIn[0][31:24];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][31:24];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][30:24] = tempValue16bit2[7:1];
        RtValue[0][31] = 0;

	tempValue16bit[7:0] = valueIn[0][39:32];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][39:32];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][38:32] = tempValue16bit2[7:1];
        RtValue[0][39] = 0;

	tempValue16bit[7:0] = valueIn[0][47:40];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][47:40];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][46:40] = tempValue16bit2[7:1];
        RtValue[0][47] = 0;

	tempValue16bit[7:0] = valueIn[0][55:48];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][55:48];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][54:48] = tempValue16bit2[7:1];
        RtValue[0][55] = 0;

	tempValue16bit[7:0] = valueIn[0][63:56];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][63:56];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][62:56] = tempValue16bit2[7:1];
        RtValue[0][63] = 0;

	tempValue16bit[7:0] = valueIn[0][71:64];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][71:64];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][70:64] = tempValue16bit2[7:1];
        RtValue[0][71] = 0;

	tempValue16bit[7:0] = valueIn[0][79:72];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][79:72];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][78:72] = tempValue16bit2[7:1];
        RtValue[0][79] = 0;

	tempValue16bit[7:0] = valueIn[0][87:80];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][87:80];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][86:80] = tempValue16bit2[7:1];
        RtValue[0][87] = 0;

	tempValue16bit[7:0] = valueIn[0][95:88];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][95:88];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][94:88] = tempValue16bit2[7:1];
        RtValue[0][95] = 0;

	tempValue16bit[7:0] = valueIn[0][103:96];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][103:96];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][102:96] = tempValue16bit2[7:1];
        RtValue[0][103] = 0;

	tempValue16bit[7:0] = valueIn[0][111:104];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][111:104];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][110:104] = tempValue16bit2[7:1];
        RtValue[0][111] = 0;

	tempValue16bit[7:0] = valueIn[0][119:112];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][119:112];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][118:112] = tempValue16bit2[7:1];
        RtValue[0][119] = 0;

	tempValue16bit[7:0] = valueIn[0][127:120];
	tempValue16bit2[15:8] = 8'h00;
	tempValue16bit2[7:0] = valueIn[1][127:120];
        tempValue16bit2 = tempValue16bit2 +tempValue16bit +1;
        RtValue[0][126:120] = tempValue16bit2[7:1];
        RtValue[0][127] = 0;

end


/* 19 absolute difference of two bytes*/
else if(evenOpcode == 25)begin 
        if((unsigned'(valueIn[1][7:0])) >(unsigned'(valueIn[0][7:0])))begin
            RtValue[0][7:0] = valueIn[1][7:0] - valueIn[0][7:0];
        end
        else begin
             RtValue[0][7:0] = valueIn[0][7:0] - valueIn[1][7:0];
        end

        if((unsigned'(valueIn[1][15:8])) >(unsigned'(valueIn[0][15:8])))begin
            RtValue[0][15:8] = valueIn[1][15:8] - valueIn[0][15:8];
        end
        else begin
             RtValue[0][15:8] = valueIn[0][15:8] - valueIn[1][15:8];
        end

        if((unsigned'(valueIn[1][23:16])) >(unsigned'(valueIn[0][23:16])))begin
            RtValue[0][23:16] = valueIn[1][23:16] - valueIn[0][23:16];
        end
        else begin
             RtValue[0][23:16] = valueIn[0][23:16] - valueIn[1][23:16];
        end

        if((unsigned'(valueIn[1][31:24])) >(unsigned'(valueIn[0][31:24])))begin
            RtValue[0][31:24] = valueIn[1][31:24] - valueIn[0][31:24];
        end
        else begin
             RtValue[0][31:24] = valueIn[0][31:24] - valueIn[1][31:24];
        end

        if((unsigned'(valueIn[1][39:32])) >(unsigned'(valueIn[0][39:32])))begin
            RtValue[0][39:32] = valueIn[1][39:32] - valueIn[0][39:32];
        end
        else begin
             RtValue[0][39:32] = valueIn[0][39:32] - valueIn[1][39:32];
        end

        if((unsigned'(valueIn[1][47:40])) >(unsigned'(valueIn[0][47:40])))begin
            RtValue[0][47:40] = valueIn[1][47:40] - valueIn[0][47:40];
        end
        else begin
             RtValue[0][47:40] = valueIn[0][47:40] - valueIn[1][47:40];
        end

        if((unsigned'(valueIn[1][55:48])) >(unsigned'(valueIn[0][55:48])))begin
            RtValue[0][55:48] = valueIn[1][55:48] - valueIn[0][55:48];
        end
        else begin
             RtValue[0][55:48] = valueIn[0][55:48] - valueIn[1][55:48];
        end

        if((unsigned'(valueIn[1][63:56])) >(unsigned'(valueIn[0][63:56])))begin
            RtValue[0][63:56] = valueIn[1][63:56] - valueIn[0][63:56];
        end
        else begin
             RtValue[0][63:56] = valueIn[0][63:56] - valueIn[1][63:56];
        end

        if((unsigned'(valueIn[1][71:64])) >(unsigned'(valueIn[0][71:64])))begin
            RtValue[0][71:64] = valueIn[1][71:64] - valueIn[0][71:64];
        end
        else begin
             RtValue[0][71:64] = valueIn[0][71:64] - valueIn[1][71:64];
        end

        if((unsigned'(valueIn[1][79:72])) >(unsigned'(valueIn[0][79:72])))begin
            RtValue[0][79:72] = valueIn[1][79:72] - valueIn[0][79:72];
        end
        else begin
             RtValue[0][79:72] = valueIn[0][79:72] - valueIn[1][79:72];
        end

        if((unsigned'(valueIn[1][87:80])) >(unsigned'(valueIn[0][87:80])))begin
            RtValue[0][87:80] = valueIn[1][87:80] - valueIn[0][87:80];
        end
        else begin
             RtValue[0][87:80] = valueIn[0][87:80] - valueIn[1][87:80];
        end

        if((unsigned'(valueIn[1][95:88])) >(unsigned'(valueIn[0][95:88])))begin
            RtValue[0][95:88] = valueIn[1][95:88] - valueIn[0][95:88];
        end
        else begin
             RtValue[0][95:88] = valueIn[0][95:88] - valueIn[1][95:88];
        end

        if((unsigned'(valueIn[1][103:96])) >(unsigned'(valueIn[0][103:96])))begin
            RtValue[0][103:96] = valueIn[1][103:96] - valueIn[0][103:96];
        end
        else begin
             RtValue[0][103:96] = valueIn[0][103:96] - valueIn[1][103:96];
        end

        if((unsigned'(valueIn[1][111:104])) >(unsigned'(valueIn[0][111:104])))begin
            RtValue[0][111:104] = valueIn[1][111:104] - valueIn[0][111:104];
        end
        else begin
             RtValue[0][111:104] = valueIn[0][111:104] - valueIn[1][111:104];
        end

        if((unsigned'(valueIn[1][119:112])) >(unsigned'(valueIn[0][119:112])))begin
            RtValue[0][119:112] = valueIn[1][119:112] - valueIn[0][119:112];
        end
        else begin
             RtValue[0][119:112] = valueIn[0][119:112] - valueIn[1][119:112];
        end

        if((unsigned'(valueIn[1][127:120])) >(unsigned'(valueIn[0][127:120])))begin
            RtValue[0][127:120] = valueIn[1][127:120] - valueIn[0][127:120];
        end
        else begin
             RtValue[0][127:120] = valueIn[0][127:120] - valueIn[1][127:120];
        end
end

/* 20 sum bytes into halfword*/
else if(evenOpcode == 26)begin

    RtValue[0][15:0] = unsigned'(valueIn[1][31:24]) +unsigned'(valueIn[1][23:16]) +unsigned'(valueIn[1][15:8]) +unsigned'(valueIn[1][7:0]);
    RtValue[0][31:16] = unsigned'(valueIn[0][31:24]) +unsigned'(valueIn[0][23:16]) +unsigned'(valueIn[0][15:8]) +unsigned'(valueIn[0][7:0]);
    RtValue[0][47:32] = unsigned'(valueIn[1][63:56]) +unsigned'(valueIn[1][55:48]) +unsigned'(valueIn[1][47:40]) +unsigned'(valueIn[1][39:32]);
    RtValue[0][63:48] = unsigned'(valueIn[0][63:56]) +unsigned'(valueIn[0][55:48]) +unsigned'(valueIn[0][47:40]) +unsigned'(valueIn[0][39:32]);
    RtValue[0][79:64] = unsigned'(valueIn[1][95:88]) +unsigned'(valueIn[1][87:80]) +unsigned'(valueIn[1][79:72]) +unsigned'(valueIn[1][71:64]);
    RtValue[0][95:80] = unsigned'(valueIn[0][95:88]) +unsigned'(valueIn[0][87:80]) +unsigned'(valueIn[0][79:72]) +unsigned'(valueIn[0][71:64]);
    RtValue[0][111:96] = unsigned'(valueIn[1][127:120]) +unsigned'(valueIn[1][119:112]) +unsigned'(valueIn[1][111:104]) +unsigned'(valueIn[1][103:96]);
    RtValue[0][127:112] = unsigned'(valueIn[0][127:120]) +unsigned'(valueIn[0][119:112]) +unsigned'(valueIn[0][111:104]) +unsigned'(valueIn[0][103:96]);
end

/* 21 multiply unsigned*/
else if(evenOpcode == 27)begin
RtValue[0][31:0] = unsigned'(valueIn[0][15:0])* unsigned'(valueIn[1][15:0]);
        RtValue[0][63:32] = unsigned'(valueIn[0][47:32])* unsigned'(valueIn[1][47:32]);
        RtValue[0][95:64] = unsigned'(valueIn[0][79:64])* unsigned'(valueIn[1][79:64]);
        RtValue[0][127:96] = unsigned'(valueIn[0][111:96])* unsigned'(valueIn[1][111:96]);
end

/* 22 multiply immediate*/
else if(evenOpcode == 28)begin

    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

RtValue[0][31:0] = (valueIn[0][15:0])* (immediate16);
        RtValue[0][63:32] = (valueIn[0][47:32])* (immediate16);
        RtValue[0][95:64] = (valueIn[0][79:64])* (immediate16);
        RtValue[0][127:96] = (valueIn[0][111:96])* (immediate16);
end


/* 23 multiply unsigned immediate*/

else if(evenOpcode == 29)begin

    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

RtValue[0][31:0] = unsigned'(valueIn[0][15:0])* unsigned'(immediate16);
        RtValue[0][63:32] = unsigned'(valueIn[0][47:32])* unsigned'(immediate16);
        RtValue[0][95:64] = unsigned'(valueIn[0][79:64])* unsigned'(immediate16);
        RtValue[0][127:96] = unsigned'(valueIn[0][111:96])* unsigned'(immediate16);
end



/*  24 immediate load halfword*/
else if( evenOpcode == 30)begin
        RtValue[0][15:0] = immediateIn[0][15:0];
        RtValue[0][31:16] = immediateIn[0][15:0];
        RtValue[0][47:32] = immediateIn[0][15:0];
        RtValue[0][63:48] = immediateIn[0][15:0];
        RtValue[0][79:64] = immediateIn[0][15:0];
        RtValue[0][95:80] = immediateIn[0][15:0];
        RtValue[0][111:96] = immediateIn[0][15:0];
        RtValue[0][127:112] = immediateIn[0][15:0];
end

/* 25 immediate load halfword upper*/
else if( evenOpcode == 31)begin
    immediate32[31:16] = immediateIn[0][15:0];
    immediate32[15:0] = 16'h0000;
    RtValue[0][31:0] = immediate32 ;
    RtValue[0][63:32] = immediate32 ;
    RtValue[0][95:64] = immediate32 ;
    RtValue[0][127:96] = immediate32 ;	
end

/* 26immediate load word*/
else if( evenOpcode == 32)begin
    if(immediateIn[0][15] == 1)begin 
        immediate32[31:15] = 17'b11111111111111111;
        immediate32[14:0] = immediateIn[0][14:0];
    end
    else begin
        immediate32[31:15] = 17'b00000000000000000;
        immediate32[14:0] = immediateIn[0][14:0];
    end
    RtValue[0][31:0] = immediate32 ;
    RtValue[0][63:32] = immediate32 ;
    RtValue[0][95:64] = immediate32 ;
    RtValue[0][127:96] = immediate32 ;	
end


/* 27 immediate load address*/
 else if(evenOpcode == 33) begin
     immediate32[31:18] = 14'b00000000000000;
     immediate32[17:0] = immediateIn[0];
     RtValue[0][31:0] = immediate32;
     RtValue[0][63:32] = immediate32;
     RtValue[0][95:64] = immediate32;
     RtValue[0][127:96] = immediate32;
 end

/* 28 equivalent*/
else if(evenOpcode == 34) begin 
    for (int i=0; i<128; i++) begin
        if(valueIn[0][i] == valueIn[1][i])begin
            RtValue[0][i] = 1;
        end
        else begin
            RtValue[0][i] = 0;
        end
    end
end


/*  29 form select mask for bytes immediate */

else if(evenOpcode == 35) begin
immediate16 = immediateIn[0][15:0];
        if(immediate16[0]==1)begin
            RtValue[0][7:0]= 8'hFF;
        end
        else begin
            RtValue[0][7:0] = 8'h00;
        end

        if(immediate16[1]==1)begin
            RtValue[0][15:8]= 8'hFF;
        end
        else begin
            RtValue[0][15:8] = 8'h00;
        end

        if(immediate16[2]==1)begin
            RtValue[0][23:16]= 8'hFF;
        end
        else begin
            RtValue[0][23:16] = 8'h00;
        end

        if(immediate16[3]==1)begin
            RtValue[0][31:24]= 8'hFF;
        end
        else begin
            RtValue[0][31:24] = 8'h00;
        end

        if(immediate16[4]==1)begin
            RtValue[0][39:32]= 8'hFF;
        end
        else begin
            RtValue[0][39:32] = 8'h00;
        end

        if(immediate16[5]==1)begin
            RtValue[0][47:40]= 8'hFF;
        end
        else begin
            RtValue[0][47:40] = 8'h00;
        end

        if(immediate16[6]==1)begin
            RtValue[0][55:48]= 8'hFF;
        end
        else begin
            RtValue[0][55:48] = 8'h00;
        end

        if(immediate16[7]==1)begin
            RtValue[0][63:56]= 8'hFF;
        end
        else begin
            RtValue[0][63:56] = 8'h00;
        end

        if(immediate16[8]==1)begin
            RtValue[0][71:64]= 8'hFF;
        end
        else begin
            RtValue[0][71:64] = 8'h00;
        end

        if(immediate16[9]==1)begin
            RtValue[0][79:72]= 8'hFF;
        end
        else begin
            RtValue[0][79:72] = 8'h00;
        end

        if(immediate16[10]==1)begin
            RtValue[0][87:80]= 8'hFF;
        end
        else begin
            RtValue[0][87:80] = 8'h00;
        end

        if(immediate16[11]==1)begin
            RtValue[0][95:88]= 8'hFF;
        end
        else begin
            RtValue[0][95:88] = 8'h00;
        end

        if(immediate16[12]==1)begin
            RtValue[0][103:96]= 8'hFF;
        end
        else begin
            RtValue[0][103:96] = 8'h00;
        end

        if(immediate16[13]==1)begin
            RtValue[0][111:104]= 8'hFF;
        end
        else begin
            RtValue[0][111:104] = 8'h00;
        end

        if(immediate16[14]==1)begin
            RtValue[0][119:112]= 8'hFF;
        end
        else begin
            RtValue[0][119:112] = 8'h00;
        end

        if(immediate16[15]==1)begin
            RtValue[0][127:120]= 8'hFF;
        end
        else begin
            RtValue[0][127:120] = 8'h00;
        end
end

/* 30 count ones in bytes*/
else if(evenOpcode == 36) begin
    	tempValue8bit = valueIn[0][7:0];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][7:0] = counter;

    	tempValue8bit = valueIn[0][15:8];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][15:8] = counter;

    	tempValue8bit = valueIn[0][23:16];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][23:16] = counter;

    	tempValue8bit = valueIn[0][31:24];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][31:24] = counter;

    	tempValue8bit = valueIn[0][39:32];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][39:32] = counter;

    	tempValue8bit = valueIn[0][47:40];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][47:40] = counter;

    	tempValue8bit = valueIn[0][55:48];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][55:48] = counter;

    	tempValue8bit = valueIn[0][63:56];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][63:56] = counter;

    	tempValue8bit = valueIn[0][71:64];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][71:64] = counter;

    	tempValue8bit = valueIn[0][79:72];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][79:72] = counter;

    	tempValue8bit = valueIn[0][87:80];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][87:80] = counter;

    	tempValue8bit = valueIn[0][95:88];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][95:88] = counter;

    	tempValue8bit = valueIn[0][103:96];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][103:96] = counter;

    	tempValue8bit = valueIn[0][111:104];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][111:104] = counter;

    	tempValue8bit = valueIn[0][119:112];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][119:112] = counter;

    	tempValue8bit = valueIn[0][127:120];
        counter = 0;
        if(tempValue8bit[0] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[1] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[2] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[3] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[4] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[5] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[6] == 1)begin
            counter = counter +1;
        end
        if(tempValue8bit[7] == 1)begin
            counter = counter +1;
        end
    	RtValue[0][127:120] = counter;
end

/*  31 gather bits from bytes */
else if(evenOpcode == 37)begin
    
    RtValue[0][127:112] = 16'h0000;
    RtValue[0][111] = valueIn[0][120];
    RtValue[0][110] = valueIn[0][112];
    RtValue[0][109] = valueIn[0][104];
    RtValue[0][108] = valueIn[0][96];
    RtValue[0][107] = valueIn[0][88];
    RtValue[0][106] = valueIn[0][80];
    RtValue[0][105] = valueIn[0][72];
    RtValue[0][104] = valueIn[0][64];
    RtValue[0][103] = valueIn[0][56];
    RtValue[0][102] = valueIn[0][48];
    RtValue[0][101] = valueIn[0][40];
    RtValue[0][100] = valueIn[0][32];
    RtValue[0][99] = valueIn[0][24];
    RtValue[0][98] = valueIn[0][16];
    RtValue[0][97] = valueIn[0][8];
    RtValue[0][96] = valueIn[0][0];
    RtValue[0][95:0] = 96'h000000000000000000000000;
end

/*  32 gather bits from halfword */

else if(evenOpcode == 38)begin
    
    RtValue[0][127:104] = 24'h000000;
    RtValue[0][103] = valueIn[0][112];
    RtValue[0][102] = valueIn[0][96];
    RtValue[0][101] = valueIn[0][80];
    RtValue[0][100] = valueIn[0][64];
    RtValue[0][99] = valueIn[0][48];
    RtValue[0][98] = valueIn[0][32];
    RtValue[0][97] = valueIn[0][16];
    RtValue[0][96] = valueIn[0][0];
    RtValue[0][95:0] = 96'h000000000000000000000000;
end


/*  33 gather bits from word */

else if(evenOpcode == 39)begin
   RtValue[0][127:100] = 28'h0000000;
    RtValue[0][99] = valueIn[0][96];
    RtValue[0][98] = valueIn[0][64];
    RtValue[0][97] = valueIn[0][32];
    RtValue[0][96] = valueIn[0][0];
    RtValue[0][95:0] = 96'h000000000000000000000000;
end

/*  34 and byte immediate*/

else if(evenOpcode == 40) begin
    for(int i =7; i<128; i = i+8)begin
            for(int j= 0; j< 8; j++)begin
                if((immediateIn[0][j] == 1) && (valueIn[0][i+j-7] == 1))begin
                    RtValue[0][i+j-7] = 1;
                end
                else begin
                    RtValue[0][i+j-7] = 0;
                end
            end
        end 
    end


/* 35 and halfword immediate*/

else if(evenOpcode == 41) begin
    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

    for(int i =15; i<128; i = i+16)begin
            for(int j= 0; j< 16; j++)begin
                if((immediate16[j] == 1) && (valueIn[0][i+j-15] == 1))begin
                    RtValue[0][i+j-15] = 1;
                end
                else begin
                    RtValue[0][i+j-15] = 0;
                end
            end
        end 
    end

/* 36 and word immediate*/
    else if(evenOpcode == 42) begin
    if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'h7fffff;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'h000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end

    for(int i =31; i<128; i = i+32)begin
            for(int j= 0; j< 32; j++)begin
                if((immediate32[j] == 1) && (valueIn[0][i+j-31] == 1))begin
                    RtValue[0][i+j-31] = 1;
                end
                else begin
                    RtValue[0][i+j-31] = 0;
                end
            end
        end 
    end

/*  37 or byte immediate*/

else if(evenOpcode == 43) begin         //   00000000101
    for(int i =7; i<128; i = i+8)begin
            for(int j= 0; j< 8; j++)begin
                if((immediateIn[0][j] == 0) && (valueIn[0][i+j-7] == 0))begin
                    RtValue[0][i+j-7] = 0;
                end
                else begin
                    RtValue[0][i+j-7] = 1;
                end
            end
        end 
    end

/* 38 or halfword immediate*/

else if(evenOpcode == 44) begin
    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

    for(int i =15; i<128; i = i+16)begin
            for(int j= 0; j< 16; j++)begin
                if((immediate16[j] == 0) && (valueIn[0][i+j-15] == 0))begin
                    RtValue[0][i+j-15] = 0;
                end
                else begin
                    RtValue[0][i+j-15] = 1;
                end
            end
        end 
    end
/* 39 or word immediate*/

else if(evenOpcode == 45) begin
    if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'h7fffff;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'h000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end

    for(int i =31; i<128; i = i+32)begin
            for(int j= 0; j< 32; j++)begin
                if((immediate32[j] == 0) && (valueIn[0][i+j-31] == 0))begin
                    RtValue[0][i+j-31] = 0;
                end
                else begin
                    RtValue[0][i+j-31] = 1;
                end
            end
        end 
    end

/*  40 xor byte immediate*/

else if(evenOpcode == 46) begin
    for(int i =7; i<128; i = i+8)begin
            for(int j= 0; j< 8; j++)begin
                if(immediateIn[0][j] != valueIn[0][i+j-7])begin
                    RtValue[0][i+j-7] = 1;
                end
                else begin
                    RtValue[0][i+j-7] = 0;
                end
            end
        end 
    end


/* 41 xor halfword immediate*/
else if(evenOpcode == 47) begin
    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end

    for(int i =15; i<128; i = i+16)begin
            for(int j= 0; j< 16; j++)begin
                if(immediate16[j] != valueIn[0][i+j-15])begin
                    RtValue[0][i+j-15] = 1;
                end
                else begin
                    RtValue[0][i+j-15] = 0;
                end
            end
        end 
    end

/* 42 xor word immediate*/

else if(evenOpcode == 48) begin
    if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'h7fffff;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'h000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end

    for(int i =31; i<128; i = i+32)begin
            for(int j= 0; j< 32; j++)begin
                if(immediate32[j] != valueIn[0][i+j-31])begin
                    RtValue[0][i+j-31] = 1;
                end
                else begin
                    RtValue[0][i+j-31] = 0;
                end
            end
        end 
    end


/*  43 shift left halfword*/
else if(evenOpcode == 49)begin 
    	    shiftAmount = 0;
            shiftAmount[4:0] = unsigned'(valueIn[1][4:0]);
            tempValue16bit = valueIn[0][15:0]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][15:0] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][20:16]);
            tempValue16bit = valueIn[0][31:16]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][31:16] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][36:32]);
            tempValue16bit = valueIn[0][47:32]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][47:32] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][52:48]);
            tempValue16bit = valueIn[0][63:58]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][63:48] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][68:64]);
            tempValue16bit = valueIn[0][79:64]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][79:64] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][84:80]);
            tempValue16bit = valueIn[0][95:80]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b-shiftAmount[4:0])>=0)begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][95:80] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][100:96]);
            tempValue16bit = valueIn[0][111:96]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][111:96] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][116:112]);
            tempValue16bit = valueIn[0][127:112]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][127:112] = tempValue16bit2;

end


/*  44 shift left halfword immediate*/

else if(evenOpcode == 50)begin 
    shiftAmount = 0;
    shiftAmount[4:0] = unsigned'(immediateIn[0][4:0]);
            tempValue16bit = valueIn[0][15:0]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][15:0] = tempValue16bit2;

            tempValue16bit = valueIn[0][31:16]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][31:16] = tempValue16bit2;

            tempValue16bit = valueIn[0][47:32]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][47:32] = tempValue16bit2;

            tempValue16bit = valueIn[0][63:58]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][63:58] = tempValue16bit2;

            tempValue16bit = valueIn[0][79:64]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][79:64] = tempValue16bit2;

            tempValue16bit = valueIn[0][95:80]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][95:80] = tempValue16bit2;

            tempValue16bit = valueIn[0][111:96]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][111:96] = tempValue16bit2;

            tempValue16bit = valueIn[0][127:112]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = 0;
                end

            end
            RtValue[0][127:112] = tempValue16bit2;
end


/*  45 rotate  halfword*/

else if(evenOpcode == 51)begin 
    	    shiftAmount = 0;
            shiftAmount[3:0] = unsigned'(valueIn[1][3:0]);
            tempValue16bit = valueIn[0][15:0]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][15:0] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][19:16]);
            tempValue16bit = valueIn[0][31:16]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][31:16] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][35:32]);
            tempValue16bit = valueIn[0][47:32]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][47:32] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][51:48]);
            tempValue16bit = valueIn[0][63:58]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][63:58] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][67:64]);
            tempValue16bit = valueIn[0][79:64]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][79:64] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][83:80]);
            tempValue16bit = valueIn[0][95:80]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][95:80] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][99:96]);
            tempValue16bit = valueIn[0][111:96]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][111:96] = tempValue16bit2;

            shiftAmount[3:0] = unsigned'(valueIn[1][115:112]);
            tempValue16bit = valueIn[0][127:112]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][127:112] = tempValue16bit2;
end

/*  46 rotate halfword immediate */

else if(evenOpcode == 52)begin 
    shiftAmount = 0;
    shiftAmount[3:0] = unsigned'(immediateIn[0][3:0]);
            tempValue16bit = valueIn[0][15:0]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][15:0] = tempValue16bit2;

            tempValue16bit = valueIn[0][31:16]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][31:16] = tempValue16bit2;

            tempValue16bit = valueIn[0][47:32]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][47:32] = tempValue16bit2;

            tempValue16bit = valueIn[0][63:58]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][63:58] = tempValue16bit2;

            tempValue16bit = valueIn[0][79:64]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][79:64] = tempValue16bit2;

            tempValue16bit = valueIn[0][95:80]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][95:80] = tempValue16bit2;

            tempValue16bit = valueIn[0][111:96]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][111:96] = tempValue16bit2;

            tempValue16bit = valueIn[0][127:112]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount];
                end
                else begin
                    tempValue16bit2[b] = tempValue16bit[b-shiftAmount+16];
                end

            end
            RtValue[0][127:112] = tempValue16bit2;
end
/*  47 shift left word*/

else if(evenOpcode == 53)begin 
    	    shiftAmount = 0;
            shiftAmount[5:0] = unsigned'(valueIn[1][5:0]);
            tempValue = valueIn[0][31:0]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][31:0] = tempValue2;

            shiftAmount[4:0] = unsigned'(valueIn[1][37:32]);
            tempValue = valueIn[0][63:32]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][63:32] = tempValue2;

            shiftAmount[4:0] = unsigned'(valueIn[1][69:64]);
            tempValue = valueIn[0][95:64]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][95:64] = tempValue2;

            shiftAmount[4:0] = unsigned'(valueIn[1][101:96]);
            tempValue = valueIn[0][127:96];  
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][127:96] = tempValue2;


end


/*  48 shift left word immediate*/

else if(evenOpcode == 54)begin 
    shiftAmount = 0;
    shiftAmount[5:0] = unsigned'(immediateIn[0][5:0]);
            tempValue = valueIn[0][31:0]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][31:0] = tempValue2;

            tempValue = valueIn[0][63:32]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][63:32] = tempValue2;

            tempValue = valueIn[0][95:64]; 
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][95:64] = tempValue2;

            tempValue = valueIn[0][127:96];  
            for(int b= 31; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = 0;
                end

            end
            RtValue[0][127:96] = tempValue2;


end
/*  49 rotate  word*/

else if(evenOpcode == 55)begin 
    	    shiftAmount = 0;
            shiftAmount[4:0] = unsigned'(valueIn[1][4:0]);
            tempValue = valueIn[0][31:0]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end
            end
            RtValue[0][31:0] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][36:32]);
            tempValue = valueIn[0][63:32]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end
            end
            RtValue[0][63:32] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][68:64]);
            tempValue = valueIn[0][95:64]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end
            end
            RtValue[0][95:64] = tempValue16bit2;

            shiftAmount[4:0] = unsigned'(valueIn[1][100:96]);
            tempValue = valueIn[0][127:96]; 
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end
            end
            RtValue[0][127:96] = tempValue16bit2;
end


/*  50 rotate  word immediate */

else if(evenOpcode == 56)begin 
    shiftAmount = 0;
    shiftAmount[4:0] = unsigned'(immediateIn[0][4:0]);
            tempValue = valueIn[0][31:0];  
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end

            end
            RtValue[0][31:0] = tempValue2;

            tempValue = valueIn[0][63:32];  
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end

            end
            RtValue[0][63:32] = tempValue2;

            tempValue = valueIn[0][95:64];  
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end

            end
            RtValue[0][95:64] = tempValue2;

            tempValue = valueIn[0][127:96];  
            for(int b= 15; b >= 0; b-- )begin
                if((b >= shiftAmount))begin
                    tempValue2[b] = tempValue[b-shiftAmount];
                end
                else begin
                    tempValue2[b] = tempValue[b-shiftAmount+32];
                end

            end
            RtValue[0][127:96] = tempValue2;

end

/*  51 compare logic > halfword  opcode == 65*/ 
else if(evenOpcode == 65)begin
            if( (unsigned'(valueIn[0][15:0]))  > (unsigned'(valueIn[1][15:0])) ) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][31:16]))  > (unsigned'(valueIn[1][31:16])) ) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][47:32]))  > (unsigned'(valueIn[1][47:32])) ) begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][63:48]))  > (unsigned'(valueIn[1][63:48])) ) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][79:64]))  > (unsigned'(valueIn[1][79:64])) ) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][95:80]))  > (unsigned'(valueIn[1][95:80])) ) begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][111:96]))  > (unsigned'(valueIn[1][111:96])) ) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][127:112]))  > (unsigned'(valueIn[1][127:112])) ) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end

end

/*  52 compare logic > halfword immediate  opcode == 66*/ 

else if(evenOpcode == 66)begin
        if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end
            if ((unsigned'(valueIn[0][15:0]))  > (unsigned'(immediate16))) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][31:16]))  > (unsigned'(immediate16))) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][47:32]))  > (unsigned'(immediate16)))begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][63:48]))  > (unsigned'(immediate16))) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][79:64]))  > (unsigned'(immediate16))) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][95:80]))  > (unsigned'(immediate16)))begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][111:96]))  > (unsigned'(immediate16))) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][127:112]))  > (unsigned'(immediate16))) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end
end

/*  53 compare logic > word  opcode == 67*/ 

else if(evenOpcode == 67)begin
            if( (unsigned'(valueIn[0][31:0]))  > (unsigned'(valueIn[1][31:0])) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][63:32]))  > (unsigned'(valueIn[1][63:32])) ) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][95:64]))  > (unsigned'(valueIn[1][95:64])) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][127:96]))  > (unsigned'(valueIn[1][127:96])) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end

end

/*  54 compare logic > word immediate  opcode == 68*/ 

else if(evenOpcode == 68)begin
     if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'b11111111111111111111111;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'b00000000000000000000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end
            if( (unsigned'(valueIn[0][31:0]))  > (unsigned'(immediate32)) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][63:32]))  > (unsigned'(immediate32)) ) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][95:64]))  > (unsigned'(immediate32)) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (unsigned'(valueIn[0][127:96]))  > (unsigned'(immediate32)) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end
end


/* 55 compare equal byte   opcode == 69 */
else if(evenOpcode == 69)begin
        if( valueIn[0][7:0] == valueIn[1][7:0] )begin
            RtValue[0][7:0] = 8'hff;
        end
        else begin
            RtValue[0][7:0] = 8'h00;
        end

        if( valueIn[0][15:8] == valueIn[1][15:8] )begin
            RtValue[0][15:8] = 8'hff;
        end
        else begin
            RtValue[0][15:8] = 8'h00;
        end

        if( valueIn[0][23:16] == valueIn[1][23:16] )begin
            RtValue[0][23:16] = 8'hff;
        end
        else begin
            RtValue[0][23:16] = 8'h00;
        end

        if( valueIn[0][31:24] == valueIn[1][31:24] )begin
            RtValue[0][31:24] = 8'hff;
        end
        else begin
            RtValue[0][31:24] = 8'h00;
        end

        if( valueIn[0][39:32] == valueIn[1][39:32] )begin
            RtValue[0][39:32] = 8'hff;
        end
        else begin
            RtValue[0][39:32] = 8'h00;
        end

        if( valueIn[0][47:40] == valueIn[1][47:40] )begin
            RtValue[0][47:40] = 8'hff;
        end
        else begin
            RtValue[0][47:40] = 8'h00;
        end

        if( valueIn[0][55:48] == valueIn[1][55:48] )begin
            RtValue[0][55:48] = 8'hff;
        end
        else begin
            RtValue[0][55:48] = 8'h00;
        end

        if( valueIn[0][63:56] == valueIn[1][63:56] )begin
            RtValue[0][63:56] = 8'hff;
        end
        else begin
            RtValue[0][63:56] = 8'h00;
        end

        if( valueIn[0][71:64] == valueIn[1][71:64] )begin
            RtValue[0][71:64] = 8'hff;
        end
        else begin
            RtValue[0][71:64] = 8'h00;
        end

        if( valueIn[0][79:72] == valueIn[1][79:72] )begin
            RtValue[0][79:72] = 8'hff;
        end
        else begin
            RtValue[0][79:72] = 8'h00;
        end

        if( valueIn[0][87:80] == valueIn[1][87:80] )begin
            RtValue[0][87:80] = 8'hff;
        end
        else begin
            RtValue[0][87:80] = 8'h00;
        end

        if( valueIn[0][95:88] == valueIn[1][95:88] )begin
            RtValue[0][95:88] = 8'hff;
        end
        else begin
            RtValue[0][95:88] = 8'h00;
        end

        if( valueIn[0][103:96] == valueIn[1][103:96] )begin
            RtValue[0][103:96] = 8'hff;
        end
        else begin
            RtValue[0][103:96] = 8'h00;
        end

        if( valueIn[0][111:104] == valueIn[1][111:104] )begin
            RtValue[0][111:104] = 8'hff;
        end
        else begin
            RtValue[0][111:104] = 8'h00;
        end

        if( valueIn[0][119:112] == valueIn[1][119:112] )begin
            RtValue[0][119:112] = 8'hff;
        end
        else begin
            RtValue[0][119:112] = 8'h00;
        end

        if( valueIn[0][127:120] == valueIn[1][127:120] )begin
            RtValue[0][127:120] = 8'hff;
        end
        else begin
            RtValue[0][127:120] = 8'h00;
        end

end
/* 56 compare equal byte immediate  opcode == 70 */

else if(evenOpcode == 70)begin
        if( valueIn[0][7:0] == immediateIn[0][7:0] )begin
            RtValue[0][7:0] = 8'hff;
        end
        else begin
            RtValue[0][7:0] = 8'h00;
        end

        if( valueIn[0][15:8] == immediateIn[0][7:0] )begin
            RtValue[0][15:8] = 8'hff;
        end
        else begin
            RtValue[0][15:8] = 8'h00;
        end

        if( valueIn[0][23:16] == immediateIn[0][7:0] )begin
            RtValue[0][23:16] = 8'hff;
        end
        else begin
            RtValue[0][23:16] = 8'h00;
        end

        if( valueIn[0][31:24] == immediateIn[0][7:0] )begin
            RtValue[0][31:24] = 8'hff;
        end
        else begin
            RtValue[0][31:24] = 8'h00;
        end

        if( valueIn[0][39:32] == immediateIn[0][7:0] )begin
            RtValue[0][39:32] = 8'hff;
        end
        else begin
            RtValue[0][39:32] = 8'h00;
        end

        if( valueIn[0][47:40] == immediateIn[0][7:0] )begin
            RtValue[0][47:40] = 8'hff;
        end
        else begin
            RtValue[0][47:40] = 8'h00;
        end

        if( valueIn[0][55:48] == immediateIn[0][7:0] )begin
            RtValue[0][55:48] = 8'hff;
        end
        else begin
            RtValue[0][55:48] = 8'h00;
        end

        if( valueIn[0][63:56] == immediateIn[0][7:0] )begin
            RtValue[0][63:56] = 8'hff;
        end
        else begin
            RtValue[0][63:56] = 8'h00;
        end

        if( valueIn[0][71:64] == immediateIn[0][7:0] )begin
            RtValue[0][71:64] = 8'hff;
        end
        else begin
            RtValue[0][71:64] = 8'h00;
        end

        if( valueIn[0][79:72] == immediateIn[0][7:0] )begin
            RtValue[0][79:72] = 8'hff;
        end
        else begin
            RtValue[0][79:72] = 8'h00;
        end

        if( valueIn[0][87:80] == immediateIn[0][7:0])begin
            RtValue[0][87:80] = 8'hff;
        end
        else begin
            RtValue[0][87:80] = 8'h00;
        end

        if( valueIn[0][95:88] == immediateIn[0][7:0] )begin
            RtValue[0][95:88] = 8'hff;
        end
        else begin
            RtValue[0][95:88] = 8'h00;
        end

        if( valueIn[0][103:96] == immediateIn[0][7:0] )begin
            RtValue[0][103:96] = 8'hff;
        end
        else begin
            RtValue[0][103:96] = 8'h00;
        end

        if( valueIn[0][111:104] == immediateIn[0][7:0] )begin
            RtValue[0][111:104] = 8'hff;
        end
        else begin
            RtValue[0][111:104] = 8'h00;
        end

        if( valueIn[0][119:112] == immediateIn[0][7:0] )begin
            RtValue[0][119:112] = 8'hff;
        end
        else begin
            RtValue[0][119:112] = 8'h00;
        end

        if( valueIn[0][127:120] == immediateIn[0][7:0])begin
            RtValue[0][127:120] = 8'hff;
        end
        else begin
            RtValue[0][127:120] = 8'h00;
        end

end

/* 57 compare equal halfword   opcode == 71 */

else if(evenOpcode == 71)begin
            if( (unsigned'(valueIn[0][15:0])) == (unsigned'(valueIn[1][15:0])) ) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][31:16])) == (unsigned'(valueIn[1][31:16])) ) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][47:32]))  == (unsigned'(valueIn[1][47:32])) ) begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][63:48]))  == (unsigned'(valueIn[1][63:48])) ) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][79:64]))  == (unsigned'(valueIn[1][79:64])) ) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][95:80]))  == (unsigned'(valueIn[1][95:80])) ) begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][111:96]))  == (unsigned'(valueIn[1][111:96])) ) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][127:112]))  == (unsigned'(valueIn[1][127:112])) ) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end

end


/* 58 compare equal halfword immediate  opcode == 72 */

else if(evenOpcode == 72)begin
    if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end
            if ((unsigned'(valueIn[0][15:0])) == immediate16 ) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][31:16]))  == immediate16) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][47:32]))  == immediate16)begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][63:48]))  == immediate16) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][79:64]))  == immediate16) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][95:80]))  == immediate16)begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][111:96]))  == immediate16) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (unsigned'(valueIn[0][127:112]))  == immediate16) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end
end
/* 59 compare equal word   opcode == 73 */

else if(evenOpcode == 73)begin
            if( (valueIn[0][31:0]) == (valueIn[1][31:0]) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (valueIn[0][63:32]) == (valueIn[1][63:32]) ) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (valueIn[0][95:64]) == (valueIn[1][95:64]) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (valueIn[0][127:96]) == (valueIn[1][127:96]) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end

end



/* 60 compare equal word immediate  opcode == 74 */
else if(evenOpcode == 74)begin
     if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'b11111111111111111111111;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'b00000000000000000000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end
            if( (valueIn[0][31:0]) == (immediate32) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (valueIn[0][63:32]) == (immediate32)) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (valueIn[0][95:64])  == (immediate32) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (valueIn[0][127:96]) == (immediate32) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end
end


/* 61 compare > byte   opcode == 75 */

else if(evenOpcode == 75)begin
        if( valueIn[0][7:0] > valueIn[1][7:0] )begin
            RtValue[0][7:0] = 8'hff;
        end
        else begin
            RtValue[0][7:0] = 8'h00;
        end

        if( valueIn[0][15:8] > valueIn[1][15:8] )begin
            RtValue[0][15:8] = 8'hff;
        end
        else begin
            RtValue[0][15:8] = 8'h00;
        end

        if( valueIn[0][23:16] > valueIn[1][23:16] )begin
            RtValue[0][23:16] = 8'hff;
        end
        else begin
            RtValue[0][23:16] = 8'h00;
        end

        if( valueIn[0][31:24] > valueIn[1][31:24] )begin
            RtValue[0][31:24] = 8'hff;
        end
        else begin
            RtValue[0][31:24] = 8'h00;
        end

        if( valueIn[0][39:32] > valueIn[1][39:32] )begin
            RtValue[0][39:32] = 8'hff;
        end
        else begin
            RtValue[0][39:32] = 8'h00;
        end

        if( valueIn[0][47:40] > valueIn[1][47:40] )begin
            RtValue[0][47:40] = 8'hff;
        end
        else begin
            RtValue[0][47:40] = 8'h00;
        end

        if( valueIn[0][55:48] > valueIn[1][55:48] )begin
            RtValue[0][55:48] = 8'hff;
        end
        else begin
            RtValue[0][55:48] = 8'h00;
        end

        if( valueIn[0][63:56] > valueIn[1][63:56] )begin
            RtValue[0][63:56] = 8'hff;
        end
        else begin
            RtValue[0][63:56] = 8'h00;
        end

        if( valueIn[0][71:64] > valueIn[1][71:64] )begin
            RtValue[0][71:64] = 8'hff;
        end
        else begin
            RtValue[0][71:64] = 8'h00;
        end

        if( valueIn[0][79:72] > valueIn[1][79:72] )begin
            RtValue[0][79:72] = 8'hff;
        end
        else begin
            RtValue[0][79:72] = 8'h00;
        end

        if( valueIn[0][87:80] > valueIn[1][87:80] )begin
            RtValue[0][87:80] = 8'hff;
        end
        else begin
            RtValue[0][87:80] = 8'h00;
        end

        if( valueIn[0][95:88] > valueIn[1][95:88] )begin
            RtValue[0][95:88] = 8'hff;
        end
        else begin
            RtValue[0][95:88] = 8'h00;
        end

        if( valueIn[0][103:96] > valueIn[1][103:96] )begin
            RtValue[0][103:96] = 8'hff;
        end
        else begin
            RtValue[0][103:96] = 8'h00;
        end

        if( valueIn[0][111:104] > valueIn[1][111:104] )begin
            RtValue[0][111:104] = 8'hff;
        end
        else begin
            RtValue[0][111:104] = 8'h00;
        end

        if( valueIn[0][119:112] > valueIn[1][119:112] )begin
            RtValue[0][119:112] = 8'hff;
        end
        else begin
            RtValue[0][119:112] = 8'h00;
        end

        if( valueIn[0][127:120] > valueIn[1][127:120] )begin
            RtValue[0][127:120] = 8'hff;
        end
        else begin
            RtValue[0][127:120] = 8'h00;
        end

end

/* 62 compare > byte immediate  opcode == 76 */

else if(evenOpcode == 76)begin
        if( valueIn[0][7:0] > immediateIn[0][7:0] )begin
            RtValue[0][7:0] = 8'hff;
        end
        else begin
            RtValue[0][7:0] = 8'h00;
        end

        if( valueIn[0][15:8] > immediateIn[0][7:0] )begin
            RtValue[0][15:8] = 8'hff;
        end
        else begin
            RtValue[0][15:8] = 8'h00;
        end

        if( valueIn[0][23:16] > immediateIn[0][7:0] )begin
            RtValue[0][23:16] = 8'hff;
        end
        else begin
            RtValue[0][23:16] = 8'h00;
        end

        if( valueIn[0][31:24] > immediateIn[0][7:0] )begin
            RtValue[0][31:24] = 8'hff;
        end
        else begin
            RtValue[0][31:24] = 8'h00;
        end

        if( valueIn[0][39:32] > immediateIn[0][7:0] )begin
            RtValue[0][39:32] = 8'hff;
        end
        else begin
            RtValue[0][39:32] = 8'h00;
        end

        if( valueIn[0][47:40] > immediateIn[0][7:0] )begin
            RtValue[0][47:40] = 8'hff;
        end
        else begin
            RtValue[0][47:40] = 8'h00;
        end

        if( valueIn[0][55:48] > immediateIn[0][7:0] )begin
            RtValue[0][55:48] = 8'hff;
        end
        else begin
            RtValue[0][55:48] = 8'h00;
        end

        if( valueIn[0][63:56] > immediateIn[0][7:0] )begin
            RtValue[0][63:56] = 8'hff;
        end
        else begin
            RtValue[0][63:56] = 8'h00;
        end

        if( valueIn[0][71:64] > immediateIn[0][7:0] )begin
            RtValue[0][71:64] = 8'hff;
        end
        else begin
            RtValue[0][71:64] = 8'h00;
        end

        if( valueIn[0][79:72] > immediateIn[0][7:0] )begin
            RtValue[0][79:72] = 8'hff;
        end
        else begin
            RtValue[0][79:72] = 8'h00;
        end

        if( valueIn[0][87:80] > immediateIn[0][7:0])begin
            RtValue[0][87:80] = 8'hff;
        end
        else begin
            RtValue[0][87:80] = 8'h00;
        end

        if( valueIn[0][95:88] > immediateIn[0][7:0] )begin
            RtValue[0][95:88] = 8'hff;
        end
        else begin
            RtValue[0][95:88] = 8'h00;
        end

        if( valueIn[0][103:96] > immediateIn[0][7:0] )begin
            RtValue[0][103:96] = 8'hff;
        end
        else begin
            RtValue[0][103:96] = 8'h00;
        end

        if( valueIn[0][111:104] > immediateIn[0][7:0] )begin
            RtValue[0][111:104] = 8'hff;
        end
        else begin
            RtValue[0][111:104] = 8'h00;
        end

        if( valueIn[0][119:112] > immediateIn[0][7:0] )begin
            RtValue[0][119:112] = 8'hff;
        end
        else begin
            RtValue[0][119:112] = 8'h00;
        end

        if( valueIn[0][127:120] > immediateIn[0][7:0])begin
            RtValue[0][127:120] = 8'hff;
        end
        else begin
            RtValue[0][127:120] = 8'h00;
        end

end


/* 63 compare > halfword   opcode == 77 */

else if(evenOpcode == 77)begin
            if( (valueIn[0][15:0]) > (valueIn[1][15:0]) ) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (valueIn[0][31:16]) > (valueIn[1][31:16]) ) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (valueIn[0][47:32])  > (valueIn[1][47:32]) ) begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (valueIn[0][63:48])  > (valueIn[1][63:48]) ) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (valueIn[0][79:64])  > (valueIn[1][79:64]) ) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (valueIn[0][95:80])  > (valueIn[1][95:80]) ) begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (valueIn[0][111:96])  > (valueIn[1][111:96]) ) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (valueIn[0][127:112])  > (valueIn[1][127:112]) ) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end

end



/* 64 compare > halfword immediate  opcode == 78 */

else if(evenOpcode == 78)begin
        if(immediateIn[0][9] == 1)begin 
        immediate16[15:9] = 7'b1111111;
        immediate16[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate16[15:9] = 7'b0000000;
        immediate16[8:0] = immediateIn[0][8:0];
    end
            if ((valueIn[0][15:0]) > immediate16 ) begin
                RtValue[0][15:0] = 16'hffff;
            end
            else begin
                 RtValue[0][15:0] = 16'h0000;
            end

            if( (valueIn[0][31:16])  > immediate16) begin
                RtValue[0][31:16] = 16'hffff;
            end
            else begin
                 RtValue[0][31:16] = 16'h0000;
            end

            if( (valueIn[0][47:32])  > immediate16)begin
                RtValue[0][47:32] = 16'hffff;
            end
            else begin
                 RtValue[0][47:32] = 16'h0000;
            end

            if( (valueIn[0][63:48])  > immediate16) begin
                RtValue[0][63:48] = 16'hffff;
            end
            else begin
                 RtValue[0][63:48] = 16'h0000;
            end

            if( (valueIn[0][79:64])  == immediate16) begin
                RtValue[0][79:64] = 16'hffff;
            end
            else begin
                 RtValue[0][79:64] = 16'h0000;
            end

            if( (valueIn[0][95:80])  > immediate16)begin
                RtValue[0][95:80] = 16'hffff;
            end
            else begin
                 RtValue[0][95:80] = 16'h0000;
            end

            if( (valueIn[0][111:96])  > immediate16) begin
                RtValue[0][111:96] = 16'hffff;
            end
            else begin
                 RtValue[0][111:96] = 16'h0000;
            end

            if( (valueIn[0][127:112])  > immediate16) begin
                RtValue[0][127:112] = 16'hffff;
            end
            else begin
                 RtValue[0][127:112] = 16'h0000;
            end
end
/* 65 compare > word   opcode == 79 */

else if(evenOpcode == 79)begin
            if( (valueIn[0][31:0]) > (valueIn[1][31:0]) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (valueIn[0][63:32])  > (valueIn[1][63:32]) ) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (valueIn[0][95:64])  > (valueIn[1][95:64]) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (valueIn[0][127:96])  > (valueIn[1][127:96]) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end

end

/* 66 compare > word immediate  opcode == 80 */

else if(evenOpcode == 80)begin
     if(immediateIn[0][9] == 1)begin 
        immediate32[31:9] = 23'b11111111111111111111111;
        immediate32[8:0] = immediateIn[0][8:0];
    end
    else begin
        immediate32[31:9] = 23'b00000000000000000000000;
        immediate32[8:0] = immediateIn[0][8:0];
    end
            if( (valueIn[0][31:0])  > (immediate32) ) begin
                RtValue[0][31:0] = 32'hffffffff;
            end
            else begin
                RtValue[0][31:0] = 32'h00000000;
            end

            if( (valueIn[0][63:32])  > (immediate32) ) begin
                RtValue[0][63:32] = 32'hffffffff;
            end
            else begin
                RtValue[0][63:32] = 32'h00000000;
            end

            if( (valueIn[0][95:64])  > (immediate32) ) begin
                RtValue[0][95:64] = 32'hffffffff;
            end
            else begin
                RtValue[0][95:64] = 32'h00000000;
            end

            if( (valueIn[0][127:96])  > (immediate32) ) begin
                RtValue[0][127:96] = 32'hffffffff;
            end
            else begin
                RtValue[0][127:96] = 32'h00000000;
            end
end


/* 67 floating add  opcode ==85 */
 else if(evenOpcode == 85) begin
          floatingResult = valueIn[0][31:0] + valueIn[1][31:0];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][31:0] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][31:0] = 32'h00000000;
          end
          else begin
          RtValue[0][31:0] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][63:32] + valueIn[1][63:32];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][63:32] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][63:32] = 32'h00000000;
          end
          else begin
          RtValue[0][63:32] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][95:64] + valueIn[1][95:64];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][95:64] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][95:64] = 32'h00000000;
          end
          else begin
          RtValue[0][95:64] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][127:96] + valueIn[1][127:96];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][127:96] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][127:96] = 32'h00000000;
          end
          else begin
          RtValue[0][127:96] = floatingResult[31:0];
          end


 end


/* 68 floating subtract   opcode == 86*/

else if(evenOpcode == 86) begin
          floatingResult = valueIn[0][31:0] - valueIn[1][31:0];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][31:0] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][31:0] = 32'h00000000;
          end
          else begin
          RtValue[0][31:0] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][63:32] - valueIn[1][63:32];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][63:32] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][63:32] = 32'h00000000;
          end
          else begin
          RtValue[0][63:32] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][95:64] - valueIn[1][95:64];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][95:64] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][95:64] = 32'h00000000;
          end
          else begin
          RtValue[0][95:64] = floatingResult[31:0];
          end

          floatingResult = valueIn[0][127:96] - valueIn[1][127:96];
          if(floatingResult > 32'h7fffffff)begin
            RtValue[0][127:96] = 32'h7fffffff;
          end
          else if(floatingResult < 32'h00800000)begin
            RtValue[0][127:96] = 32'h00000000;
          end
          else begin
          RtValue[0][127:96] = floatingResult[31:0];
          end


 end

/* 69 floating multiply   opcode ==87 */

else if(evenOpcode == 87) begin
          floatingResult64bit  = valueIn[0][31:0] * valueIn[1][31:0];
          if(floatingResult64bit  > 32'h7fffffff)begin
            RtValue[0][31:0] = 32'h7fffffff;
          end
          else if(floatingResult64bit  < 32'h00800000)begin
            RtValue[0][31:0] = 32'h00000000;
          end
          else begin
          RtValue[0][31:0] = floatingResult64bit [31:0];
          end

          floatingResult64bit  = valueIn[0][63:32] * valueIn[1][63:32];
          if(floatingResult64bit  > 32'h7fffffff)begin
            RtValue[0][63:32] = 32'h7fffffff;
          end
          else if(floatingResult64bit  < 32'h00800000)begin
            RtValue[0][63:32] = 32'h00000000;
          end
          else begin
          RtValue[0][63:32] = floatingResult64bit [31:0];
          end

          floatingResult64bit  = valueIn[0][95:64] * valueIn[1][95:64];
          if(floatingResult64bit  > 32'h7fffffff)begin
            RtValue[0][95:64] = 32'h7fffffff;
          end
          else if(floatingResult64bit  < 32'h00800000)begin
            RtValue[0][95:64] = 32'h00000000;
          end
          else begin
          RtValue[0][95:64] = floatingResult64bit [31:0];
          end

          floatingResult64bit  = valueIn[0][127:96] * valueIn[1][127:96];
          if(floatingResult64bit  > 32'h7fffffff)begin
            RtValue[0][127:96] = 32'h7fffffff;
          end
          else if(floatingResult64bit  < 32'h00800000)begin
            RtValue[0][127:96] = 32'h00000000;
          end
          else begin
          RtValue[0][127:96] = floatingResult64bit [31:0];
          end


 end
/* 70 floating multiply and add  opcode ==88 */
/* this operation need to double check with professor about the addition after the multiplication
actually all floating point operation might need to check with professor*/
else if(evenOpcode == 88) begin
          floatingResult64bit = valueIn[0][31:0] * valueIn[1][31:0]+ valueIn[2][31:0];
          if(floatingResult64bit > 32'h7fffffff)begin
            RtValue[0][31:0] = 32'h7fffffff;
          end
          else if(floatingResult64bit < 32'h00800000)begin
            RtValue[0][31:0] = 32'h00000000;
          end
          else begin
          RtValue[0][31:0] = floatingResult64bit[31:0];
          end

          floatingResult64bit = valueIn[0][63:32] * valueIn[1][63:32]+ valueIn[2][63:32];
          if(floatingResult64bit > 32'h7fffffff)begin
            RtValue[0][63:32] = 32'h7fffffff;
          end
          else if(floatingResult64bit < 32'h00800000)begin
            RtValue[0][63:32] = 32'h00000000;
          end
          else begin
          RtValue[0][63:32] = floatingResult64bit[31:0];
          end

          floatingResult64bit = valueIn[0][95:64] * valueIn[1][95:64]+ valueIn[2][95:64];
          if(floatingResult64bit > 32'h7fffffff)begin
            RtValue[0][95:64] = 32'h7fffffff;
          end
          else if(floatingResult64bit < 32'h00800000)begin
            RtValue[0][95:64] = 32'h00000000;
          end
          else begin
          RtValue[0][95:64] = floatingResult64bit[31:0];
          end

          floatingResult64bit = valueIn[0][127:96] * valueIn[1][127:96]+ valueIn[2][127:96];
          if(floatingResult64bit > 32'h7fffffff)begin
            RtValue[0][127:96] = 32'h7fffffff;
          end
          else if(floatingResult64bit < 32'h00800000)begin
            RtValue[0][127:96] = 32'h00000000;
          end
          else begin
          RtValue[0][127:96] = floatingResult64bit[31:0];
          end


 end

/* 71 NOOP EVEN*/
else if(evenOpcode == 90) begin
         RtValue[0] = 0;   /* garbage operation*/
 
end

/* then here will start with odd pipe operation*/

/*  72 load quardword d 1*/
if(oddOpcode == 1 )begin
     if(immediateIn[1][9] == 1)begin 
        immediate32[31:14] = 18'b111111111111111111;
        immediate32[13:4] = immediateIn[1][9:0];
        immediate32[3:0] = 4'b0000;
    end
    else begin
        immediate32[31:14] = 18'b000000000000000000;
        immediate32[13:4] = immediateIn[1][9:0];
        immediate32[3:0] = 4'b0000;
    end
        tempValue = immediate32 + valueIn[3][127:96];
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin                           /* only take 14:7 bc each of them is 128 so ignore 6:0 above 14 exceed the local storage memory 32kb*/
            RtValue[1] = dataMemory1[tempValue[14:7]];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
            RtValue[1] = dataMemory2[tempValue[14:7]-32];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
            RtValue[1] = dataMemory3[tempValue[14:7]-64];
        end
        else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
            RtValue[1] = dataMemory4[tempValue[14:7]-96];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
            RtValue[1] = dataMemory5[tempValue[14:7]-128];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
            RtValue[1] = dataMemory6[tempValue[14:7]-160];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
            RtValue[1] = dataMemory7[tempValue[14:7]-192];
        end   
        else begin
            RtValue[1] = dataMemory8[tempValue[14:7]-224];
        end   
end

/*  73 load quardword x 2*/
else if(oddOpcode == 2) begin
    tempValue = valueIn[4][127:96]+ valueIn[3][127:96];
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin
            RtValue[1] = dataMemory1[tempValue[14:7]];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
            RtValue[1] = dataMemory2[tempValue[14:7]-32];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
            RtValue[1] = dataMemory3[tempValue[14:7]-64];
        end
        else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
            RtValue[1] = dataMemory4[tempValue[14:7]-96];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
            RtValue[1] = dataMemory5[tempValue[14:7]-128];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
            RtValue[1] = dataMemory6[tempValue[14:7]-160];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
            RtValue[1] = dataMemory7[tempValue[14:7]-192];
        end   
        else begin
            RtValue[1] = dataMemory8[tempValue[14:7]-224];
        end   
end

/*  74 load quardword a 3*/
else if(oddOpcode == 3 )begin
     if(immediateIn[1][15] == 1)begin 
        immediate32[31:18] = 14'b11111111111111;
        immediate32[17:2] = immediateIn[1][15:0];
        immediate32[1:0] = 2'b00;
    end
    else begin
        immediate32[31:18] = 14'b00000000000000;
        immediate32[17:2] = immediateIn[1][15:0];
        immediate32[1:0] = 2'b00;
    end
        tempValue = immediate32;
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin
            RtValue[1] = dataMemory1[tempValue[14:7]];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
            RtValue[1] = dataMemory2[tempValue[14:7]-32];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
            RtValue[1] = dataMemory3[tempValue[14:7]-64];
        end
        else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
            RtValue[1] = dataMemory4[tempValue[14:7]-96];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
            RtValue[1] = dataMemory5[tempValue[14:7]-128];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
            RtValue[1] = dataMemory6[tempValue[14:7]-160];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
            RtValue[1] = dataMemory7[tempValue[14:7]-192];
        end   
        else begin
            RtValue[1] = dataMemory8[tempValue[14:7]-224];
        end       
end

/*  75 store quardword d 4 will treat value in [4] to be rt value*/ 
else if(oddOpcode == 4) begin 
     if(immediateIn[1][9] == 1)begin 
        immediate32[31:14] = 18'b111111111111111111;
        immediate32[13:4] = immediateIn[1][9:0];
        immediate32[3:0] = 4'b0000;
    end
    else begin
        immediate32[31:14] = 18'b000000000000000000;
        immediate32[13:4] = immediateIn[1][9:0];
        immediate32[3:0] = 4'b0000;
    end
        tempValue = immediate32 + valueIn[3][127:96];
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin
            dataMemory1[tempValue[14:7]] = valueIn[4];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
            dataMemory2[tempValue[14:7]-32] = valueIn[4];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
            dataMemory3[tempValue[14:7]-64] = valueIn[4];
        end
        else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
             dataMemory4[tempValue[14:7]-96] = valueIn[4];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
             dataMemory5[tempValue[14:7]-128] = valueIn[4];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
             dataMemory6[tempValue[14:7]-160] = valueIn[4];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
             dataMemory7[tempValue[14:7]-192] = valueIn[4];
        end   
        else begin
             dataMemory8[tempValue[14:7]-224] = valueIn[4];
        end       
end
/*  76 store quardword x 5*/
else if(oddOpcode == 5) begin
    tempValue = valueIn[4][127:96]+ valueIn[3][127:96];
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin
        dataMemory1[tempValue[14:7]]=valueIn[4];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
         dataMemory2[tempValue[14:7]-32]=valueIn[4];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
        dataMemory3[tempValue[14:7]-64]=valueIn[4];
        end
         else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
             dataMemory4[tempValue[14:7]-96] = valueIn[4];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
             dataMemory5[tempValue[14:7]-128] = valueIn[4];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
             dataMemory6[tempValue[14:7]-160] = valueIn[4];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
             dataMemory7[tempValue[14:7]-192] = valueIn[4];
        end   
        else begin
             dataMemory8[tempValue[14:7]-224] = valueIn[4];
        end         
end

/*  77 store quardword a 6*/
else if(oddOpcode == 6 )begin
     if(immediateIn[1][15] == 1)begin 
        immediate32[31:18] = 14'b11111111111111;
        immediate32[17:2] = immediateIn[1][15:0];
        immediate32[1:0] = 2'b00;
    end
    else begin
        immediate32[31:18] = 14'b00000000000000;
        immediate32[17:2] = immediateIn[1][15:0];
        immediate32[1:0] = 2'b00;
    end
        tempValue = immediate32;
        tempValue[3:0] = 4'b0000;
        if(tempValue[14:7] <=31)begin
            dataMemory1[tempValue[14:7]]=valueIn[4];
        end
        else if (tempValue[14:7] > 31 && tempValue[14:7] <= 63)begin
            dataMemory2[tempValue[14:7]-32]=valueIn[4];
        end
        else if (tempValue[14:7] > 63 && tempValue[14:7] <= 95)begin
            dataMemory3[tempValue[14:7]-64]=valueIn[4];
        end
        else if (tempValue[14:7] > 95 && tempValue[14:7] <= 127)begin
             dataMemory4[tempValue[14:7]-96] = valueIn[4];
        end     
        else if (tempValue[14:7] > 127 && tempValue[14:7] <= 159)begin
             dataMemory5[tempValue[14:7]-128] = valueIn[4];
        end   
        else if (tempValue[14:7] > 159 && tempValue[14:7] <= 191)begin
             dataMemory6[tempValue[14:7]-160] = valueIn[4];
        end   
        else if (tempValue[14:7] > 191 && tempValue[14:7] <= 223)begin
             dataMemory7[tempValue[14:7]-192] = valueIn[4];
        end   
        else begin
             dataMemory8[tempValue[14:7]-224] = valueIn[4];
        end         
end

/* 78 shift left quadword by bits 57*/
else if(oddOpcode == 57) begin
    shiftAmount = 0;
    shiftAmount[2:0] = valueIn[4][98:96];

    for(int i=127; i>=0; i--)begin
        if( (i  >= shiftAmount))begin
            RtValue[1][i] = valueIn[3][i-shiftAmount];
        end
        else begin
            RtValue[1][i] = 0;
        end
    end
end

/* 79 shift left quadword by bits immediate 58 */
else if(oddOpcode == 58) begin
    shiftAmount = 0;
    shiftAmount[2:0] = immediateIn[1][2:0];

    for(int i=127; i>=0; i--)begin
        if( (i  >= shiftAmount))begin
            RtValue[1][i] = valueIn[3][i-shiftAmount];
        end
        else begin
            RtValue[1][i] = 0;
        end
    end
end

/* 80 shift left quadword by bytes 59*/

else if(oddOpcode == 59) begin
    shiftAmount = 0;
    shiftAmount[4:0] = valueIn[4][100:96];
	if (shiftAmount <= 15) begin
		if (shiftAmount == 1) begin
		RtValue[1][127:8] = valueIn[3][119:0];
		RtValue[1][7:0]   = 8'b00000000;				
		end
	
		else if (shiftAmount == 2) begin
		RtValue[1][127:16] = valueIn[3][111:0];
		RtValue[1][15:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 3) begin
		RtValue[1][127:24] = valueIn[3][103:0];
		RtValue[1][23:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 4) begin
		RtValue[1][127:32] = valueIn[3][95:0];
		RtValue[1][31:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 5) begin
		RtValue[1][127:40] = valueIn[3][87:0];
		RtValue[1][39:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 6) begin
		RtValue[1][127:48] = valueIn[3][79:0];
		RtValue[1][47:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 7) begin
		RtValue[1][127:56] = valueIn[3][71:0];
		RtValue[1][55:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 8) begin
		RtValue[1][127:64] = valueIn[3][63:0];
		RtValue[1][63:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 9) begin
		RtValue[1][127:72] = valueIn[3][55:0];
		RtValue[1][71:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 10) begin
		RtValue[1][127:80] = valueIn[3][47:0];
		RtValue[1][79:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 11) begin
		RtValue[1][127:88] = valueIn[3][39:0];
		RtValue[1][87:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 12) begin
		RtValue[1][127:96] = valueIn[3][31:0];
		RtValue[1][95:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 13) begin
		RtValue[1][127:104] = valueIn[3][23:0];
		RtValue[1][103:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 14) begin
		RtValue[1][127:112] = valueIn[3][15:0];
		RtValue[1][111:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 15) begin
		RtValue[1][127:120] = valueIn[3][7:0];
		RtValue[1][119:0]   = 8'b00000000;				
		end

	end
	else begin
            RtValue[1] = 0;
	end
end
/* 81 shift left quadword by bytes immediate 60*/

else if(oddOpcode == 60) begin
    shiftAmount = 0;
    shiftAmount[4:0] = immediateIn[1][4:0];
	if (shiftAmount <= 15) begin
		if (shiftAmount == 1) begin
		RtValue[1][127:8] = valueIn[3][119:0];
		RtValue[1][7:0]   = 8'b00000000;				
		end
	
		else if (shiftAmount == 2) begin
		RtValue[1][127:16] = valueIn[3][111:0];
		RtValue[1][15:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 3) begin
		RtValue[1][127:24] = valueIn[3][103:0];
		RtValue[1][23:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 4) begin
		RtValue[1][127:32] = valueIn[3][95:0];
		RtValue[1][31:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 5) begin
		RtValue[1][127:40] = valueIn[3][87:0];
		RtValue[1][39:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 6) begin
		RtValue[1][127:48] = valueIn[3][79:0];
		RtValue[1][47:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 7) begin
		RtValue[1][127:56] = valueIn[3][71:0];
		RtValue[1][55:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 8) begin
		RtValue[1][127:64] = valueIn[3][63:0];
		RtValue[1][63:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 9) begin
		RtValue[1][127:72] = valueIn[3][55:0];
		RtValue[1][71:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 10) begin
		RtValue[1][127:80] = valueIn[3][47:0];
		RtValue[1][79:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 11) begin
		RtValue[1][127:88] = valueIn[3][39:0];
		RtValue[1][87:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 12) begin
		RtValue[1][127:96] = valueIn[3][31:0];
		RtValue[1][95:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 13) begin
		RtValue[1][127:104] = valueIn[3][23:0];
		RtValue[1][103:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 14) begin
		RtValue[1][127:112] = valueIn[3][15:0];
		RtValue[1][111:0]   = 8'b00000000;				
		end

		else if (shiftAmount == 15) begin
		RtValue[1][127:120] = valueIn[3][7:0];
		RtValue[1][119:0]   = 8'b00000000;				
		end

	end
	else if (shiftAmount > 15) begin
            RtValue[1] = 0;
	end
end
/* 82 rotate quadword by bits 61 */
else if(oddOpcode == 61) begin
    shiftAmount = 0;
    shiftAmount[2:0] = valueIn[4][98:96];

    for(int i=127; i>=0; i--)begin
        if( (i  >= shiftAmount))begin
            RtValue[1][i] = valueIn[3][i-shiftAmount];
        end
        else begin
            RtValue[1][i] = valueIn[3][i-shiftAmount+128];
        end
    end
end

/* 83 rotate quadword by bits immediate 62*/
else if(oddOpcode == 62) begin
    shiftAmount = 0;
    shiftAmount[2:0] = immediateIn[1][2:0];

    for(int i=127; i>=0; i--)begin
        if( (i  >= shiftAmount))begin
            RtValue[1][i] = valueIn[3][i-shiftAmount];
        end
        else begin
            RtValue[1][i] = valueIn[3][i-shiftAmount+128];
        end
    end
end

/* 84 rotate quadword by bytes 63*/
else if(oddOpcode == 63) begin
    shiftAmount = 0;
    shiftAmount[3:0] = valueIn[4][99:96];
	if (shiftAmount <= 15) begin
		if (shiftAmount == 1) begin
		RtValue[1][127:8] = valueIn[3][119:0];
		RtValue[1][7:0]   = valueIn[3][127:120];				
		end
	
		else if (shiftAmount == 2) begin
		RtValue[1][127:16] = valueIn[3][111:0];
		RtValue[1][15:0]   = valueIn[3][127:112];				
		end

		else if (shiftAmount == 3) begin
		RtValue[1][127:24] = valueIn[3][103:0];
		RtValue[1][23:0]   = valueIn[3][127:104];				
		end

		else if (shiftAmount == 4) begin
		RtValue[1][127:32] = valueIn[3][95:0];
		RtValue[1][31:0]   = valueIn[3][127:96];				
		end

		else if (shiftAmount == 5) begin
		RtValue[1][127:40] = valueIn[3][87:0];
		RtValue[1][39:0]   = valueIn[3][127:88];				
		end

		else if (shiftAmount == 6) begin
		RtValue[1][127:48] = valueIn[3][79:0];
		RtValue[1][47:0]   = valueIn[3][127:80];				
		end

		else if (shiftAmount == 7) begin
		RtValue[1][127:56] = valueIn[3][71:0];
		RtValue[1][55:0]   = valueIn[3][127:72];				
		end

		else if (shiftAmount == 8) begin
		RtValue[1][127:64] = valueIn[3][63:0];
		RtValue[1][63:0]   = valueIn[3][127:64];				
		end

		else if (shiftAmount == 9) begin
		RtValue[1][127:72] = valueIn[3][55:0];
		RtValue[1][71:0]   = valueIn[3][127:56];				
		end

		else if (shiftAmount == 10) begin
		RtValue[1][127:80] = valueIn[3][47:0];
		RtValue[1][79:0]   = valueIn[3][127:48];				
		end

		else if (shiftAmount == 11) begin
		RtValue[1][127:88] = valueIn[3][39:0];
		RtValue[1][87:0]   = valueIn[3][127:40];				
		end

		else if (shiftAmount == 12) begin
		RtValue[1][127:96] = valueIn[3][31:0];
		RtValue[1][95:0]   = valueIn[3][127:32];				
		end

		else if (shiftAmount == 13) begin
		RtValue[1][127:104] = valueIn[3][23:0];
		RtValue[1][103:0]   = valueIn[3][127:24];				
		end

		else if (shiftAmount == 14) begin
		RtValue[1][127:112] = valueIn[3][15:0];
		RtValue[1][111:0]   = valueIn[3][127:16];				
		end

		else if (shiftAmount == 15) begin
		RtValue[1][127:120] = valueIn[3][7:0];
		RtValue[1][119:0]   = valueIn[3][127:18];				
		end

	end
end

/* 85 rotate quadword by bytes immediate 64 */
else if(oddOpcode == 64) begin
    shiftAmount = 0;
    shiftAmount[3:0] = immediateIn[1][3:0];
	if (shiftAmount <= 15) begin
		if (shiftAmount == 1) begin
		RtValue[1][127:8] = valueIn[3][119:0];
		RtValue[1][7:0]   = valueIn[3][127:120];				
		end
	
		else if (shiftAmount == 2) begin
		RtValue[1][127:16] = valueIn[3][111:0];
		RtValue[1][15:0]   = valueIn[3][127:112];				
		end

		else if (shiftAmount == 3) begin
		RtValue[1][127:24] = valueIn[3][103:0];
		RtValue[1][23:0]   = valueIn[3][127:104];				
		end

		else if (shiftAmount == 4) begin
		RtValue[1][127:32] = valueIn[3][95:0];
		RtValue[1][31:0]   = valueIn[3][127:96];				
		end

		else if (shiftAmount == 5) begin
		RtValue[1][127:40] = valueIn[3][87:0];
		RtValue[1][39:0]   = valueIn[3][127:88];				
		end

		else if (shiftAmount == 6) begin
		RtValue[1][127:48] = valueIn[3][79:0];
		RtValue[1][47:0]   = valueIn[3][127:80];				
		end

		else if (shiftAmount == 7) begin
		RtValue[1][127:56] = valueIn[3][71:0];
		RtValue[1][55:0]   = valueIn[3][127:72];				
		end

		else if (shiftAmount == 8) begin
		RtValue[1][127:64] = valueIn[3][63:0];
		RtValue[1][63:0]   = valueIn[3][127:64];				
		end

		else if (shiftAmount == 9) begin
		RtValue[1][127:72] = valueIn[3][55:0];
		RtValue[1][71:0]   = valueIn[3][127:56];				
		end

		else if (shiftAmount == 10) begin
		RtValue[1][127:80] = valueIn[3][47:0];
		RtValue[1][79:0]   = valueIn[3][127:48];				
		end

		else if (shiftAmount == 11) begin
		RtValue[1][127:88] = valueIn[3][39:0];
		RtValue[1][87:0]   = valueIn[3][127:40];				
		end

		else if (shiftAmount == 12) begin
		RtValue[1][127:96] = valueIn[3][31:0];
		RtValue[1][95:0]   = valueIn[3][127:32];				
		end

		else if (shiftAmount == 13) begin
		RtValue[1][127:104] = valueIn[3][23:0];
		RtValue[1][103:0]   = valueIn[3][127:24];				
		end

		else if (shiftAmount == 14) begin
		RtValue[1][127:112] = valueIn[3][15:0];
		RtValue[1][111:0]   = valueIn[3][127:16];				
		end

		else if (shiftAmount == 15) begin
		RtValue[1][127:120] = valueIn[3][7:0];
		RtValue[1][119:0]   = valueIn[3][127:18];				
		end

	end
end

/* 86 BRANCH IF NOT ZERO WORD 81*/
else if(oddOpcode == 81)begin
    if(valueIn[4][127:96] != 0)begin
        branchAddress = PCounter + immediateIn[1][5:0];
        branchOrNot = 1;
    end
    else begin
        branchAddress = branchAddress+1;
        branchOrNot = 0;
    end

end


/* 87 BRANCH If zero word 82*/
else if(oddOpcode == 82)begin
    if(valueIn[4][127:96] == 0)begin
        branchAddress = PCounter + immediateIn[1][5:0];
        branchOrNot = 1;
    end
    else begin
        branchAddress = branchAddress+1;
        branchOrNot = 0;
    end

end

/* 88 BRANCH IF NOT ZERO halfWORD 83*/
else if(oddOpcode == 83)begin
    if(valueIn[4][111:96] != 0)begin
        branchAddress = PCounter + immediateIn[1][5:0];
        branchOrNot = 1;
    end
    else begin
        branchAddress = branchAddress+1;
        branchOrNot = 0;
    end

end


/* 89 BRANCH If zero halfword 84 */
else if(oddOpcode == 84)begin
    if(valueIn[4][111:96] == 0)begin
        branchAddress = PCounter + immediateIn[1][5:0];
        branchOrNot = 1;
    end
    else begin
        branchAddress = branchAddress+1;
        branchOrNot = 0;
    end

end



/* 90 no op odd 91*/
else if(evenOpcode == 91) begin
         RtValue[1] = 0;   /* garbage operation*/
 
end
end

always_ff @(posedge clock)begin

    RtValue_ff <= RtValue;
    RtAddress_out <= RtAddress_in;
    wr_en_out <= wr_en_in;
    ready_stage_out <= ready_stage_in;
    stop_ff <= stop;
    branchOrNot_ff <= branchOrNot;
    branchAddress_ff <= branchAddress;

end



endmodule

/*
module test();
logic [5:0] PCounter;
logic clock;
logic [1:0][6:0] opcode;    
logic signed [5:0][127:0] valueIn;       // 0-2 even a,b,c 3-5 odd a,b,c   rt register value will be in 4 when it's used  some cares need to be taken when connect port
logic signed [1:0][17:0] immediateIn;    // assume uniform length we don't need to know its length operation will just take bits based on 6,7,10,16 or 18
logic [1:0] wr_en_in;
logic [1:0][6:0] RtAddress_in;
logic [1:0][3:0] ready_stage_in;          //these three are just bypassing to output
logic signed [1:0][127:0] RtValue_ff;     //      0 for even 1 for odd
logic [1:0][6:0] RtAddress_out;
logic [1:0] wr_en_out;
logic [1:0][3:0] ready_stage_out;
logic [5:0] branchAddress_ff;      //  new pc address 
logic branchOrNot_ff;
logic stop_ff;

PipeStage dut (PCounter, clock, opcode, valueIn, immediateIn, wr_en_in, RtAddress_in, ready_stage_in,
RtValue_ff, RtAddress_out, wr_en_out, ready_stage_out, branchAddress_ff, branchOrNot_ff, stop_ff);

// pay attention each clock 2 instructions, 1 for odd, 1 for even
//register is better to be re-used after 20 clock cycle to prevent data harzard

initial begin



    clock = 0;
    PCounter = 0;
    opcode[0] = 12;
    opcode[1] = 64;
    valueIn[0] = 41;
    valueIn[1] = 42;
    valueIn[2] = 43;
    valueIn[3] = 15;
    valueIn[4] = 0;
    valueIn[5] = 17;
    immediateIn[0] = 9;
    immediateIn[1] = 12;
    wr_en_in[0] = 1;
    wr_en_in[1] = 0;
    RtAddress_in[0] = 43;
    RtAddress_in[1] = 52;
    ready_stage_in[0] = 4;
    ready_stage_in[1] = 2;    	
    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 65;
    opcode[1] = 81;

    $finish;
    end
endmodule 
/*    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 66;
    opcode[1] = 82;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 67;
    opcode[1] = 83;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 68;
    opcode[1] = 84;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 69;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 70;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 71;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 72;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 73;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 74;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 75;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 76;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 77;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 78;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 79;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 80;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 85;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 86;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 87;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 88;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 89;

    #5 
    clock = 1;
    #5
    clock = 0; 
    opcode[0] = 90;

    #5 
    clock = 1;
    #5
    clock = 0; 



    $finish;
    end
endmodule */
    // ex. for multiply unsigned immediate   and  store quadword
    
    /* store quadword */
    /*input: 
    pc = 1 // this is not so sure
    opcode = 0000100
    immediateIn1 = 5;
    ra = 3;
    rb(this case is rt value instead of rb value) = 4;
    rc = 7//not going to use but still send, this was sent and used by last time 
    rt address = 30;
    wr_en = 0;
    stage = 7;

    / multiply unsigned immediate
    pc = 1
    opcode = 0011101
    immediatein2 = 10;
    ra = 10
    rb(rt) = 10
    rc = 10 
    rt_address = 50;
    wr_en = 1
    stage = 3
    */


