//////////////////////////////////////////////////////////////
// tb_alu_regfile.sv - testbench for the ALU/REGFILE problem
//
// Modified by:	        Drew Seidel (dseidel@pdx.edu) 
// Version:         2.0
// Last Modified:	10/01/22
//
// Description:
// ------------
// Implements a testbench for the ALU/REGFILE problem.  Not the most exhaustive
// coverage but I tried to implement it in a way that additional tests could be added
//
// Note:    Original code created by Michael Ciletti
// Note:    Hierarchical naming (. notation) is used to "reach into" the DUT for internal values
//          This is OK for testbenches but shouldn't be done for synthesizable logic.  You may
//          need to change some of these signal names (DUT.xx) to match your internal signal names       
////////////////////////////////////////////////////////////////

import alu_regfile_defs::*;

module tb_alu_regfile;

// make use of the SystemVerilog C programming interface
// https://stackoverflow.com/questions/33394999/how-can-i-know-my-current-path-in-system-verilog
import "DPI-C" function string getenv(input string env_name);

// parameters and constants
parameter	CLK_PERIOD = 10;	// clock period is 10 time units

// declare internal variables
bit								clk = 1'b0;							// system clock
bit   [REGFILE_ADDR_WIDTH-1:0]	rd_addr_1, rd_addr_2;				// Regfile read port addresses
bit   [REGFILE_ADDR_WIDTH-1:0]	wr_addr, wr_addr_2;					// Regfile write port addresses
bit								we;									// Regfile write enable
bit	  [REGFILE_WIDTH-1:0] 		wr_data, wr_data_2;					// write data for Regfile								
bit								c_in;								// Carry in to the ALU
aluop_t							opc;								// operation for the ALU to perform

logic [ALU_OUTPUT_WIDTH-1:0] 	alu_out; 							// ALU result
logic                           carry_out;                          // Carry out from ALU

// instantiate the alu_regfile (the DUT)
alu_regfile DUT
(
	.Read_Addr_1(rd_addr_1),
	.Read_Addr_2(rd_addr_2),
	.Write_Addr(wr_addr),
	.Write_enable(we),
	.Write_data(wr_data),
	.Carry_In(c_in),
	.Opcode(opc),
	.ALU_Out(alu_out),
    .Carry_Out(carry_out),
	.Clock(clk)
);

//////////////////////////////////
// Tasks to manipulate the register file
//////////////////////////////////

// define a task to write a location in the register file
task write_regfile(bit [REGFILE_ADDR_WIDTH-1:0] write_addr, bit [REGFILE_WIDTH-1:0] write_data);
	// set up the write address and data

	we = 1'b0;
	wr_addr = write_addr;
	wr_data = write_data;		
	// perform the write operation
	// use the negedge because the regfile is clocked on the posedge
	@(negedge clk);
	we = 1'b1;
	@(negedge clk);
	we = 1'b0;
endtask: write_regfile


// define a task to display the contents of the regfile
task display_regfile;
	$strobe("Contents of the Register file are:");
	for (int i = 0; i < REGFILE_SIZE; i++) begin
		#1  // need to advance simulation time
		rd_addr_1 = i;
		$strobe("regfile[%d]: %b", rd_addr_1, DUT.Data_Out_1);
	end
	$strobe("-----------------------------------");
	#10;
endtask: display_regfile


task initialize_regfile(bit [REGFILE_WIDTH-1:0] initial_value);
	$display("initializing register file to %h", initial_value);
	for (int i = 0; i < REGFILE_SIZE; i++) begin
		#1  // need to advance simulation time
		write_regfile(i, initial_value);
	end
	$display ("register file initialization complete");
endtask: initialize_regfile
	
	
//////////////////////////////////
// Clock generator
//////////////////////////////////
always begin: clock_generator
	#(CLK_PERIOD / 2) clk = ~clk;
end: clock_generator


//////////////////////////////////
// Test vectors
//////////////////////////////////
initial begin: stimulus
    // TODO: CHANGE THE GREETING MESSAGE
    $display("Welcome to Drew Seidel's ALU/Register File Design For ECE 508 (SystemVerilog Workshop Fall 2022)"); 	
    //$display("ECE (System)Verilog workshop Fall 2022: ALU/Register file");
    $display("Sources: %s\n", getenv("PWD"));
    
	$display("Testing register file by walking a 1 through all of the locations");
	
	// initialize the opcode (avoids a warning for QuestaSim, but not used in this part of the test)
	opc = ADD_OP;
	
	// initialize the register file locations to 0
	initialize_regfile(8'h00);	
		
	// walk 1's through the regfile
    wr_data_2 = 8'h80;
	for (int k = 0; k < REGFILE_SIZE; k++) begin: regfile_test
		wr_addr_2 = k;
		if (wr_data_2 == 8'h80) begin
			wr_data_2 = 8'h01;
		end
		else begin
			wr_data_2 = wr_data_2 << 1;
		end
		
		// write the data to the regfile
		$display("Writing %b to regfile[%d]", wr_data_2, wr_addr_2);
		write_regfile(wr_addr_2, wr_data_2);
	end: regfile_test
	
	// display the contents of the register file
	$display("\nCheck functionality by manually examining the register file contents");
	display_regfile;
	
	// Test the ALU - this is rudimentary - much room for improvement
	$display("\n\nALU Test - This is rudimentary");
	
	// initialize the register file
	initialize_regfile(8'h00);
	
	// put some data in the first two register file locations
	// these are the ones we are going to supply to the ALU
	write_regfile(0, 8'h55);
	write_regfile(1, 8'hAA);
	rd_addr_1 = 0;
	rd_addr_2 = 1;
	wr_addr_2 = 4'd4;
	
	// rudimentary test of the ALU operations
    // you are encouraged to add additional test cases
    
    // test ALU functions with carry in = 0
    $display("Setting carry in to 0");
    c_in = 1'b0;
	for (int j = 0; j < 8; j++) begin: test_alu_cin0
		@(posedge clk);
		case(j)
			0: opc = ADD_OP;
			1: opc = SUB_OP;
			2: opc = NOTA_OP;
			3: opc = ORAB_OP;
			4: opc = ANDAB_OP;
			5: opc = NOTAB_OP;
			6: opc = EXOR_OP;
			7: opc = EXNOR_OP;
		endcase
		
		// display and store the result
		$strobe("operation: %12s\t A_In: %b, B_In: %b, ALU_Out: %b", opc.name,
					DUT.ALU_INST.A_In, DUT.ALU_INST.B_In, alu_out);
		#5;  // wait for the dust to settle :).  We want to move a little past posedge clk to avoid a race
		     // race condition between the register file and my write_regfile() task which is not synthesized
		wr_addr_2 += 1;
        
        // wrap the ALU results back to the register file 
		write_regfile(wr_addr_2, alu_out);
	end: test_alu_cin0
	$display("\nCheck functionality  with c_in = 0 by manually examining the register file");
	display_regfile;
    
    // repeat ALU test with carry in = 1
    $display("Setting carry in to 1");
    c_in = 1'b1;
    wr_addr_2 = 4'd4;
	for (int j = 0; j < 8; j++) begin: test_alu_cin1
		@(posedge clk);
		case(j)
			0: opc = ADD_OP;
			1: opc = SUB_OP;
			2: opc = NOTA_OP;
			3: opc = ORAB_OP;
			4: opc = ANDAB_OP;
			5: opc = NOTAB_OP;
			6: opc = EXOR_OP;
			7: opc = EXNOR_OP;
		endcase
		
		// display and store the result
		$strobe("operation: %12s\t A_In: %b, B_In: %b, ALU_Out: %b", opc.name,
					DUT.ALU_INST.A_In, DUT.ALU_INST.B_In, alu_out);
		#5;  // wait for the dust to settle :).  We want to move a little past posedge clk to avoid a race
		     // race condition between the register file and my write_regfile() task which is not synthesized
		wr_addr_2 += 1;
        
        // wrap the ALU results back to the register file 
		write_regfile(wr_addr_2, alu_out);
	end: test_alu_cin1
	$display("\nCheck functionality  with c_in = 1 by manually examining the register file");
	display_regfile;
    
    // rudimentary test of the ALU carry out functionality
    begin: test_carry_out
    	initialize_regfile(8'h00);
        // test that carry out is set to 1 when the result is to large for 8-bits
        write_regfile(12, 8'hF0);
        write_regfile(13, 8'h12);
        rd_addr_1 = 12;
        rd_addr_2 = 13;
        opc = ADD_OP;
        c_in = 1'b0;
        #5;  // wait for the dust to settle
        $strobe("ALU Operation: 0xF0 + 0x12 = 0x%X\t Carry out(expected): %b(%b)", alu_out, carry_out, 1'b1); 
        
        // test that carry out is set to 0 when the result fits in 8-bits
        write_regfile(12, 8'h80);
        write_regfile(13, 8'h12);
        opc = ADD_OP;
        #5;  // wait for the dust to settle
        $strobe("ALU Operation: 0x80 + 0x12 = 0x%X\t Carry out(expected): %b(%b)", alu_out, carry_out, 1'b0);  
    end: test_carry_out
		   
    // TODO: CHANGE THE END OF SIMULATION MESSAGE
    repeat(5)@(posedge clk);
    
    // TODO: Change the end of simulation message
    //$display("End simulation of ALU/Register file\n");	
     $display("\nThank you for joining us on this journey."); 
     $display("We hope you enjoyed your time on this flight."); 
     $display("Now terminating Drew's ALU/Register file simulation.\n"); 
    
    $stop;
end: stimulus

endmodule: tb_alu_regfile

		
		



