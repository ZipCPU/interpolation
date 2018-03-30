################################################################################
##
## Filename: 	Makefile
##
## Project:	Example Interpolators
##
## Purpose:	To direct the Verilator build of the Verilator supported master
##		interpolator comparison executable.
##
##
## Targets:
##	all
##		Build the icomparison executable.
##	test
##		Build the executable and run the test.
##
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Copyright (C) 2018, Gisselquist Technology, LLC
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
################################################################################
##
##
CXX	:= g++
FLAGS	:= -Wall -Og -g
OBJDIR  := obj-pc
RTLD	:= ../rtl
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
INCS	:= -I$(RTLD)/obj_dir/ -I$(VROOT)/include
SOURCES := icompare.cpp
VOBJDR	:= $(RTLD)/obj_dir
SYSVDR	:= $(VROOT)/include
VSRC	:= verilated.cpp verilated_vcd_c.cpp
VLIB	:= $(addprefix $(OBJDIR)/,$(subst .cpp,.o,$(VSRC)))
# Sources necessary to build the icompare executable
CMPSRCS := icompare.cpp
CMPOBJ := $(subst .cpp,.o,$(CMPSRCS))
CMPOBJS:= $(addprefix $(OBJDIR)/,$(CMPOBJ)) $(VLIB)
all:	icompare

$(OBJDIR)/icompare.o: icompare.cpp

$(OBJDIR)/%.o: %.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/%.o: $(SYSVDR)/%.cpp
	$(mk-objdir)
	$(CXX) $(FLAGS) $(INCS) -c $< -o $@

icompare: $(CMPOBJS) $(VOBJDR)/Vicomparison__ALL.a
	$(CXX) $(FLAGS) $(INCS) $^ -o $@

test: icompare
	./icompare

#
# The "depends" target, to know what files things depend upon.  The depends
# file itself is kept in $(OBJDIR)/depends.txt
#
define	build-depends
	$(mk-objdir)
	@echo "Building dependency file"
	@$(CXX) $(CFLAGS) $(INCS) -MM $(SOURCES) > $(OBJDIR)/xdepends.txt
	@sed -e 's/^.*.o: /$(OBJDIR)\/&/' < $(OBJDIR)/xdepends.txt > $(OBJDIR)/depends.txt
	@rm $(OBJDIR)/xdepends.txt
endef

.PHONY: depends
depends: tags
	$(build-depends)

$(OBJDIR)/depends.txt: depends

#
define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef

#
# The "tags" target
#
tags:	$(SOURCES) $(HEADERS)
	@echo "Generating tags"
	@ctags $(SOURCES) $(HEADERS)

.PHONY: clean
clean:
	rm -f  ./icompare
	rm -rf $(OBJDIR)/

-include $(OBJDIR)/depends.txt
