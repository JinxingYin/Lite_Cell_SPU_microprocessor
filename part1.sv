`include "opdecoder.sv"
`include "pipelineReg.sv"
`include "rf_fw.sv"
`include "PipeStage.sv"


module part1(input clock, input unsigned [5:0]program_counter, input unsigned [1:0][10:0]opcode, input unsigned [1:0] write_back, input unsigned [1:0][3:0]forward_stage 
,input unsigned [1:0][6:0] ra, input unsigned [1:0][6:0] rb, input unsigned [1:0][6:0] rc, input unsigned [1:0][6:0] rt, input signed [1:0][17:0] immediate,
output logic branch_taken, output logic signed[15:0] branch_value ,output logic stop);

logic unsigned [1:0][10:0] opcode_dec_out;

logic unsigned [1:0][10:0] opcode_rf_out;
logic signed [1:0][17:0] immediate_rf_out;
logic unsigned [1:0][6:0] rt_out_rf;
logic unsigned [1:0][4:0] fw_out_rf;
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

opdecode opdecode_inst1(.opcode_in(opcode), .opcode_out(opcode_dec_out));
regFileForward  regFileForward_inst (.clock(clock), .wr_en(wr_en_wb), .wr_back_in(write_back), .opcode_in(opcode_dec_out), .immediateIn(immediate),.data_in(data_in_wb), .rt(rt), 
.rt_wb(rt_wb), .ra(ra), .rb(rb), .rc(rc),.forwardStage_in(forward_stage), .OddregisterValue(RegValueOutOdd), .OddregisterAddress(RegTargetOutOdd), .OddforwardStage(FWstageOutOdd), 
.OddwriteBack(RegWrOutOdd),  .EvenregisterValue(RegValueOutEven), .EvenregisterAddress(RegTargetOutEven), .EvenforwardStage(FWstageOutEven), .EvenwriteBack(RegWrOutEven), 
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
