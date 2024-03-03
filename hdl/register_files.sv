//////////////////////////////////////////////////////////////
// register_file.sv - Register File for ALU/REGFILE problem
//
// Author:	        Jasur Hanbaba, Roy Kravitz (roy.kravitz@pdx.edu)
// Version:         2.0
// Last Modified:	01-Oct-2022
//
// Description:
// ------------
// Implements a parameterized register File.  The register file
// is a dual read port, single write port Register file such as 
// would be used in a RISC CPU
//
// Note:  Original code created by Michael Ciletti
////////////////////////////////////////////////////////////////

import alu_regfile_defs::*;

module register_file (
		output logic [REGFILE_WIDTH-1:0]		Data_Out_1, Data_Out_2,		// dual read port outputs from the register file
		input  logic [REGFILE_WIDTH-1:0]		Data_In,					// single write port input to the register file
		input  logic [REGFILE_ADDR_WIDTH-1:0]	Read_Addr_1, Read_Addr_2,	// read port addresses
		input  logic [REGFILE_ADDR_WIDTH-1:0]	Write_Addr,					// address to write Data_In to
		input  logic							Write_enable,				// write enable (1 to write)
		input  logic							Clock						// clock
);

// define the register file
logic [REGFILE_WIDTH-1:0]	regfile[REGFILE_SIZE];

// implement the register file logic

// update the two read ports
assign Data_Out_1 = regfile[Read_Addr_1];
assign Data_Out_2 = regfile[Read_Addr_2];

// do a write if Write_enable is asserted
always_ff @(posedge Clock) begin
	if (Write_enable == 1'b1) begin
		regfile[Write_Addr] = Data_In;
	end
end

endmodule: register_file
	