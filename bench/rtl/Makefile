################################################################################
##
## Filename:	Makefile
## {{{
## Project:	Example Interpolators
##
## Purpose:	To direct the Verilator build of the master interpolator
##		comparison module.
##
## Targets:	The default target, all, builds the only item supported by this
##		makefile.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
## }}}
## Copyright (C) 2018-2024, Gisselquist Technology, LLC
## {{{
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of the GNU General Public License as published
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
## }}}
## License:	GPL, v3, as defined and found on www.gnu.org,
## {{{
##		http://www.gnu.org/licenses/gpl.html
##
################################################################################
##
## }}}
all:	icomparison
YYMMDD=`date +%Y%m%d`
CXX   := g++
FBDIR := .
VDIRFB:= $(FBDIR)/obj_dir
VERILATOR := verilator
VDIRS := ../../rtl/nearest-neighbor ../../rtl/lininterp ../../rtl/quadratic
VSEARCH := $(addprefix -y ,$(VDIRS))
VFLAGS := -MMD -Wall -trace $(VSEARCH) -cc

.DELETE_ON_ERROR:

.PHONY: icomparison
icomparison: $(VDIRFB)/Vicomparison__ALL.a

$(VDIRFB)/Vicomparison__ALL.a: $(VDIRFB)/Vicomparison.h $(VDIRFB)/Vicomparison.cpp
$(VDIRFB)/Vicomparison__ALL.a: $(VDIRFB)/Vicomparison.mk
$(VDIRFB)/Vicomparison.h $(VDIRFB)/Vicomparison.cpp $(VDIRFB)/Vicomparison.mk: icomparison.v

$(VDIRFB)/V%.cpp $(VDIRFB)/V%.h $(VDIRFB)/V%.mk: $(FBDIR)/%.v
	$(VERILATOR) $(VFLAGS) $*.v

$(VDIRFB)/V%__ALL.a: $(VDIRFB)/V%.mk
	cd $(VDIRFB); make -f V$*.mk

.PHONY: clean
clean:
	rm -rf $(VDIRFB)/*.mk
	rm -rf $(VDIRFB)/*.cpp
	rm -rf $(VDIRFB)/*.h
	rm -rf $(VDIRFB)/

DEPS := $(wildcard $(VDIRFB)/*.d)
ifneq ($(DEPS),)
include $(DEPS)
endif
