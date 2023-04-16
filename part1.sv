`include "opdecoder.sv"
`include "pipelineReg.sv"
`include "rf_fw.sv"
`include "PipeStage.sv"


module part1(input clock, input unsigned [5:0]program_counter, input unsigned [1:0][10:0]opcode, input unsigned [1:0] write_back, input unsigned [1:0][3:0]forward_stage 
,input unsigned [1:0][6:0] ra, input unsigned [1:0][6:0] rb, input unsigned [1:0][6:0] rc, input unsigned [1:0][6:0] rt, input signed [1:0][17:0] immediate,
output logic branch_taken, output logic signed[5:0] branch_value ,output logic stop);

logic unsigned [1:0][6:0] opcode_dec_out;

logic unsigned [1:0][6:0] opcode_rf_out;
logic signed [1:0][17:0] immediate_rf_out;
logic unsigned [1:0][6:0] rt_out_rf;
logic unsigned [1:0][3:0] fw_out_rf;
logic [1:0] wb_out_rf;

logic signed [1:0][127:0] Rt_value_pipe;
logic signed [1:0][6:0] Rt_add_pipe;
logic [1:0] wr_en_out_pipe;
logic [1:0][3:0] ready_stage_out_pipe; 

logic [1:0] wr_en_wb;
logic signed[1:0][127:0] data_in_wb;
logic unsigned [1:0][6:0] rt_wb; 


logic [6:0] RegWrOutOdd;
logic unsigned [6:0][6:0] RegTargetOutOdd;
logic signed [6:0][127:0]RegValueOutOdd;
logic unsigned [6:0][3:0]FWstageOutOdd;

logic [6:0] RegWrOutEven;
logic unsigned [6:0][6:0] RegTargetOutEven;
logic signed [6:0][127:0]RegValueOutEven;
logic unsigned [6:0][3:0]FWstageOutEven;

logic signed[2:0][127:0] regOdd;     /*  a, b, c*/
logic signed[2:0][127:0] regEven;    /* a,b,c */
logic signed[5:0][127:0] valueIn_pipe;    /*  0-2 even 3-5 odd*/



always_comb begin

wr_en_wb[0] = RegWrOutOdd[6];
wr_en_wb[1] = RegWrOutEven[6];
data_in_wb[0] = RegValueOutOdd[6];
data_in_wb[1] = RegValueOutEven[6];
rt_wb[0] = RegTargetOutOdd[6];
rt_wb[1] = RegTargetOutEven[6];
valueIn_pipe[0] = regEven[0];
valueIn_pipe[1] = regEven[1];
valueIn_pipe[2] = regEven[2];
valueIn_pipe[3] = regOdd[0];
valueIn_pipe[4] = regOdd[1];
valueIn_pipe[5] = regOdd[2];

end

opdecode opdecode_inst1(.opcode_in(opcode[0]), .opcode_out(opcode_dec_out[0]));
opdecode opdecode_inst2(.opcode_in(opcode[1]), .opcode_out(opcode_dec_out[1]));
regFileForward  regFileForward_inst (.clock(clock), .wr_en(wr_en_wb), .wr_back_in(write_back), .opcode_in(opcode_dec_out), .immediateIn(immediate),.data_in(data_in_wb), .rt(rt), 
.rt_wb(rt_wb), .ra(ra), .rb(rb), .rc(rc),.forwardStage_in(forward_stage), .OddregisterValue(RegValueOutOdd[5:0]), .OddregisterAddress(RegTargetOutOdd[5:0]), .OddforwardStage(FWstageOutOdd[5:0]), 
.OddwriteBack(RegWrOutOdd[5:0]),  .EvenregisterValue(RegValueOutEven[5:0]), .EvenregisterAddress(RegTargetOutEven[5:0]), .EvenforwardStage(FWstageOutEven[5:0]), .EvenwriteBack(RegWrOutEven[5:0]), 
.regOdd(regOdd), .regEven(regEven),.wr_back_out(wb_out_rf),  .rt_out(rt_out_rf), .forwardStage_out(fw_out_rf), .opcode_out(opcode_rf_out), .immediateOut(immediate_rf_out));

PipeStage pipeStage_inst( .PCounter(program_counter), .clock(clock), .opcode(opcode_rf_out),  .valueIn(valueIn_pipe), .wr_en_in(wb_out_rf), .immediateIn(immediate_rf_out), .RtAddress_in(rt_out_rf),
.ready_stage_in(fw_out_rf), .RtValue_ff(Rt_value_pipe), .RtAddress_out(Rt_add_pipe),.wr_en_out(wr_en_out_pipe),.ready_stage_out(ready_stage_out_pipe),.branchAddress_ff(branch_value),       
.branchOrNot_ff(branch_taken),.stop_ff(stop));


pipelineReg pipelineReg_instOdd1(.clock(clock), .RegWrIn(wr_en_out_pipe[1]), .RegTargetIn(Rt_add_pipe[1]), .RegValueIn(Rt_value_pipe[1]), .FWstageIn(ready_stage_out_pipe[1]), 
.RegWrOut(RegWrOutOdd[0]), .RegTargetOut(RegTargetOutOdd[0]), .RegValueOut(RegValueOutOdd[0]), .FWstageOut(FWstageOutOdd[0]));
pipelineReg pipelineReg_instOdd2(.clock(clock), .RegWrIn(RegWrOutOdd[0]), .RegTargetIn(RegTargetOutOdd[0]), .RegValueIn(RegValueOutOdd[0]), .FWstageIn(FWstageOutOdd[0]), 
.RegWrOut(RegWrOutOdd[1]), .RegTargetOut(RegTargetOutOdd[1]), .RegValueOut(RegValueOutOdd[1]), .FWstageOut(FWstageOutOdd[1]));
pipelineReg pipelineReg_instOdd3(.clock(clock), .RegWrIn(RegWrOutOdd[1]), .RegTargetIn(RegTargetOutOdd[1]), .RegValueIn(RegValueOutOdd[1]), .FWstageIn(FWstageOutOdd[1]), 
.RegWrOut(RegWrOutOdd[2]), .RegTargetOut(RegTargetOutOdd[2]), .RegValueOut(RegValueOutOdd[2]), .FWstageOut(FWstageOutOdd[2]));
pipelineReg pipelineReg_instOdd4(.clock(clock), .RegWrIn(RegWrOutOdd[2]), .RegTargetIn(RegTargetOutOdd[2]), .RegValueIn(RegValueOutOdd[2]), .FWstageIn(FWstageOutOdd[2]), 
.RegWrOut(RegWrOutOdd[3]), .RegTargetOut(RegTargetOutOdd[3]), .RegValueOut(RegValueOutOdd[3]), .FWstageOut(FWstageOutOdd[3]));
pipelineReg pipelineReg_instOdd5(.clock(clock), .RegWrIn(RegWrOutOdd[3]), .RegTargetIn(RegTargetOutOdd[3]), .RegValueIn(RegValueOutOdd[3]), .FWstageIn(FWstageOutOdd[3]), 
.RegWrOut(RegWrOutOdd[4]), .RegTargetOut(RegTargetOutOdd[4]), .RegValueOut(RegValueOutOdd[4]), .FWstageOut(FWstageOutOdd[4]));
pipelineReg pipelineReg_instOdd6(.clock(clock), .RegWrIn(RegWrOutOdd[4]), .RegTargetIn(RegTargetOutOdd[4]), .RegValueIn(RegValueOutOdd[4]), .FWstageIn(FWstageOutOdd[4]), 
.RegWrOut(RegWrOutOdd[5]), .RegTargetOut(RegTargetOutOdd[5]), .RegValueOut(RegValueOutOdd[5]), .FWstageOut(FWstageOutOdd[5]));

pipelineReg pipelineReg_instEven1(.clock(clock), .RegWrIn(wr_en_out_pipe[0]), .RegTargetIn(Rt_add_pipe[0]), .RegValueIn(Rt_value_pipe[0]), .FWstageIn(ready_stage_out_pipe[0]), 
.RegWrOut(RegWrOutEven[0]), .RegTargetOut(RegTargetOutEven[0]), .RegValueOut(RegValueOutEven[0]), .FWstageOut(FWstageOutEven[0]));
pipelineReg pipelineReg_instEven2(.clock(clock), .RegWrIn(RegWrOutEven[0]), .RegTargetIn(RegTargetOutEven[0]), .RegValueIn(RegValueOutEven[0]), .FWstageIn(FWstageOutEven[0]), 
.RegWrOut(RegWrOutEven[1]), .RegTargetOut(RegTargetOutEven[1]), .RegValueOut(RegValueOutEven[1]), .FWstageOut(FWstageOutEven[1]));
pipelineReg pipelineReg_instEven3(.clock(clock), .RegWrIn(RegWrOutEven[1]), .RegTargetIn(RegTargetOutEven[1]), .RegValueIn(RegValueOutEven[1]), .FWstageIn(FWstageOutEven[1]), 
.RegWrOut(RegWrOutEven[2]), .RegTargetOut(RegTargetOutEven[2]), .RegValueOut(RegValueOutEven[2]), .FWstageOut(FWstageOutEven[2]));
pipelineReg pipelineReg_instEven4(.clock(clock), .RegWrIn(RegWrOutEven[2]), .RegTargetIn(RegTargetOutEven[2]), .RegValueIn(RegValueOutEven[2]), .FWstageIn(FWstageOutEven[2]),
.RegWrOut(RegWrOutEven[3]), .RegTargetOut(RegTargetOutEven[3]), .RegValueOut(RegValueOutEven[3]), .FWstageOut(FWstageOutEven[3]));
pipelineReg pipelineReg_instEven5(.clock(clock), .RegWrIn(RegWrOutEven[3]), .RegTargetIn(RegTargetOutEven[3]), .RegValueIn(RegValueOutEven[3]), .FWstageIn(FWstageOutEven[3]), 
.RegWrOut(RegWrOutEven[4]), .RegTargetOut(RegTargetOutEven[4]), .RegValueOut(RegValueOutEven[4]), .FWstageOut(FWstageOutEven[4]));
pipelineReg pipelineReg_instEven6(.clock(clock), .RegWrIn(RegWrOutEven[4]), .RegTargetIn(RegTargetOutEven[4]), .RegValueIn(RegValueOutEven[4]), .FWstageIn(FWstageOutEven[4]), 
.RegWrOut(RegWrOutEven[5]), .RegTargetOut(RegTargetOutEven[5]), .RegValueOut(RegValueOutEven[5]), .FWstageOut(FWstageOutEven[5]));

WBReg WBReg_instOdd(.clock(clock), .RegWrIn(RegWrOutOdd[5]), .RegTargetIn(RegTargetOutOdd[5]),  .RegValueIn(RegValueOutOdd[5]), .FWstageIn(FWstageOutOdd[5]), 
.RegWrOut(RegWrOutOdd[6]), .RegTargetOut(RegTargetOutOdd[6]), .RegValueOut(RegValueOutOdd[6]));

WBReg WBReg_instEven(.clock(clock), .RegWrIn(RegWrOutEven[5]), .RegTargetIn(RegTargetOutEven[5]),  .RegValueIn(RegValueOutEven[5]), .FWstageIn(FWstageOutEven[5]),
 .RegWrOut(RegWrOutEven[6]), .RegTargetOut(RegTargetOutEven[6]), .RegValueOut(RegValueOutEven[6]));


endmodule



module test();
logic clock;
logic unsigned [5:0] program_counter;
logic unsigned [1:0][10:0]opcode;         //order doesn't matter module will figure out and send to correspond pipe but will try 0 even 1 odd first 
logic unsigned [1:0] write_back;
logic unsigned [1:0][3:0]forward_stage;
logic unsigned [1:0][6:0] ra; 
logic unsigned [1:0][6:0] rb;
logic unsigned [1:0][6:0] rc; 
logic unsigned [1:0][6:0] rt; 
logic signed [1:0][17:0] immediateIn;
logic branch_taken;
logic signed[5:0] branch_value;
logic stop;


part1 part1_inst(.clock(clock), .program_counter(program_counter), .opcode(opcode), .write_back(write_back), .forward_stage(forward_stage),
.ra(ra), .rb(rb), .rc(rc), .rt(rt), .immediate(immediateIn), .branch_taken(branch_taken), .branch_value(branch_value) ,.stop(stop));

initial begin
    // 0 no op Even and Odd

    clock = 0;
    program_counter= 0;   

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 7;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

    // 1 add word load quadword d

    clock = 0;
    program_counter= 0;   

    opcode[0] = 11'b00011000000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

    // 2 add word immediate load quardword d
    clock = 0;
    program_counter= 1;        // indeed, pc should just to p = p+2, here just for simplicity

    opcode[0] = 11'b00011100000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 12;
    rt[1] = 16;


    ra[0] = 9;
    rb[0] = 10;
    rc[0] = 11;
    ra[1] = 13;
    rb[1] = 14;
    rc[1] = 15;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

    // 3 subtract from word load quadword d
    clock = 0;
    program_counter= 2;

    opcode[0] = 11'b00001000000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 20;
    rt[1] = 24;


    ra[0] = 17;
    rb[0] = 18;
    rc[0] = 19;
    ra[1] = 21;
    rb[1] = 22;
    rc[1] = 23;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
    // 4 subtract from word immediate  load quadword x
clock = 0;
    program_counter= 3;

    opcode[0] = 11'b00001100000;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 28;
    rt[1] = 32;


    ra[0] = 25;
    rb[0] = 26;
    rc[0] = 27;
    ra[1] = 29;
    rb[1] = 30;
    rc[1] = 31;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


    // 5 multiply load quadword x
clock = 0;
    program_counter= 4;

    opcode[0] = 11'b01111000100;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 8;
    forward_stage[1] = 7;
    rt[0] = 36;
    rt[1] = 40;


    ra[0] = 4;
    rb[0] = 34;
    rc[0] = 35;
    ra[1] = 37;
    rb[1] = 38;
    rc[1] = 39;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5




    // 6 multiply and add word load quadword x
    clock = 0;
    program_counter= 5;

    opcode[0] = 11'b11000000000;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 8;
    forward_stage[1] = 7;
    rt[0] = 44;
    rt[1] = 48;


    ra[0] = 41;
    rb[0] = 42;
    rc[0] = 43;
    ra[1] = 45;
    rb[1] = 46;
    rc[1] = 47;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 7 and  load quadword a
 clock = 0;
    program_counter= 6;

    opcode[0] = 11'b00011000001;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 52;
    rt[1] = 56;


    ra[0] = 49;
    rb[0] = 50;
    rc[0] = 51;
    ra[1] = 53;
    rb[1] = 54;
    rc[1] = 55;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 8 or   load quadword a
clock = 0;
    program_counter= 7;

    opcode[0] = 11'b00001000001;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 60;
    rt[1] = 64;


    ra[0] = 57;
    rb[0] = 58;
    rc[0] = 59;
    ra[1] = 61;
    rb[1] = 62;
    rc[1] = 63;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 9 xor  load quadword a
clock = 0;
    program_counter= 8;

    opcode[0] = 11'b01001000001;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 68;
    rt[1] = 72;


    ra[0] = 65;
    rb[0] = 66;
    rc[0] = 67;
    ra[1] = 69;
    rb[1] = 70;
    rc[1] = 71;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


// 10 nand   storequadword d
clock = 0;
    program_counter= 9;

    opcode[0] = 11'b00011000001;
    opcode[1] = 11'b00100100000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 76;
    rt[1] = 80;


    ra[0] = 73;
    rb[0] = 74;
    rc[0] = 75;
    ra[1] = 77;
    rb[1] = 78;
    rc[1] = 79;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 11 nor store quadword d
clock = 0;
    program_counter= 10;

    opcode[0] = 11'b00001001001;
    opcode[1] = 11'b00100100000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 84;
    rt[1] = 88;


    ra[0] = 81;
    rb[0] = 82;
    rc[0] = 83;
    ra[1] = 85;
    rb[1] = 86;
    rc[1] = 87;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 12 count leading zeros  store quadword d

clock = 0;
    program_counter= 11;

    opcode[0] = 11'b01010100101;
    opcode[1] = 11'b00100100000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 92;
    rt[1] = 96;


    ra[0] = 89;
    rb[0] = 90;
    rc[0] = 91;
    ra[1] = 93;
    rb[1] = 94;
    rc[1] = 95;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//13 select bits store quadword x

clock = 0;
    program_counter= 12;

    opcode[0] = 11'b10000000000;
    opcode[1] = 11'b00101000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 100;
    rt[1] = 104;


    ra[0] = 97;
    rb[0] = 98;
    rc[0] = 99;
    ra[1] = 101;
    rb[1] = 102;
    rc[1] = 103;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//14 add halfword immediate  store quadword x

clock = 0;
    program_counter= 13;

    opcode[0] = 11'b00011101000;
    opcode[1] = 11'b00101000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 108;
    rt[1] = 112;


    ra[0] = 105;
    rb[0] = 106;
    rc[0] = 107;
    ra[1] = 109;
    rb[1] = 110;
    rc[1] = 111;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//15 add halfword  store quaword x

clock = 0;
    program_counter= 14;

    opcode[0] = 11'b00011001000;
    opcode[1] = 11'b00101000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 116;
    rt[1] = 120;


    ra[0] = 113;
    rb[0] = 114;
    rc[0] = 115;
    ra[1] = 117;
    rb[1] = 118;
    rc[1] = 119;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


    
//16 subtract from halfword store  quadword a
clock = 0;
    program_counter= 15;

    opcode[0] = 11'b00001001000;
    opcode[1] = 11'b00100000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 124;
    rt[1] = 0;


    ra[0] = 121;
    rb[0] = 122;
    rc[0] = 123;
    ra[1] = 125;
    rb[1] = 126;
    rc[1] = 127;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//17 subtract halfword immediate  store quadword a
clock = 0;
    program_counter= 16;

    opcode[0] = 11'b00001101000;
    opcode[1] = 11'b00100000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//18 average bytes  store quaword a
clock = 0;
    program_counter= 17;

    opcode[0] = 11'b00011010011;
    opcode[1] = 11'b00100000100;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 7;
    rt[0] = 12;
    rt[1] = 16;


    ra[0] = 9;
    rb[0] = 10;
    rc[0] = 11;
    ra[1] = 13;
    rb[1] = 14;
    rc[1] = 15;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//19 absolute differences of bytes shift left quardword by bits
clock = 0;
    program_counter= 18;

    opcode[0] = 11'b00001010011;
    opcode[1] = 11'b00111011011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 20;
    rt[1] = 24;


    ra[0] = 17;
    rb[0] = 18;
    rc[0] = 19;
    ra[1] = 21;
    rb[1] = 22;
    rc[1] = 23;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


//20 sum bytes into halfword shift left quardword by bits
clock = 0;
    program_counter= 19;

    opcode[0] = 11'b01001010011;
    opcode[1] = 11'b00111011011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 28;
    rt[1] = 32;


    ra[0] = 25;
    rb[0] = 26;
    rc[0] = 27;
    ra[1] = 29;
    rb[1] = 30;
    rc[1] = 31;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//21 multiply unsigned shift left quardword by bits
clock = 0;
    program_counter= 20;

    opcode[0] = 11'b01111001100;
    opcode[1] = 11'b00111011011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 8;
    forward_stage[1] = 4;
    rt[0] = 36;
    rt[1] = 40;


    ra[0] = 33;
    rb[0] = 34;
    rc[0] = 35;
    ra[1] = 37;
    rb[1] = 38;
    rc[1] = 39;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//22 multiply immediate shift left quardword by bits immediate
clock = 0;
    program_counter= 21;

    opcode[0] = 11'b01110100000;
    opcode[1] = 11'b00111111011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 8;
    forward_stage[1] = 4;
    rt[0] = 44;
    rt[1] = 48;


    ra[0] = 41;
    rb[0] = 42;
    rc[0] = 43;
    ra[1] = 45;
    rb[1] = 46;
    rc[1] = 47;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//23 multiply unsigned immediate shift left quardword by bits immediate
clock = 0;
    program_counter= 22;

    opcode[0] = 11'b01110101000;
    opcode[1] = 11'b00111111011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 8;
    forward_stage[1] = 4;
    rt[0] = 52;
    rt[1] = 56;


    ra[0] = 49;
    rb[0] = 50;
    rc[0] = 51;
    ra[1] = 53;
    rb[1] = 56;
    rc[1] = 55;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//24 immediate load halfword shift left quardword by bits immediate
clock = 0;
    program_counter= 23;

    opcode[0] = 11'b01000001100;
    opcode[1] = 11'b00111111011;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 60;
    rt[1] = 64;


    ra[0] = 57;
    rb[0] = 58;
    rc[0] = 59;
    ra[1] = 61;
    rb[1] = 62;
    rc[1] = 63;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//25 immediate load halfword upper shift left quardword by bytes
clock = 0;
    program_counter= 24;

    opcode[0] = 11'b01000001000;
    opcode[1] = 11'b00111011111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 68;
    rt[1] = 72;


    ra[0] = 65;
    rb[0] = 66;
    rc[0] = 67;
    ra[1] = 69;
    rb[1] = 70;
    rc[1] = 71;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//26 immediate load word shift left quardword by bytes
clock = 0;
    program_counter= 25;

    opcode[0] = 11'b01000000100;
    opcode[1] = 11'b00111011111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 76;
    rt[1] = 80;


    ra[0] = 73;
    rb[0] = 74;
    rc[0] = 75;
    ra[1] = 77;
    rb[1] = 78;
    rc[1] = 79;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//27 immediate load address shift left quardword by bytes
clock = 0;
    program_counter= 26;

    opcode[0] = 11'b01000010000;
    opcode[1] = 11'b00111011111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 84;
    rt[1] = 88;


    ra[0] = 81;
    rb[0] = 82;
    rc[0] = 83;
    ra[1] = 85;
    rb[1] = 86;
    rc[1] = 87;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//28 equivalent shift left quardword by bytes immediate
clock = 0;
    program_counter= 27;

    opcode[0] = 11'b01100000100;
    opcode[1] = 11'b00111111111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 92;
    rt[1] = 96;


    ra[0] = 89;
    rb[0] = 90;
    rc[0] = 91;
    ra[1] = 93;
    rb[1] = 94;
    rc[1] = 95;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//29 form select mask for bytes immediate shift left quardword by bytes immediate
clock = 0;
    program_counter= 28;

    opcode[0] = 11'b00110010100;
    opcode[1] = 11'b00111111111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 100;
    rt[1] = 104;


    ra[0] = 97;
    rb[0] = 98;
    rc[0] = 99;
    ra[1] = 101;
    rb[1] = 102;
    rc[1] = 103;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


//30 count ones in bytes shift left quardword by bytes immediate
clock = 0;
    program_counter= 29;

    opcode[0] = 11'b01010110100;
    opcode[1] = 11'b00111111111;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 108;
    rt[1] = 112;


    ra[0] = 105;
    rb[0] = 106;
    rc[0] = 107;
    ra[1] = 109;
    rb[1] = 110;
    rc[1] = 111;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//31 gather bits from bytes  rotate quadword by bits
clock = 0;
    program_counter= 30;

    opcode[0] = 11'b00110110010;
    opcode[1] = 11'b00111011000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 116;
    rt[1] = 120;


    ra[0] = 113;
    rb[0] = 114;
    rc[0] = 115;
    ra[1] = 117;
    rb[1] = 118;
    rc[1] = 119;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//32 gather bits from halfword  rotate quadword by bits
clock = 0;
    program_counter= 31;

    opcode[0] = 11'b00110110001;
    opcode[1] = 11'b00111011000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 124;
    rt[1] = 0;


    ra[0] = 121;
    rb[0] = 122;
    rc[0] = 123;
    ra[1] = 125;
    rb[1] = 126;
    rc[1] = 127;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//33 gather bits from word  rotate quadword by bits
clock = 0;
    program_counter= 32;

    opcode[0] = 11'b00110110000;
    opcode[1] = 11'b00111011000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


// 34 and byte immediate rotate quadword by bits immediate
clock = 0;
    program_counter= 33;

    opcode[0] = 11'b00010110000;
    opcode[1] = 11'b00111111000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 12;
    rt[1] = 16;


    ra[0] = 9;
    rb[0] = 10;
    rc[0] = 11;
    ra[1] = 13;
    rb[1] = 14;
    rc[1] = 15;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 35 and halfword immediate rotate quadword by bits immediate
clock = 0;
    program_counter= 34;

    opcode[0] = 11'b00010101000;
    opcode[1] = 11'b00111111000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 20;
    rt[1] = 24;


    ra[0] = 17;
    rb[0] = 18;
    rc[0] = 19;
    ra[1] = 21;
    rb[1] = 22;
    rc[1] = 23;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 36 and word immediate rotate quadword by bits immediate
clock = 0;
    program_counter= 35;

    opcode[0] = 11'b00010100000;
    opcode[1] = 11'b00111111000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 28;
    rt[1] = 32;


    ra[0] = 25;
    rb[0] = 26;
    rc[0] = 27;
    ra[1] = 29;
    rb[1] = 30;
    rc[1] = 31;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 37 or byte immediate rotate quadword by bytes

clock = 0;
    program_counter= 36;

    opcode[0] = 11'b00000110000;
    opcode[1] = 11'b00111011100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 36;
    rt[1] = 40;


    ra[0] = 33;
    rb[0] = 34;
    rc[0] = 35;
    ra[1] = 37;
    rb[1] = 38;
    rc[1] = 39;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 38 or halfword immediate rotate quadword by bytes
clock = 0;
    program_counter= 37;

    opcode[0] = 11'b00000101000;
    opcode[1] = 11'b00111011100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 44;
    rt[1] = 48;


    ra[0] = 41;
    rb[0] = 42;
    rc[0] = 43;
    ra[1] = 45;
    rb[1] = 46;
    rc[1] = 47;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 39 or word immediate rotate quadword by bytes
clock = 0;
    program_counter= 38;

    opcode[0] = 11'b00000100000;
    opcode[1] = 11'b00111011100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 52;
    rt[1] = 56;


    ra[0] = 49;
    rb[0] = 50;
    rc[0] = 51;
    ra[1] = 53;
    rb[1] = 54;
    rc[1] = 55;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 40 xor byte immediate rotate quadword by byte immediate
clock = 0;
    program_counter= 39;

    opcode[0] = 11'b00000110000;
    opcode[1] = 11'b00111111100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 4;
    forward_stage[1] = 4;
    rt[0] = 60;
    rt[1] = 64;


    ra[0] = 57;
    rb[0] = 58;
    rc[0] = 59;
    ra[1] = 61;
    rb[1] = 62;
    rc[1] = 63;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 41 xor halfword immediate rotate quadword by byte immediate
clock = 0;
    program_counter= 40;

    opcode[0] = 11'b01000101000;
    opcode[1] = 11'b00111111100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 68;
    rt[1] = 72;


    ra[0] = 65;
    rb[0] = 66;
    rc[0] = 67;
    ra[1] = 69;
    rb[1] = 70;
    rc[1] = 71;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 42 xor word immediate rotate quadword by byte immediate

clock = 0;
    program_counter= 41;

    opcode[0] = 11'b01000100000;
    opcode[1] = 11'b00111111100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 4;
    rt[0] = 76;
    rt[1] = 80;


    ra[0] = 73;
    rb[0] = 74;
    rc[0] = 75;
    ra[1] = 77;
    rb[1] = 78;
    rc[1] = 79;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


// 43 shift left halfword branch if not zero word
clock = 0;
    program_counter= 42;

    opcode[0] = 11'b00001011111;
    opcode[1] = 11'b00100001000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 84;
    rt[1] = 88;


    ra[0] = 81;
    rb[0] = 82;
    rc[0] = 83;
    ra[1] = 85;
    rb[1] = 86;
    rc[1] = 87;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 44 shift left halfword immediate  branch if not zero word

clock = 0;
    program_counter= 43;

    opcode[0] = 11'b00001111111;
    opcode[1] = 11'b00100001000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 92;
    rt[1] = 96;


    ra[0] = 89;
    rb[0] = 90;
    rc[0] = 91;
    ra[1] = 93;
    rb[1] = 94;
    rc[1] = 95;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 45 rotate halfword branch if not zero word
clock = 0;
    program_counter= 44;

    opcode[0] = 11'b00001011100;
    opcode[1] = 11'b00100001000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 100;
    rt[1] = 104;


    ra[0] = 97;
    rb[0] = 98;
    rc[0] = 99;
    ra[1] = 101;
    rb[1] = 102;
    rc[1] = 103;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 46 rotate halfword immediate branch if  zero word
clock = 0;
    program_counter= 45;

    opcode[0] = 11'b00001111100;
    opcode[1] = 11'b00100000000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 108;
    rt[1] = 112;


    ra[0] = 105;
    rb[0] = 106;
    rc[0] = 107;
    ra[1] = 109;
    rb[1] = 110;
    rc[1] = 111;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 47 shift left word  branch if  zero word
clock = 0;
    program_counter= 46;

    opcode[0] = 11'b00001011011;
    opcode[1] = 11'b00100000000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 116;
    rt[1] = 120;


    ra[0] = 113;
    rb[0] = 114;
    rc[0] = 115;
    ra[1] = 117;
    rb[1] = 118;
    rc[1] = 119;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 48 shift left word immediate branch if zero word
clock = 0;
    program_counter= 47;

    opcode[0] = 11'b00001111011;
    opcode[1] = 11'b00100000000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 124;
    rt[1] = 0;


    ra[0] = 121;
    rb[0] = 122;
    rc[0] = 123;
    ra[1] = 125;
    rb[1] = 126;
    rc[1] = 127;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5


// 49 rotate word  branch if  not zero halfword

clock = 0;
    program_counter= 48;

    opcode[0] = 11'b00001011000;
    opcode[1] = 11'b00100011000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 50 rotate word immediate branch if  not zero halfword
clock = 0;
    program_counter= 49;

    opcode[0] = 11'b00001111000;
    opcode[1] = 11'b00100011000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 4;
    forward_stage[1] = 1;
    rt[0] = 12;
    rt[1] = 16;


    ra[0] = 9;
    rb[0] = 10;
    rc[0] = 11;
    ra[1] = 13;
    rb[1] = 14;
    rc[1] = 15;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 51 compare logical greater than halfword branch if  not zero halfword
clock = 0;
    program_counter= 50;

    opcode[0] = 11'b01011001000;
    opcode[1] = 11'b00100011000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 1;
    rt[0] = 20;
    rt[1] = 24;


    ra[0] = 17;
    rb[0] = 18;
    rc[0] = 19;
    ra[1] = 21;
    rb[1] = 22;
    rc[1] = 23;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

// 52 compare logical greater than halfword immediate branch if  zero halfword
clock = 0;
    program_counter= 51;

    opcode[0] = 11'b01011101000;
    opcode[1] = 11'b00100010000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 1;
    rt[0] = 28;
    rt[1] = 32;


    ra[0] = 25;
    rb[0] = 26;
    rc[0] = 27;
    ra[1] = 29;
    rb[1] = 30;
    rc[1] = 31;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 53 compare logical greater than word branch if  zero halfword
clock = 0;
    program_counter= 52;

    opcode[0] = 11'b01011000000;
    opcode[1] = 11'b00100010000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 1;
    rt[0] = 36;
    rt[1] = 40;


    ra[0] = 33;
    rb[0] = 34;
    rc[0] = 35;
    ra[1] = 37;
    rb[1] = 38;
    rc[1] = 39;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
// 54 compare logical greater than word immediate branch if zero halfword
clock = 0;
    program_counter= 53;

    opcode[0] = 11'b01011100000;
    opcode[1] = 11'b00100010000;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 1;
    rt[0] = 44;
    rt[1] = 48;


    ra[0] = 41;
    rb[0] = 42;
    rc[0] = 43;
    ra[1] = 45;
    rb[1] = 46;
    rc[1] = 47;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//55 Compare Equal Byte load quardword d
clock = 0;
    program_counter= 54;

    opcode[0] = 11'b01111010000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 52;
    rt[1] = 56;


    ra[0] = 49;
    rb[0] = 50;
    rc[0] = 51;
    ra[1] = 53;
    rb[1] = 54;
    rc[1] = 55;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//56 Compare Equal Byte Immediate load quardword d
clock = 0;
    program_counter= 55;

    opcode[0] = 11'b01111110000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 60;
    rt[1] = 64;


    ra[0] = 57;
    rb[0] = 58;
    rc[0] = 59;
    ra[1] = 61;
    rb[1] = 62;
    rc[1] = 63;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//57 Compare Equal Halfword load quardword d
clock = 0;
    program_counter= 56;

    opcode[0] = 11'b01111001000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 68;
    rt[1] = 72;


    ra[0] = 65;
    rb[0] = 66;
    rc[0] = 67;
    ra[1] = 69;
    rb[1] = 70;
    rc[1] = 71;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//58 Compare Equal Halfword Immediate no op odd
clock = 0;
    program_counter= 57;

    opcode[0] = 11'b01111101000;
    opcode[1] = 11'b01000000001;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 0;
    rt[0] = 76;
    rt[1] = 80;


    ra[0] = 73;
    rb[0] = 74;
    rc[0] = 75;
    ra[1] = 77;
    rb[1] = 78;
    rc[1] = 79;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//59 Compare Equal word no op odd
clock = 0;
    program_counter= 58;

    opcode[0] = 11'b01111000000;
    opcode[1] = 11'b01000000001;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 0;
    rt[0] = 84;
    rt[1] = 88;


    ra[0] = 81;
    rb[0] = 82;
    rc[0] = 83;
    ra[1] = 85;
    rb[1] = 86;
    rc[1] = 87;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//60 Compare Equal word Immediate  no op odd
clock = 0;
    program_counter= 59;

    opcode[0] = 11'b01111100000;
    opcode[1] = 11'b01000000001;
    write_back[0] = 1;
    write_back[1] = 0;
    forward_stage[0] = 3;
    forward_stage[1] = 0;
    rt[0] = 92;
    rt[1] = 96;


    ra[0] = 89;
    rb[0] = 90;
    rc[0] = 91;
    ra[1] = 93;
    rb[1] = 94;
    rc[1] = 95;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//61 Compare Greater Than Byte load quardword x
clock = 0;
    program_counter= 60;

    opcode[0] = 11'b01001010000;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 100;
    rt[1] = 104;


    ra[0] = 97;
    rb[0] = 98;
    rc[0] = 99;
    ra[1] = 101;
    rb[1] = 102;
    rc[1] = 103;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//62 Compare Greater Than Byte Immediate load quardword x
clock = 0;
    program_counter= 61;

    opcode[0] = 11'b01001110000;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 108;
    rt[1] = 112;


    ra[0] = 105;
    rb[0] = 106;
    rc[0] = 107;
    ra[1] = 109;
    rb[1] = 110;
    rc[1] = 111;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//63 Compare Greater Than Halfword load quardword x
clock = 0;
    program_counter= 62;

    opcode[0] = 11'b01001001000;
    opcode[1] = 11'b00111000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 116;
    rt[1] = 120;


    ra[0] = 113;
    rb[0] = 114;
    rc[0] = 115;
    ra[1] = 117;
    rb[1] = 118;
    rc[1] = 119;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//64 Compare Greater Than Halfword Immediate load quardword d
clock = 0;
    program_counter= 63;

    opcode[0] = 11'b01001101000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 124;
    rt[1] = 0;


    ra[0] = 121;
    rb[0] = 122;
    rc[0] = 123;
    ra[1] = 125;
    rb[1] = 126;
    rc[1] = 127;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//65 Compare Greater Than word  load quardword d
clock = 0;
    program_counter= 64;

    opcode[0] = 11'b01001000000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 4;
    rt[1] = 8;


    ra[0] = 1;
    rb[0] = 2;
    rc[0] = 3;
    ra[1] = 5;
    rb[1] = 6;
    rc[1] = 7;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//66 Compare Greater Than Word Immediate  load quardword d
clock = 0;
    program_counter= 65;

    opcode[0] = 11'b01001100000;
    opcode[1] = 11'b00110100000;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 3;
    forward_stage[1] = 7;
    rt[0] = 12;
    rt[1] = 16;


    ra[0] = 9;
    rb[0] = 10;
    rc[0] = 11;
    ra[1] = 13;
    rb[1] = 14;
    rc[1] = 15;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//67 Floating Add  load quardword a
clock = 0;
    program_counter= 66;

    opcode[0] = 11'b01011000100;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 7;
    forward_stage[1] = 7;
    rt[0] = 20;
    rt[1] = 24;


    ra[0] = 17;
    rb[0] = 18;
    rc[0] = 19;
    ra[1] = 21;
    rb[1] = 22;
    rc[1] = 23;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5

//68 Floating Subtract load quardword a
clock = 0;
    program_counter= 67;

    opcode[0] = 11'b01011000101;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 7;
    forward_stage[1] = 7;
    rt[0] = 28;
    rt[1] = 32;


    ra[0] = 25;
    rb[0] = 26;
    rc[0] = 27;
    ra[1] = 29;
    rb[1] = 30;
    rc[1] = 31;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//69 Floating Multiply load quardword a
clock = 0;
    program_counter= 68;

    opcode[0] = 11'b01011000110;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 7;
    forward_stage[1] = 7;
    rt[0] = 36;
    rt[1] = 40;


    ra[0] = 33;
    rb[0] = 34;
    rc[0] = 35;
    ra[1] = 37;
    rb[1] = 38;
    rc[1] = 39;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//70 Floating Multiply and Add load quardword a
clock = 0;
    program_counter= 69;

    opcode[0] = 11'b11100000000;
    opcode[1] = 11'b00110000100;
    write_back[0] = 1;
    write_back[1] = 1;
    forward_stage[0] = 7;
    forward_stage[1] = 7;
    rt[0] = 44;
    rt[1] = 48;


    ra[0] = 41;
    rb[0] = 42;
    rc[0] = 43;
    ra[1] = 45;
    rb[1] = 46;
    rc[1] = 47;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//71 no op even  load quardword a
clock = 0;
    program_counter= 70;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b00110000100;
    write_back[0] = 0;
    write_back[1] = 1;
    forward_stage[0] = 0;
    forward_stage[1] = 7;
    rt[0] = 52;
    rt[1] = 56;


    ra[0] = 49;
    rb[0] = 50;
    rc[0] = 51;
    ra[1] = 53;
    rb[1] = 54;
    rc[1] = 55;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//72 stop stop
clock = 0;
    program_counter= 71;

    opcode[0] = 11'b00000000000;
    opcode[1] = 11'b00000000000;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 60;
    rt[1] = 64;


    ra[0] = 57;
    rb[0] = 58;
    rc[0] = 59;
    ra[1] = 61;
    rb[1] = 62;
    rc[1] = 63;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//73 no op even no op odd
clock = 0;
    program_counter= 72;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 68;
    rt[1] = 72;


    ra[0] = 65;
    rb[0] = 66;
    rc[0] = 67;
    ra[1] = 69;
    rb[1] = 70;
    rc[1] = 71;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//74 no op even no op odd
clock = 0;
    program_counter= 73;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 76;
    rt[1] = 80;


    ra[0] = 73;
    rb[0] = 74;
    rc[0] = 75;
    ra[1] = 77;
    rb[1] = 78;
    rc[1] = 79;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//75 no op even no op odd
clock = 0;
    program_counter= 74;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 84;
    rt[1] = 88;


    ra[0] = 81;
    rb[0] = 82;
    rc[0] = 83;
    ra[1] = 85;
    rb[1] = 86;
    rc[1] = 87;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//76 no op even no op odd
clock = 0;
    program_counter= 75;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 92;
    rt[1] = 96;


    ra[0] = 89;
    rb[0] = 90;
    rc[0] = 91;
    ra[1] = 93;
    rb[1] = 94;
    rc[1] = 95;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//77 no op even no op odd
clock = 0;
    program_counter= 76;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 100;
    rt[1] = 104;


    ra[0] = 97;
    rb[0] = 98;
    rc[0] = 99;
    ra[1] = 101;
    rb[1] = 102;
    rc[1] = 103;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
//78 no op even no op odd
clock = 0;
    program_counter= 77;

    opcode[0] = 11'b00000000001;
    opcode[1] = 11'b01000000001;
    write_back[0] = 0;
    write_back[1] = 0;
    forward_stage[0] = 0;
    forward_stage[1] = 0;
    rt[0] = 108;
    rt[1] = 112;


    ra[0] = 105;
    rb[0] = 106;
    rc[0] = 107;
    ra[1] = 109;
    rb[1] = 110;
    rc[1] = 111;
    immediateIn[0] = 2;
    immediateIn[1] = 4;	
    #5 
    clock = 1;
    #5
    $finish;
end
endmodule
