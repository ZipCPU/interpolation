%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Filename: 	plotem.m
%% {{{
%% Project:	Example Interpolators
%%
%% Purpose:	Converts the output data dump from icomparison.cpp into a plot
%%		made with Octave and gnuplot (or likely Matlab)
%%
%% Creator:	Dan Gisselquist, Ph.D.
%%		Gisselquist Technology, LLC
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% }}}
%% Copyright (C) 2018-2021, Gisselquist Technology, LLC
%% {{{
%% This program is free software (firmware): you can redistribute it and/or
%% modify it under the terms of  the GNU General Public License as published
%% by the Free Software Foundation, either version 3 of the License, or (at
%% your option) any later version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
%% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
%% for more details.
%%
%% You should have received a copy of the GNU General Public License along
%% with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
%% target there if the PDF file isn't present.)  If not, see
%% <http://www.gnu.org/licenses/> for a copy.
%% }}}
%% License:	GPL, v3, as defined and found on www.gnu.org,
%% {{{
%%		http://www.gnu.org/licenses/gpl.html
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% }}}
fid = fopen('dbgout.32t','r');
  dat=fread(fid, [5 inf], 'int32');
  fclose(fid);
  t = 1:length(dat(1,:));
  dat = dat / (2^28)*2;
  mxv = 1;

fid = fopen('dbgsrc.32t','r');
  src=fread(fid, inf, 'int32');
  fclose(fid);
  st = 1:length(src);
  src = src / (2^28)*2;

iclocks = 160;
input_rate = 100e6/iclocks;
output_rate = 82e6;
srate = input_rate / output_rate;

ilen = output_rate / input_rate;

figure(1);

plot(400+(st / srate)*0.99235, src, 'o;SRC;',
	t,dat(1,:),'1;NN;', ...
	t,dat(2,:),'4;LN;', ...
	t,2*dat(3,:),'3;QF;', ...
	t,2*dat(4,:),'2;RC;', ...
	t,2*dat(5,:),'5;IQ;');

axis([3470,4910,-mxv,mxv]);
grid on;

figure(2);
plot(400+(st / srate)*0.99235, src, 'o;SRC;',
	t,dat(1,:),'1;NN;', ...
	t,dat(2,:),'4;LN;', ...
	t,2*dat(3,:),'3;QF;', ...
	t,2*dat(4,:),'2;RC;', ...
	t,2*dat(5,:),'5;IQ;');

axis([31470,32350,-mxv,mxv]);
grid on;

figure(3);
plot(400+(st / srate)*0.99235, src, 'o;SRC;',
	t,dat(1,:),'1;NN;', ...
	t,dat(2,:),'4;LN;', ...
	t,2*dat(3,:),'3;QF;', ...
	t,2*dat(4,:),'2;RC;', ...
	t,2*dat(5,:),'5;IQ;');

axis([54000,57500,-mxv,mxv]);
grid on;

