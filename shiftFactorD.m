% DSF=shiftFactorD(casefile) calculates load shift factor of each
% lines i w.r.t. the injection at load bus j absorbed at the slack
% bus
%
%
% Berna Bakir Batu, April 2017.
% bernabakir@gmail.com

function DSF=shiftFactorD(casefile)
	
	simNum=1;
	refdata=casefile;
	Nl=size(refdata.branch,1);
	LoadBusInd=find(refdata.bus(:,3)>0);
	Nd=size(LoadBusInd,1);
	SlackBusInd=find(refdata.bus(:,2)==3);
		
	results=runopf(refdata);
	flows_init=results.branch(:,14);
	DSF=zeros(Nl,Nd,simNum);
	shift=1;
	
	for sim=1:simNum
		for loadInd=1:Nd
			data=refdata;
			data.bus(LoadBusInd(loadInd),3)=data.bus(LoadBusInd(loadInd),3)+shift;
			data.bus(SlackBusInd,3)=data.bus(SlackBusInd,3)-shift;
			results=runopf(data);
			flows_new=results.branch(:,14);
			DSF(:,loadInd,sim)=(flows_init-flows_new)./shift;
		end
	end
	% h=HeatMap(abs(GSF),'RowLabels',(1:Nl),'ColumnLabels',refdata.gen(:,1))
end