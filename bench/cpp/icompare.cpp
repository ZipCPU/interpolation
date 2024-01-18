////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	icompare.cpp
// {{{
// Project:	Example Interpolators
//
// Purpose:	This file provides the Verilator test harness for all of the
//		interpolation functions.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2018-2024, Gisselquist Technology, LLC
// {{{
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
// }}}
// License:	GPL, v3, as defined and found on www.gnu.org,
// {{{
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
// }}}
#include <stdio.h>
#include <math.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vicomparison.h"

int	main(int argc, char **argv) {
	const	char	*DBGFNAME = "dbgout.32t";
	const	char	*SRCFNAME = "dbgsrc.32t";
	Verilated::commandArgs(argc, argv);
	Vicomparison	tb;
	// Pretend (simulate) that we're running at 100MHz
	const unsigned long	CLOCKRATE_HZ = 100000000;
	const unsigned 		CLOCKRATE_NS = 10;
	// We'll simulate a signal that is sampled every fourty clocks, and then
	// try to upample it via our linear upsampling routine
	unsigned	iclocks = 160, inow = 0;

	// We'll create a binary file of 32-bit integers, dbgfp.32t, that
	// we'll later load into Octave to find any buts.
	FILE	*dbg_fp, *src_fp;

	dbg_fp = fopen(DBGFNAME,"w");
	if (NULL == dbg_fp) {
		fprintf(stderr, "ERR: Could not open the debugging output file, \"dbgfp.32t\"\n");
		perror("O/S Err:");
		exit(EXIT_FAILURE);
	}
	src_fp = fopen(SRCFNAME,"w");
	if (NULL == dbg_fp) {
		fprintf(stderr, "ERR: Could not open the debugging output file, \"dbgfp.32t\"\n");
		perror("O/S Err:");
		exit(EXIT_FAILURE);
	}

	long	input_rate  = CLOCKRATE_HZ/iclocks;

	// Pick a chosen output rate, less than our clock rate, but
	// significantly greater than our input rate.  Why significantly? 
	// Because it makes the test results more interesting to examine
	long	output_rate = 82000000;

	assert((unsigned)output_rate < CLOCKRATE_HZ);
	assert(input_rate  < output_rate);

	// Calculate the i_step value to go into the core.
	double	dstep;
	dstep = (double)input_rate / (double)output_rate;
	// Convert this less than one value into an integer an FPGA can work
	// with.  Specifically, we're going to multiply by 2^32 here.  The
	// multiplication may be a touch harder to recognize, simply because
	// (1<<32) would overflow.  Hence, we do a touch more work here to
	// get our multiply right.
	dstep = dstep * 4.0 * (1ul<<30);
	// Once within the range of 0 ... 2^N-1, we can set the step
	// value.
	tb.i_step = (unsigned int)dstep;

	printf("STEP = %08x\n", tb.i_step);

	// Set Verilator up for capturing a trace of this waveform
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb.trace(tfp, 99);
	tfp->open("icompare.vcd");
#define	TRACE_POSEDGE	tfp->dump(CLOCKRATE_NS*clocks)
#define	TRACE_NOEDGE	tfp->dump(CLOCKRATE_NS*clocks-1)
#define	TRACE_NEGEDGE	tfp->dump(CLOCKRATE_NS*clocks+CLOCKRATE_NS/2)
#define	TRACE_CLOSE	tfp->close()

	// IBITS is the number of bits in the input.  It *MUST* match the value
	// within lininterp.v.  Here, we calculate some other helper values
	// as well.
	const unsigned	IBITS=28,
			MAXIV = ((1<<(IBITS-1))-1);


	// Clocks keeps track of how many clock ticks have passed since
	// we started
	unsigned clocks = 1;

	// dphase is the phase increment of our test sinewave.  It's really
	// represented by a phase step, rater than a frequency.  The phase
	// step is how many radians to advance on each SYSTEM clock pulse
	// (not input sample pulse).  This difference just makes things
	// easier to track later.

	// double	dphase = 1 / (double)iclocks / 24.0, dtheta = 0.0;
	double	dphase = 1 / (double)iclocks / 2.0 * 1. / 8., dtheta = 0.0,
		dslope;

	// We're goingto run this simulation for a minimum number of clocks.
	// Since iclocks is the number of clocks required to represent one
	// input sample, 16*32 specifies that we'll want to wait out 16*32
	// samples.  If, as specified above, there are 24 input samples per
	// wavelength, a value less than 32, then this will guarantee that we
	// capture at least sixteen full wavelengths of the input signal
	unsigned	MAXTICKS = 16*32*iclocks;
	double	dv, rv;

	{
		double	dlast;
		dlast = 1 / (double)iclocks / 2.0 * 9./8.;
		dslope = (dlast-dphase)/MAXTICKS;
	}

	int	vals[5];
	for(int k=0; k<5; k++)
		vals[k] = 0;

	while(clocks < MAXTICKS) {
		// Advance our understanding of "now"
		clocks++;

		// Also count off the number of clocks between the input
		// samples
		inow++;

		// As well as the phase of the simulated input sinewave
		dtheta = dtheta + dphase;
		if (dtheta > 1.0)
			dtheta -= 1.0;
		dphase += dslope;

		// Do I need to produce a new input sample to be interpolated?
		if (inow >= iclocks) {
			// YES!
			//
			// Calculate a new test sample via a sine wave
			inow = 0;
			rv = cos(2.0 * M_PI * dtheta);
			// Expand it to the maximum extent of our input bits
			dv = rv * (double)MAXIV;
			// Convert it to an input, and send it to the core.
			tb.i_data = ((int)dv)&((1ul<<IBITS)-1);
			// Tell the core there's a new value waiting for it
			tb.i_ce = 1;

			int32_t	os = (int)dv;
			fwrite(&os, 1, sizeof(os), src_fp);
		} else
			// Otherwise, there's no "new data" for the core, let
			// it keep working on the last data
			tb.i_ce = 0;

		// Toggle the clock

		// First, toggle in our changes to i_ce and i_data without
		// touching the clock
		tb.i_clk = 0;
		tb.eval();
		TRACE_NOEDGE;

		// Then toggle the clock high
		tb.i_clk = 1;
		tb.eval();
		TRACE_POSEDGE;

		// And low
		tb.i_clk = 0;
		tb.eval();
		TRACE_NEGEDGE;

		// If the core is producing an output, then let's examine
		// what went into it, and what it's calculations were.
		if (tb.o_ln_ce) {
			// Capture, from the core, the values to send to
			// our binary debugging file
			vals[0] = tb.o_nn_data;

			for(int k=0; k<5; k++) {
				// Sign extend these values first, by shifting
				// them so their sign bit is in the high bit
				// position,
				vals[k] = (int)(vals[k] <<(32- IBITS));
				// and then dropping them back down to the
				// range they were in initially.
				vals[k] >>= (32-IBITS);
			}

			// Write these to the debugging file
			fwrite(vals, sizeof(int), 5, dbg_fp);

			// Just to prove we are doing something useful, print
			// results out.  These tend to be incomprehensible to
			// me in general, but I like seeing them because they
			// convince me that something's going on.
			printf("%02x %8.2f: %08x, (%08x, %08x, %08x, %08x, %08x)\n",
				// dphase/2./M_PI*iclocks,
				((int)(dphase*iclocks*256.0))&0x0ff,
				rv, tb.i_data,
				vals[0], vals[1],
				vals[2], vals[3], vals[4]);
		} if (tb.o_ln_ce) {
			// Capture, from the core, the values to send to
			// our binary debugging file
			vals[1] = tb.o_ln_data;
		} if (tb.o_qf_ce) {
			// Capture, from the core, the values to send to
			// our binary debugging file
			vals[2] = tb.o_qf_data;
		} if (tb.o_qm_ce) {
			// Capture, from the core, the values to send to
			// our binary debugging file
			vals[3] = tb.o_qm_data;
		} if (tb.o_qi_ce) {
			// Capture, from the core, the values to send to
			// our binary debugging file
			vals[4] = tb.o_qi_data;
		}
	}

	TRACE_CLOSE;
	fclose(dbg_fp);

	printf("Simulation complete.  Output samples placed into %s\n",
		DBGFNAME);
}
