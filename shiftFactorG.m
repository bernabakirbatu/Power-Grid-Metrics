% GSF=shiftFactorG(casefile) calculates generation shift factor of each
% lines i w.r.t. the injection at generation bus j absorbed at the slack
% bus
%
%
% Berna Bakir Batu, April 2017.
% bernabakir@gmail.com

function GSF=shiftFactorG(casefile)

	simNum=1;
	refdata=casefile;
	Nl=size(refdata.branch,1);
	Nb=size(refdata.bus,1);
	Ng=size(refdata.gen,1);
	SlackBusInd=find(refdata.bus(:,2)==3);
	SlackBusNo=refdata.bus(SlackBusInd,1);
	if isempty(find(refdata.gen(:,1)==SlackBusNo))
		SlackBusNo=refdata.gen(1,1);
		SlackBusGenInd=1;
	else
		SlackBusGenInd=find(refdata.gen(:,1)==SlackBusNo);
	end
	results=runopf(refdata);
	flows_init=results.branch(:,14);
	GSF=zeros(Nl,Ng,simNum);
	shift=1;
	for sim=1:simNum
		for genInd=1:Ng
			data=refdata;
			data.gen(genInd,2)=data.gen(genInd,2)+shift;
			data.gen(SlackBusGenInd,2)=data.gen(SlackBusGenInd,2)-shift;
			results=runopf(data);
			flows_new=results.branch(:,14);
			GSF(:,genInd,sim)=(flows_init-flows_new)./shift;
		end
	end
	% h=HeatMap(abs(GSF),'RowLabels',(1:Nl),'ColumnLabels',refdata.gen(:,1))
end