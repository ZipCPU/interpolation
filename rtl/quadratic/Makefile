################################################################################
##
## Filename: 	quadinterp/Makefile
##
## Project:	Example Interpolators
##
## Purpose:	To direct the making of a Verilator test program, to prove
##		the functionality of the quadratic interpolator.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Copyright (C) 2017, Gisselquist Technology, LLC
##
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of  the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
## target there if the PDF file isn't present.)  If not, see
## <http://www.gnu.org/licenses/> for a copy.
##
## License:	GPL, v3, as defined and found on www.gnu.org,
##		http://www.gnu.org/licenses/gpl.html
##
##
################################################################################
##
##
all:	test
CXX       := g++
VDIR      := obj_dir
VFLAGS    := -Wall --MMD --trace --Mdir $(VDIR) --cc
VERILATOR := verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VROOT     := $(VERILATOR_ROOT)
SUBMAKE   := $(MAKE) --no-print-directory -C
VFILES    := $(VROOT)/include/verilated.cpp $(VROOT)/include/verilated_vcd_c.cpp
CFLAGS    := -g -I$(VROOT)/include -I$(VDIR)

$(VDIR)/Vquadinterp.h: quadinterp.v
	$(VERILATOR) $(VFLAGS) quadinterp.v

$(VDIR)/Vquadinterp.cpp: $(VDIR)/Vquadinterp.h
$(VDIR)/Vquadinterp.mk: $(VDIR)/Vquadinterp.cpp

.PHONY: library
library: $(VDIR)/Vquadinterp.h $(VDIR)/Vquadinterp.cpp $(VDIR)/Vquadinterp.mk
	$(SUBMAKE) $(VDIR) -f Vquadinterp.mk

quadinterp: quadinterp.cpp library
	$(CXX) $(CFLAGS) $< $(VFILES) $(VDIR)/Vquadinterp__ALL.a -o $@

dbgfp.32t: quadinterp
	./quadinterp

.PHONY: test
test:	dbgfp.32t

.PHONY: clean
clean:
	rm -rf $(VDIR) quadinterp dbgfp.32t

