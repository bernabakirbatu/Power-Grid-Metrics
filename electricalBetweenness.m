% [G2LSF,C,Tbus,Tline]=electricalBetweenness(casefile,alpha) calculates 
% electrical betweenness centrality of buses and lines in a bulk power 
% system based on definitions given in [1]. The input format is Matpower
% case format.
% DEPENDENCIES: 
% 1. runopf(casefile), Matpower optimal power flow solver. 
% 2. shiftFactorG2L(casefile), function that calculates generation to load
%    shift factors. 
% INPUT: 
% 1. casefile: Matpower input case format
% 2. alpha: tolerance parameters of the network, alpha>=1
% OUTPUTS:
% 1. G2LSF: generation to load shift factor for each lines w.r.t. the 
%    injection at a generation bus g and withdrawal at a load bus d.
% 2. C: the maximum power transmission capacity which can be injected at  
%    bus g and withdrawn at bus d, while the power on each transmission 
%    line is smaller than or equal to its own line flow limit. It depends
%    physical limits of lines.
% 3. Tbus: Electrical betweenness of buses.
% 4. Tline: Electrical betweenness of lines.
%
% 
% [1] Bompard, E., Pons, E., & Wu, D. (2012). Extended topological metrics  
%     for the analysis of power grid vulnerability. IEEE Systems Journal,  
%     6(3), 481-487.
% 
%
% Berna Bakir Batu, May 2017.
% bernabakir@gmail.com

function [G2LSF,C,Tbus,Tline,OPF]=electricalBetweenness(casefile,alpha)
	
	casefile.gen=sortrows(casefile.gen,1);
	casefile.bus=sortrows(casefile.bus,1);
	[G2LSF,~]=shiftFactorG2L(casefile);
	
	% Determine line limits 
	if all(casefile.branch(:,6)==0) % unlimited or not specified
        OPF=runopf(casefile);
		MaxFlow=alpha*abs(OPF.branch(:,14)); 
	else % take limits from the input files if specified.
		if any(casefile.branch(:,6)==0)
            OPF=runopf(casefile); % bu ve bir ustteki birlestirilebilir
			MaxFlow=casefile.branch(:,6);
			MaxFlow(casefile.branch(:,6)==0,1)=alpha*abs(OPF.branch(casefile.branch(:,6)==0,14));
		else
			MaxFlow=casefile.branch(:,6);
		end
	end
	C=min(repmat(MaxFlow,1,size(G2LSF,2))./abs(G2LSF));
    
	% Determine lines connected to each bus
	Connections=zeros(size(casefile.branch,1),size(casefile.bus,1));
	for branchNo=1:size(casefile.branch,1)
		Connections(branchNo,casefile.branch(branchNo,1:2))=1;
	end
	
	% Find indexes of C and G2LSF to be included in calculation of each bus
	% betweenness and line betweenness. 
	GenBusNo=casefile.gen(:,1);
	LoadBusNo=casefile.bus(casefile.bus(:,3)>0,1);
	BusId=repmat((1:size(casefile.bus,1))',1,size(GenBusNo,1)*size(LoadBusNo,1));
	GenId=repmat(reshape(repmat(GenBusNo,1,size(LoadBusNo,1))',1,size(GenBusNo,1)*size(LoadBusNo,1)),size(casefile.bus,1),1);
	LoadId=repmat(reshape(repmat(LoadBusNo,size(GenBusNo,1),1),1,size(GenBusNo,1)*size(LoadBusNo,1)),size(casefile.bus,1),1);
	BusPairsInd=(BusId~=GenId & GenId~=LoadId & BusId~=LoadId)';
	Tbus=0.5*sum(BusPairsInd.*(repmat(C,size(casefile.bus,1),1).*(Connections'*abs(G2LSF)))');
	
	BusPairsInd2=reshape((repmat(GenBusNo,1,size(LoadBusNo,1))~=repmat(LoadBusNo',size(GenBusNo,1),1))',1,size(GenBusNo,1)*size(LoadBusNo,1));
	TlineP=sum((repmat(BusPairsInd2,size(casefile.branch,1),1) & (G2LSF>0)).*(repmat(C,size(casefile.branch,1),1).*G2LSF),2);
	TlineN=sum((repmat(BusPairsInd2,size(casefile.branch,1),1) & (G2LSF<0)).*(repmat(C,size(casefile.branch,1),1).*G2LSF),2);
	Tline=max(TlineP,abs(TlineN))';
	
end