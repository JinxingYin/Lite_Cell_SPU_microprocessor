
/* pipeline register after 1st operation register */
module pipelineReg(
input clock, 
input RegWrIn, 
input unsigned [6:0]RegTargetIn, 
input signed[127:0]RegValueIn, 
input unsigned [3:0]FWstageIn, 
output logic RegWrOut, 
output logic unsigned [6:0]RegTargetOut, 
output logic signed [127:0]RegValueOut, 
output logic unsigned [3:0]FWstageOut 
/*output logic FWRRegWrOut, 
output logic unsigned [6:0] FWRRegTargetOut, 
output logic signed [127:0]FWRRegValueOut, 
output logic unsigned [3:0]FWRstageOut
*/);

parameter unsigned current_stage = 3;

/*always_comb begin                         // this block is for fw unit

    FWRRegWrOut = RegWrIn;
    FWRRegTargetOut = RegTargetIn;
    FWRRegValueOut = RegValueIn;
    FWRstageOut = FWstageIn;
 
end
*/

always_ff @( posedge clock ) begin          // this block is for following pipeline register
     
    RegWrOut <= RegWrIn;
    RegTargetOut <= RegTargetIn;
    RegValueOut <= RegValueIn;
    FWstageOut <= FWstageIn;
    
end

endmodule

/* write back stage */
module WBReg(input clock, input RegWrIn, input unsigned [6:0]RegTargetIn,             
input signed [127:0]RegValueIn, input unsigned [3:0]FWstageIn, output logic RegWrOut, 
output logic unsigned [6:0]RegTargetOut, output logic signed [127:0]RegValueOut);

always_ff @( posedge clock ) begin 
    
    RegTargetOut <= RegTargetIn;
    RegValueOut <= RegValueIn;
    RegWrOut <= RegWrIn;
    
end

endmodule




