module opdecode(input unsigned [10:0]opcode_in, output logic unsigned [6:0] opcode_out);

always_comb begin
    
    if(opcode_in[10:3] == 8'b00110100)
     opcode_out = 7'b0000001; // Load Quadword d 
    else if(opcode_in == 11'b00111000100)
     opcode_out = 7'b0000010; // Load Quadword x
    else if(opcode_in[10:2] == 9'b001100001)
     opcode_out = 7'b0000011; // Load Quadword a
    else if(opcode_in[10:3] == 8'b00100100)
     opcode_out = 7'b0000100; // Store Quadword d
    else if(opcode_in == 11'b00101000100)
     opcode_out = 7'b0000101; // Sotre Quadword x
    else if(opcode_in[10:2] == 9'b001000001)
     opcode_out = 7'b0000110; // Store Quadword a
    else if(opcode_in == 11'b00011000000)
     opcode_out = 7'b0000111; // add word
    else if(opcode_in[10:3] == 8'b00011100)
     opcode_out = 7'b0001000; // add word immediate
    else if(opcode_in == 11'b00001000000)
     opcode_out = 7'b0001001; // subtract from word 
    else if(opcode_in[10:3] == 8'b00001100)
     opcode_out = 7'b0001010; // Subtract from Word Immediate
    else if(opcode_in == 11'b01111000100)
     opcode_out = 7'b0001011; // Multiply
    else if(opcode_in[10:7] == 4'b1100)
     opcode_out = 7'b0001100; // Multiply and Add
    else if(opcode_in == 11'b00011000001)
     opcode_out = 7'b0001101; // And
    else if(opcode_in == 11'b00001000001)
     opcode_out = 7'b0001110; // Or
    else if(opcode_in == 11'b01001000001)
     opcode_out = 7'b0001111; // Exclusive or
    else if(opcode_in == 11'b00011001001)
     opcode_out = 7'b0010000; // Nand
    else if(opcode_in == 11'b00001001001)
     opcode_out = 7'b0010001; // Nor
    else if(opcode_in == 11'b01010100101)
     opcode_out = 7'b0010010; // Count Leading Zeros
    else if(opcode_in[10:7] == 4'b1000)
     opcode_out = 7'b0010011; // Select Bits
    else if(opcode_in[10:3] == 8'b00011101)
     opcode_out = 7'b0010100; // Add Halfword Immediate
    else if(opcode_in == 11'b00011001000)
     opcode_out = 7'b0010101; // Add Halfword 
    else if(opcode_in == 11'b00001001000)
     opcode_out = 7'b0010110; // Subtract from Halfword 
    else if(opcode_in[10:3] == 8'b00001101)
     opcode_out = 7'b0010111; // Subtract from Halfword Immediate
    else if(opcode_in == 11'b00011010011)
     opcode_out = 7'b0011000; // Average Bytes
    else if(opcode_in == 11'b00001010011)
     opcode_out = 7'b0011001; // Absolute Differences of Bytes
    else if(opcode_in == 11'b01001010011)
     opcode_out = 7'b0011010; // Sum Bytes into Halfword
    else if(opcode_in == 11'b01111001100)
     opcode_out = 7'b0011011; // Multiply Unsigned
    else if(opcode_in[10:3] == 8'b01110100)
     opcode_out = 7'b0011100; // Multiply Immediate
    else if(opcode_in[10:3] == 8'b01110101)
     opcode_out = 7'b0011101; // Multiply Unsigned Immediate
    else if(opcode_in[10:2] == 9'b010000011)
     opcode_out = 7'b0011110; // Immediate Load Halfword
    else if(opcode_in[10:2] == 9'b010000010)
     opcode_out = 7'b0011111; // Immediate Load Halfword Upper 
    else if(opcode_in[10:2] == 9'b010000001)
     opcode_out = 7'b0100000; // Immediate Load Word
    else if(opcode_in[10:4] == 7'b0100001)
     opcode_out = 7'b0100001; // Immediate Load Address
    else if(opcode_in[10:2] == 9'b011000001)
     opcode_out = 7'b0100010; // Equivalent
    else if(opcode_in[10:2] == 9'b001100101)
     opcode_out = 7'b0100011; // Form Select Mask for Bytes Immediate
    else if(opcode_in == 11'b01010110100)
     opcode_out = 7'b0100100; // Count Ones in Bytes
    else if(opcode_in == 11'b00110110010)
     opcode_out = 7'b0100101; // Gather Bits from Bytes
    else if(opcode_in == 11'b00110110001)
     opcode_out = 7'b0100110; // Gather Bits from Halfwords 
    else if(opcode_in == 11'b00110110000)
     opcode_out = 7'b0100111; // Gather Bits from Words
    else if(opcode_in[10:3] == 8'b00010110)
     opcode_out = 7'b0101000; // And Byte Immediate
    else if(opcode_in[10:3] == 8'b00010101)
     opcode_out = 7'b0101001; // And Halfword Immediate
    else if(opcode_in[10:3] == 8'b00010100)
     opcode_out = 7'b0101010; // And Word Immediate
    else if(opcode_in[10:3] == 8'b00000110)
     opcode_out = 7'b0101011; // Or Byte Immediate
    else if(opcode_in[10:3] == 8'b00000101)
     opcode_out = 7'b0101100; // Or Halfword Immediate
    else if(opcode_in[10:3] == 8'b00000100)
     opcode_out = 7'b0101101; // Or Word Immediate
    else if(opcode_in[10:3] == 8'b01000110)
     opcode_out = 7'b0101110; // Exclusive Or Byte Immediate
    else if(opcode_in[10:3] == 8'b01000101)
     opcode_out = 7'b0101111; // Exclusive Or Halfword Immediate
    else if(opcode_in[10:3] == 8'b01000100)
     opcode_out = 7'b0110000; // Exclusive Or Word Immediate
    else if(opcode_in == 11'b00001011111)
     opcode_out = 7'b0110001; // Shift Left Halfword
    else if(opcode_in == 11'b00001111111)
     opcode_out = 7'b0110010; // Shift Left Halfword Immediate
    else if(opcode_in == 11'b00001011100)
     opcode_out = 7'b0110011; // Rotate Halfword
    else if(opcode_in == 11'b00001111100)
     opcode_out = 7'b0110100; // Rotate Halfword Immediate
    else if(opcode_in == 11'b00001011011)
     opcode_out = 7'b0110101; // Shift Left word
    else if(opcode_in == 11'b00001111011)
     opcode_out = 7'b0110110; // Shift Left Word Immediate
    else if(opcode_in == 11'b00001011000)
     opcode_out = 7'b0110111; // Rotate word
    else if(opcode_in == 11'b00001111000)
     opcode_out = 7'b0111000; // Rotate Word Immediate
    else if(opcode_in == 11'b00111011011)
     opcode_out = 7'b0111001; // Shift Left Quadword by Bits
    else if(opcode_in == 11'b00111111011)
     opcode_out = 7'b0111010; // Shift Left Quadword by Bits Immediate
    else if(opcode_in == 11'b00111011111)
     opcode_out = 7'b0111011; // Shift Left Quadword by Bytes
    else if(opcode_in == 11'b00111111111)
     opcode_out = 7'b0111100; // Shift Left Quadword by Bytes Immediate
    else if(opcode_in == 11'b00111011000)
     opcode_out = 7'b0111101; // Rotate Quadword by Bits
    else if(opcode_in == 11'b00111111000)
     opcode_out = 7'b0111110; // Rotate Quadword by Bits Immediate
    else if(opcode_in == 11'b00111011100)
     opcode_out = 7'b0111111; // Rotate Quadword by Bytes
    else if(opcode_in == 11'b00111111100)
     opcode_out = 7'b1000000; // Rotate Quadword by Bytes Immediate
    else if(opcode_in == 11'b01011001000)
     opcode_out = 7'b1000001; // Compare Logical Greater Than Halfword
    else if(opcode_in[10:3] == 8'b01011101)
     opcode_out = 7'b1000010; // Compare Logical Greater Than Halfword Immediate
    else if(opcode_in == 11'b01011000000)
     opcode_out = 7'b1000011; // Compare Logical Greater Than Word
    else if(opcode_in[10:3] == 8'b01011100)
     opcode_out = 7'b1000100; // Compare Logical Greater Than Word Immediate
    else if(opcode_in == 11'b01111010000)
     opcode_out = 7'b1000101; // Compare Equal Byte
    else if(opcode_in [10:3] == 8'b01111110)
     opcode_out = 7'b1000110; // Compare Equal Byte Immediate
    else if(opcode_in == 11'b01111001000)
     opcode_out = 7'b1000111; // Compare Equal Halfword
    else if(opcode_in[10:3] == 8'b01111101)
     opcode_out = 7'b1001000; // Compare Equal Halfword Immediate
    else if(opcode_in == 11'b01111000000)
     opcode_out = 7'b1001001; // Compare Equal word
    else if(opcode_in[10:3] == 8'b01111100)
     opcode_out = 7'b1001010; // Compare Equal word Immediate
    else if(opcode_in == 11'b01001010000)
     opcode_out = 7'b1001011; // Compare Greater Than Byte
    else if(opcode_in[10:3] == 8'b01001110)
     opcode_out = 7'b1001100; // Compare Greater Than Byte Immediate
    else if(opcode_in == 11'b01001001000)
     opcode_out = 7'b1001101; // Compare Greater Than Halfword
    else if(opcode_in[10:3] == 8'b01001101)
     opcode_out = 7'b1001110; // Compare Greater Than Halfword Immediate
    else if(opcode_in == 11'b01001000000)
     opcode_out = 7'b1001111; // Compare Greater Than word
    else if(opcode_in[10:3] == 8'b01001100)
     opcode_out = 7'b1010000; // Compare Greater Than Word Immediate 
    else if(opcode_in[10:2] == 9'b001000010)
     opcode_out = 7'b1010001; // Branch if Not Zero Word
    else if(opcode_in[10:2] == 9'b001000000)
     opcode_out = 7'b1010010; // Branch if Zero Word
    else if(opcode_in[10:2] == 9'b001000110)
     opcode_out = 7'b1010011; // Branch if Not Zero Halfword
    else if(opcode_in[10:2] == 9'b001000100)
     opcode_out = 7'b1010100; // Branch if Zero Halfword
    else if(opcode_in == 11'b01011000100)
     opcode_out = 7'b1010101; // Floating Add
    else if(opcode_in == 11'b01011000101)
     opcode_out = 7'b1010110; // Floating Subtract
   else if(opcode_in == 11'b01011000110)
     opcode_out = 7'b1010111; // Floating Multiply
    else if(opcode_in[10:7] == 4'b1110)
     opcode_out = 7'b1011000; // Floating Multiply and Add
    else if(opcode_in == 11'b00000000000)
     opcode_out = 7'b1011001; // Stop and Signal
    else if(opcode_in == 11'b00000000001)
     opcode_out = 7'b1011010; // No operation (Even)
    else if(opcode_in == 11'b01000000001)
     opcode_out = 7'b1011011; // No operation (Odd)
    
end
endmodule


module test();

logic [10:0]testInput;
logic [6:0] testOutput;
    
opdecode opdecode_inst(.opcode_in(testInput), .opcode_out(testOutput));
initial begin
    
    $monitor($time,, "in0 = %b, out = %d", testInput , testOutput);
    #1;
    testInput = 11'b00110100000;
    #1;      
    testInput = 11'b00111000100;
    #1;     
    testInput = 11'b00110000100;
    #1;     
    testInput = 11'b00100100000;
    #1;     
    testInput = 11'b00101000100;
    #1;      
    testInput = 11'b00100000100;
    #1;      
    testInput = 11'b00011000000;
    #1;      
    testInput = 11'b00011100000;
    #1;      
    testInput = 11'b00001000000;
    #1;      
    testInput = 11'b00001100000;
    #1;     
    testInput = 11'b01111000100;
    #1;      
    testInput = 11'b11000000000;
    #1;      
    testInput = 11'b00011000001;
    #1;    
    testInput = 11'b00001000001;
    #1;    
    testInput = 11'b01001000001;
    #1;    
    testInput = 11'b00011001001;
    #1;    
    testInput = 11'b00001001001;
    #1;    
    testInput = 11'b01010100101;
    #1;
    testInput = 11'b10000000000;
    #1;   
    testInput = 11'b00011101000;
    #1;     
    testInput = 11'b00011001000;
    #1;   
    testInput = 11'b00001001000;
    #1;   
    testInput = 11'b00001101000;
    #1;    
    testInput = 11'b00011010011;
    #1;
    testInput = 11'b00001010011;
    #1;    
    testInput = 11'b01001010011;
    #1;    
    testInput = 11'b01111001100;
    #1;    
    testInput = 11'b01110100000;
    #1;    
    testInput = 11'b01110101000;
    #1;     
    testInput = 11'b01000001100;
    #1;    
    testInput = 11'b01000001000;
    #1;    
    testInput = 11'b01000000100;
    #1;    
    testInput = 11'b01000010000;
    #1;     
    testInput = 11'b01100000100;
    #1;    
    testInput = 11'b00110010100;
    #1; 
    testInput = 11'b01010110100;
    #1; 
    testInput = 11'b00110110010;
    #1;  
    testInput = 11'b00110110001;
    #1;  
    testInput = 11'b00110110000;
    #1;  
    testInput = 11'b00010110000;
    #1;    
    testInput = 11'b00010101000;
    #1;    
    testInput = 11'b00010100000;
    #1;     
    testInput = 11'b00000110000;
    #1;     
    testInput = 11'b00000101000;
    #1;    
    testInput = 11'b00000100000;
    #1;    
    testInput = 11'b01000110000;
    #1;   
    testInput = 11'b01000101000;
    #1;    
    testInput = 11'b01000100000;
    #1;     
    testInput = 11'b00001011111;
    #1;    
    testInput = 11'b00001111111;
    #1;   
    testInput = 11'b00001011100;
    #1;   
    testInput = 11'b00001111100;
    #1;    
    testInput = 11'b00001011011;
    #1;    
    testInput = 11'b00001111011;
    #1;   
    testInput = 11'b00001011000;
    #1;    
    testInput = 11'b00001111000;
    #1; 
    testInput = 11'b00111011011;
    #1; 
    testInput = 11'b00111111011;
    #1;    
    testInput = 11'b00111011111;
    #1;    
    testInput = 11'b00111111111;
    #1;    
    testInput = 11'b00111011000;
    #1; 
    testInput = 11'b00111111000;
    #1;
    testInput = 11'b00111011100;
    #1;  
    testInput = 11'b00111111100;
    #1;
    testInput = 11'b01011001000;
    #1;
    testInput = 11'b01011101000;
    #1;  
    testInput = 11'b01011000000;
    #1;  
    testInput = 11'b01011100000;
    #1;
    testInput = 11'b01111010000;
    #1;   
    testInput = 11'b01111110000;
    #1;  
    testInput = 11'b01111001000;
    #1;  
    testInput = 11'b01111101000;
    #1;   
    testInput = 11'b01111000000;
    #1;  
    testInput = 11'b01111100000;
    #1;  
    testInput = 11'b01001010000;
    #1;   
    testInput = 11'b01001110000;
    #1;    
    testInput = 11'b01001001000;
    #1;
    testInput = 11'b01001101000;
    #1;
    testInput = 11'b01001000000;
    #1;
    testInput = 11'b01001100000;
    #1;   
    testInput = 11'b00100001000;
    #1;  
    testInput = 11'b00100000000;
    #1;  
    testInput = 11'b00100011000;
    #1;    
    testInput = 11'b00100010000;
    #1;
    testInput = 11'b01011000100;
    #1;
    testInput = 11'b01011000101;
    #1;
    testInput = 11'b01011000110;
    #1;
    testInput = 11'b11100000000;
    #1; 
    testInput = 11'b00000000000;
    #1;   
    testInput = 11'b00000000001;
    #1;  
    testInput = 11'b01000000001;
    #1;    
    $finish;
end

endmodule
