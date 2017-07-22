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
redo = o_last + ((o_next-o_last).*o_offset)/mxv;
redo = redo / mxv;
plot(
	t,i_data/mxv,'b;Input Signal;',
	t,redo,'r;Octave results;',
	t,o_data/mxv,'g;Interpolated/Output Signal;');
axis([2501,3000,-1,1]); grid on;
title('Comparing output results to Octave calculated results');
xlabel('Output Samples');
ylabel('Units');

