//////////////////////////////////////////////////////////////////////////////
// alu_regfile_defs.sv - Global definitions for ALU/Register File problem
//
// Author:			Jasur Hanbaba, Roy Kravitz (roy.kravitz@pdx.edu)
// Version:			2.0
// Last modified:	01-Oct-2022
//
// Contains the global typedefs, const, enum, structs, etc. for the ALU/Register
// Files problem
/////////////////////////////////////////////////////////////////////////////
package alu_regfile_defs;

// define the register file parameters
parameter REGFILE_SIZE = 16;
parameter REGFILE_WIDTH = 8;
parameter REGFILE_ADDR_WIDTH = 4;

// define the ALU parameters
parameter ALU_INPUT_WIDTH = 8;
parameter ALU_OUTPUT_WIDTH = 8;

// define the ALU opcodes
typedef enum logic[2:0] {
	ADD_OP = 0,
	SUB_OP = 1,
	NOTA_OP = 2,
	ORAB_OP = 3,
	ANDAB_OP = 4,
	NOTAB_OP = 5,
	EXOR_OP = 6,
	EXNOR_OP = 7
} aluop_t;

endpackage: alu_regfile_defs