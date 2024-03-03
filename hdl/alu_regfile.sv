//Drew Seidel
//Prof Jasur Hanbaba
//ECE 508
//Homework 1


//This module defines the ALU regfile, and is responsible for simulating the wiring of the register files and the ALU
//This means the module will make input and output declarations, and instantaite the register file, followed buy the ALU
//As seen below 
//The test bench will call alu_regfile

import alu_regfile_defs::*;

module alu_regfile (
// register file interface
  input logic [REGFILE_ADDR_WIDTH-1:0] 	Read_Addr_1, Read_Addr_2, //read addresses 
  input logic [REGFILE_ADDR_WIDTH-1:0]  Write_Addr, 		  //write addresses 
  input logic 				Write_enable, 	          //write enable (1 to write)
								
  input logic [REGFILE_WIDTH-1:0]	Write_data, 		  //Write_data to register file

   //ALU interface. Data to the ALU comes from the reigster file 

   input logic 				Carry_In, 		  //Carry_In 
   input aluop_t			Opcode, 		  //operation 
   output logic [ALU_OUTPUT_WIDTH-1:0]  ALU_Out,	          //ALU Result 
   output logic 			Carry_Out, 		  //ALU Carry Out

   //system-wide signals 
    input logic 			Clock 			  //system clock 
); 

    //interal signals to connect the register file to the ALU
    logic [REGFILE_WIDTH-1:0] Data_Out_1, Data_Out_2;  //read port outputs from register file 
	
    //instantiate the register file
    register_file REG
(
	
	.Data_Out_1(Data_Out_1),
	.Data_Out_2(Data_Out_2),
	.Read_Addr_1(Read_Addr_1),
	.Read_Addr_2(Read_Addr_2),
	.Write_Addr(Write_Addr),
	.Write_enable(Write_enable),
	.Data_In(Write_data),	//Connect Write_data to Data_In on register file, as shown in block diagram
	.Clock(Clock)
); 

      //instantiate the alu device
	alu ALU_INST
(

	.Carry_In(Carry_In), 
	.Carry_Out(Carry_Out), 
	.ALU_Out(ALU_Out), 
	.Opcode(Opcode),
	.A_In(Data_Out_1), //connect Data_Out_1 from register file to A_In on ALU. The Data_Out_1 on register file is connected to A_In on ALU as shwon in block diagram
	.B_In(Data_Out_2)  //connect Data_Out_2 from register file to B_In on ALU. The Data_Out_2 on register file is connected to B_In on ALU as shwon in block diagram
); 


endmodule: alu_regfile		