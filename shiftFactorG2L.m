% G2LSF=shiftFactorG2L(casefile) calculates generation to load shift factor
% for each lines w.r.t. the injection at a generation bus g and withdrawal
% at a load bus d.
% 
%
% Berna Bakir Batu, April 2017.
% bernabakir@gmail.com

function G2LSF=shiftFactorG2L(casefile)
	
	GSF=shiftFactorG(casefile);
	DSF=shiftFactorD(casefile);
	col=1;
	for gen=1:size(GSF,2)
		for load=1:size(DSF,2)
			G2LSF(:,col)=GSF(:,gen)-DSF(:,load);
			col=col+1;
		end
	end

end