%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Filename: 	lintest.m
% {{{
% Project:	Example Interpolators
%
% Purpose:	Read and process/examine/plot the outputs from the test bench.
%
% Creator:	Dan Gisselquist, Ph.D.
%		Gisselquist Technology, LLC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% }}}
% Copyright (C) 2017-2021, Gisselquist Technology, LLC
% {{{
% This program is free software (firmware): you can redistribute it and/or
% modify it under the terms of  the GNU General Public License as published
% by the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
% target there if the PDF file isn't present.)  If not, see
% <http://www.gnu.org/licenses/> for a copy.
% }}}
% License:	GPL, v3, as defined and found on www.gnu.org,
% {{{
%		http://www.gnu.org/licenses/gpl.html
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% }}}

fid = fopen('dbgfp.32t','r');
dat = fread(fid,[ 6 inf] ,'int32');
fclose(fid);

% Assign names to these values
i_data  = dat(1,:);
o_data  = dat(2,:);
o_last  = dat(3,:);
o_next  = dat(4,:);
o_slope = dat(5,:);
o_offset= dat(6,:);

% We used 28 bits for our values internal to our simulation.  We'd like to
% plot our sine wave here between +1 and -2.  Hence, we'll need to scale
% them by 1/2^27.
nbits = 28;
mxv = 2^(nbits-1);

t = ((1:length(dat))-1);

figure(1);
plot(t,i_data/mxv,'b;Input Signal;',t,o_data/mxv,'g; Output Signal;');
axis([2501,3000,-1,1]); grid on;
xlabel('Output Samples');
ylabel('Units');
title('Interpolator Output');

figure(2);
redo = o_last + ((o_next-o_last).*o_offset)/mxv/2;
redo = redo / mxv;
plot(
	t,i_data/mxv,'b;Input Signal;',
	t,redo,'r;Octave results;',
	t,o_data/mxv,'g;Interpolated/Output Signal;');
axis([2501,3000,-1,1]); grid on;
title('Comparing output results to Octave calculated results');
xlabel('Output Samples');
ylabel('Units');

