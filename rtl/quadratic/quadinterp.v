////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	quadinterp.v
//
// Project:	Example Interpolators
//
// Purpose:	This file describes the implementation of one of three quadratic
//		upsamplers: 1) A quadratic fit, 2) a better quadratic filter,
//	3) an actual quadratic interpolator.
//
//	The quadratic fit just fits a quadratic to every set of three points,
//	and then uses this quadratic interpolate from halfway between the
//	first two points to halfway between the last two.  This may be the
//	standard means of using quadratic interpolation, but the result it
//	produces is quite discontinuous.
//
//	Two *MUCH* better quadratics are not included here, but both have a much
//	better response.  It is likely these will be included in this file over
//	time--given sufficient interest.
//
//
// Parameters:
//
//	INW		The number of bits at the input
//	OWID		The number of bits at the output
//	MP 		The number of bits from the counter used in the multiply
//	CTRBITS		The number of bits used to keep track of the internal
//		resampling timer.
//
// Inputs:
//
//	i_clk	Your system clock
//
//	i_ce	A logic strobe.  True whenever there is a new input sample
//		on i_data.  There must be enough clocks between i_ce values
//		to output all of the o_data values.
//
//	i_step	This controls the outgoing sample rate.  Set this value to
//		2^N * (incoming sample rate / outgoing sample rate), where
//		"N" is given by the CTRBITS parameter.
//
//	i_data	The input sample.  This value need only valid any time i_ce
//		is also true.  It will be ignored on any other clock(s).
//
// Outputs:
//
//	o_ce	A logic strobe similar to i_ce, but true once for every valid
//		output.
//
//		This implementation of a linear interpolator does nothing to
//		space o_ce values out.  Hence, if you are upsampling a 1/4 rate
//		signal to 1/2 rate, the inputs: 0, x, x, x, 1, x, x, x, 2, x,etc
//		will produce outputs: 0,1,x,x, 2,3,x,x, 4,5,x,x, etc.
//
//	o_data	The output sample, produced by linear interpolation within
//		this core.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
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
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype none
//
//
module	quadinterp(i_clk, i_ce, i_step, i_data, o_ce, o_data);
	parameter	INW   = 25,	// Input width
			OWID  = INW,	// Output width
			MP    = 25,	// Multiply precision
			CTRBITS = 32;	// Bits in our counter
	// This core only supports upsampling
	// parameter [0:0]	UPSAMPLE = 1'b1;
	//
	input	wire			i_clk;
	input	wire			i_ce;
	input	wire	[(INW-1):0]	i_data;
	input	wire	[(CTRBITS-1):0]	i_step;
	output	wire			o_ce;
	output	wire	[(OWID-1):0]	o_data;

			// Bit-Width's of the quadratic, linear, and constant
			// coefficients
	localparam	AW = INW+2, BW = INW+1, CW = INW,
			ADEC=1, BDEC=1, CDEC=0;

	// Good quadratic interpolation is done around a given point, not
	// between points.  (i.e., the offset will be between +/- 1/2, not
	// between [0..1])  As a result, we'll need to switch coefficients
	// midway through the interval.  So ... keep track of both the current
	// and old coefficients for that purpose.
	reg	[(AW-1):0]	av, avold;
	reg	[(BW-1):0]	bv, bvold;
	reg	[(CW-1):0]	cv, cvold;


	reg	signed	[(INW-1):0]	mem	[0:1];

	initial	mem[0] = 0;
	initial	mem[1] = 0;
	always @(posedge i_clk)
	if (i_ce)
		{ mem[1], mem[0] } <= { mem[0], i_data };


	reg	[INW:0]		psum, pdif;

	initial	psum = 0;
	initial	pdif = 0;
	always @(posedge i_clk)
	if (i_ce)
	begin
		psum <= { i_data[(INW-1)], i_data } + { mem[1][(INW-1)], mem[1] };
		pdif <= { i_data[(INW-1)], i_data } - { mem[1][(INW-1)], mem[1] };
	end

	initial	av = 0;
	initial	bv = 0;
	always @(posedge i_clk)
	if (i_ce)
	begin
		av <= { psum[INW],psum }-{ mem[1][INW-1], mem[1], 1'b0 };
			// * 2^-ADEC
		bv <= pdif;	// * 2^-BDEC
	end

	always @(posedge i_clk)
		if (i_ce)
			cv <= mem[1]; // * 1

	initial	avold = 0;
	initial	bvold = 0;
	initial	cvold = 0;
	always @(posedge i_clk)
	if (i_ce)
	begin
		avold <= av;
		bvold <= bv;
		cvold <= cv;
	end

	reg	pre_ce;
	initial	r_counter = 0;
	initial	pre_ce = 0;
	always @(posedge i_clk)
		pre_ce <= i_ce;

	reg				r_ce, r_ovfl;
	reg	signed	[(AW-1):0]	r_av;
	reg	signed	[(BW-1):0]	r_bv;
	reg	signed	[(CW-1):0]	r_cv;
	reg	signed	[(MP-1):0]	r_offset;
	reg		[(CTRBITS-1):0]	r_counter;

	// Start with ovfl true, so that we wait for the first valid input
	initial	r_ovfl  = 1'b1;
	always @(posedge i_clk)
		if (i_ce)
			{ r_ovfl, r_counter } <= r_counter + i_step;
		else if (!r_ovfl)
			{ r_ovfl, r_counter } <= r_counter + i_step;

	//
	// Calculate when we want to do our next step.  In other words,
	// when do we want to use these r_* values
	initial	r_ce = 1'b0;
	always @(posedge i_clk)
		r_ce <= ((pre_ce)||(!r_ovfl));

	//
	// Do a bit select of our counter to get the offset which will be
	// multiplied by our slope
	reg	signed [(MP-1):0]	pre_offset;
	always @(posedge i_clk)
	if (r_ce)
		pre_offset <= r_counter[(CTRBITS-1):(CTRBITS-MP)];

	initial	r_offset = 0;
	initial	r_av = 0;
	initial	r_bv = 0;
	initial	r_cv = 0;
	always @(posedge i_clk)
		if (r_ce)
		begin
			r_offset <= { pre_offset[MP-1], pre_offset[(MP-2):0] };
			if (pre_offset[(MP-1)])
			begin
				r_av <= av;
				r_bv <= bv;
				r_cv <= cv;
			end else begin
				r_av <= avold;
				r_bv <= bvold;
				r_cv <= cvold;
			end
		end

	// Start with ovfl true, so that we wait for the first valid input
	reg	signed	[(AW+MP-1):0]	qp_quad;
	reg	signed	[(BW-1):0]	qp_bv;
	reg	signed	[(CW-1):0]	qp_cv;
	reg	signed	[(MP-1):0]	qp_offset;

	initial	qp_quad = 0;
	initial	qp_bv   = 0;
	initial	qp_cv   = 0;
	initial	qp_offset = 0;
	always @(posedge i_clk)
	if (r_ce)
	begin
		qp_quad  <= r_av * r_offset;	// * 2^(-MP-ADEC)
		qp_bv    <= r_bv;		// * 2^(-BDEC)
		qp_cv    <= r_cv;		// * 2^(-CDEC)
		qp_offset<= r_offset;		// * 2^(-MP)
	end

	localparam	BMW = ((AW-ADEC>BW-BDEC) ? (AW-ADEC+BDEC) : BW);
	// qp_quad (AW-ADEC).(MP+ADEC)
	// qb_bv   (BW-BDEC).(BDEC)
	// lw_quad (BW-BDEC).(BDEC)
	wire	signed	[(BMW-1):0] lw_quad;
	assign	lw_quad = { {(BMW-(AW+MP-(MP+ADEC-BDEC))){qp_quad[(AW+MP-1)]}},
				qp_quad[(AW+MP-1):(MP+ADEC-BDEC)] };
	reg	signed	[BMW:0]		ls_bv;
	reg	signed	[(CW-1):0]	ls_cv;
	reg	signed	[(MP-1):0]	ls_offset;

	initial	ls_bv = 0;
	initial	ls_cv = 0;
	initial	ls_offset = 0;
	always @(posedge i_clk)
	if (r_ce)
	begin
		ls_bv    <= {{(BMW+1-BW){qp_bv[BW-1]}}, qp_bv }
				+ { lw_quad[BMW-1], lw_quad };
		ls_cv    <= qp_cv;
		ls_offset<= qp_offset;
	end

	reg	signed	[(BMW+MP):0]	lp_bv;
	reg	signed	[(CW-1):0]	lp_cv;

	initial	lp_bv = 0;
	initial	lp_cv = 0;
	always @(posedge i_clk)
	if (r_ce)
	begin
		lp_bv    <= ls_bv * ls_offset;	// * 2^(-MP-BDEC)
		lp_cv    <= ls_cv;		// * 2^(-   CDEC)
	end

	localparam	CMW = ((BMW+1-BDEC>CW-CDEC) ? (BMW+1-BDEC+CDEC) : CW);
	// lp_bv (BMW+1-BDEC).(BDEC+MP)
	// lp_cv    (CW-CDEC).(CDEC)
	wire	signed	[(CMW-1):0]	wp_bv;
	assign	wp_bv = {
			//{(CMW-(BMW+1+MP-(MP+BDEC-CDEC))){lp_bv[BMW+MP]}},
				lp_bv[(BMW+MP):(MP+BDEC-CDEC)] };
	reg	signed	[CMW:0]	r_done;
	initial	r_done = 0;
	always @(posedge i_clk)
	if (r_ce)
		r_done <= { wp_bv[CMW-1], wp_bv }
				 + {{(CMW+1-CW){lp_cv[CW-1]}}, lp_cv};

	assign	o_ce = r_ce;
	assign	o_data = r_done[(CMW):(CMW+1-OWID)];

	// Make verilator -Wall happy
	// verilator lint_off UNUSED
	wire	[(AW+MP)+(BMW+1+MP)+(CMW+1)-1:0]	unused;
	assign	unused = { qp_quad, lp_bv, r_done };
	// verilator lint_on  UNUSED
endmodule
