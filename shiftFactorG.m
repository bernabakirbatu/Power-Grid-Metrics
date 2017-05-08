% GSF=shiftFactorG(casefile) calculates generation shift factor of each
% lines i w.r.t. the injection at generation bus j absorbed at the slack
% bus
%
%
% Berna Bakir Batu, April 2017.
% bernabakir@gmail.com

function GSF=shiftFactorG(casefile)

	shift=1;
	refdata=casefile;
	Nl=size(refdata.branch,1);
	Ng=size(refdata.gen,1);
	SlackBusNo=refdata.bus(find(refdata.bus(:,2)==3,1),1);
	if isempty(find(refdata.gen(:,1)==SlackBusNo,1))
		SlackBusNo=refdata.gen(1,1);
		GenSlackBusInd=1;
	else
		GenSlackBusInd=find(refdata.gen(:,1)==SlackBusNo);
	end
	results=runopf(refdata);
	flows_init=results.branch(:,14);
	GSF=zeros(Nl,Ng);
	
	for genInd=1:Ng
		data=refdata;
		data.gen(genInd,2)=data.gen(genInd,2)+shift;
		data.gen(GenSlackBusInd,2)=data.gen(GenSlackBusInd,2)-shift;
		results=runopf(data);
		flows_new=results.branch(:,14);
		GSF(:,genInd)=(flows_init-flows_new)./shift;
	end
		
end