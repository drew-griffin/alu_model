
//Drew Seidel
//Prof Jasur Hanbaba
//ECE 508
//Homework 1


//This module defines the ALU performance. 
//inputs are A_In (given from register file Data_Out_1), B_In (given from register file Data_Out_2), Carry_In (simulated with many different carry ins in test bench)
//and Opcode (simulated over all opcodes)
//Ouputs are ALU_Out (determined by this module) and Carry_out (determined by this module)

import alu_regfile_defs::*;


module alu (
input logic [ALU_INPUT_WIDTH-1:0] A_In, B_In, // A and B operands
input logic Carry_In, 			      // Carry In 
input aluop_t Opcode, 			      // operation to perform 
output logic [ALU_OUTPUT_WIDTH-1:0] ALU_Out,  // ALU result 
output logic                        Carry_Out // Carry out from teh ALU
);

//Use a simple switch case method to determine ALU_Out and Carry_Out operations given the Opcode 
logic [ALU_OUTPUT_WIDTH:0] temp_ALU_Out; //temp ALU output with an extra bit for carry out 

always_comb //change on any input change
begin 
  case(Opcode)
 	0: begin  //add
	temp_ALU_Out = A_In + B_In + Carry_In;	
	ALU_Out = A_In + B_In + Carry_In;
	Carry_Out = temp_ALU_Out[ALU_OUTPUT_WIDTH]; 
	end
	1: begin //subtract
	temp_ALU_Out = A_In + ~B_In + Carry_In;
	ALU_Out = A_In + ~B_In + Carry_In;
	Carry_Out = temp_ALU_Out[ALU_OUTPUT_WIDTH]; 
	end
	2: begin // not a
	ALU_Out = ~A_In;
	Carry_Out = 1'b0; 
	end
	3: begin // Or 
	ALU_Out = A_In | B_In;
	Carry_Out = 1'b0; 
	end
 	4: begin // And 
	ALU_Out = A_In & B_In;
	Carry_Out = 1'b0; 
	end 
	5: begin //Not A and B
	ALU_Out = ~A_In & B_In;
	Carry_Out = 1'b0; 
	end 
	6: begin // Exor
	ALU_Out = A_In ^ B_In; 
	Carry_Out = 1'b0; 
	end 
	7: begin //Exnor
	ALU_Out = A_In ~^ B_In; 
	Carry_Out = 1'b0; 	
	end 
endcase

end

endmodule: alu