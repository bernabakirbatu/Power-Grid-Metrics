% G2LSF=shiftFactorG2L(casefile) calculates generation to load shift factor
% for each lines w.r.t. the injection at a generation bus g and withdrawal
% at a load bus d.
% 
%
% Berna Bakir Batu, April 2017.
% bernabakir@gmail.com

function [G2LSF,Labels]=shiftFactorG2L(casefile)

	GSF=shiftFactorG(casefile);
	LSF=shiftFactorL(casefile);
	GenBusNo=casefile.gen(:,1);
	LoadBusNo=casefile.bus(find(casefile.bus(:,3)>0),1);

	col=1;	
	for gen=1:size(GSF,2)
		for load=1:size(LSF,2)
			Labels{col}=sprintf('G %d to L %d', GenBusNo(gen), LoadBusNo(load));
			G2LSF(:,col)=GSF(:,gen)-LSF(:,load);
			col=col+1;
		end
	end

end