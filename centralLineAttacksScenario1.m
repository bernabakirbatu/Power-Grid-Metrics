function [Topo,LineIDs,disconnectedLines,OPF,Centrality]=centralLineAttacksScenario1(casefile,G)

% Start with a connected graph
% Settings and assumptions:
% Single failure type: line overload
% Single action: line disconnection
% Attacks based on centrality of lines: electrical betweenness of lines
% Test case: IEEE 118-bus test system
% Constant limits for all lines
% Capacity_of_line = Tolerance ? Load0
% Load0 = max(Loadinit_sol(l)) ~= 400, Tolerance = 1.5
% Capacity_of_line = 600

nline=size(casefile.branch,1);
CapacityMVA=casefile.branch(1,6);
k=1;
ind=1;
connected=true;
currentTopo=casefile;
LineIDs=(1:nline)';
disconnectedLines=zeros(nline,2);
PrevIsolated=[];
LastIsolated=[];

OPF(k)=runopf(currentTopo);
FlowsMVA=(OPF(k).branch(:,14).^2+OPF(k).branch(:,14).^2).^0.5;
[~,~,Tbus,Tline]=electricalBetweenness(currentTopo,1.5);
Centrality(k,:) = {Tline,Tbus};
G.line(:,2)=abs(OPF(k).branch(:,14))/max(abs(OPF(k).branch(:,14)));
G.subst(:,2)=0;
Topo(k,1)=G;
draw(G,k,1);
G.line(:,2)=Tline/max(Tline);
G.subst(:,2)=Tbus/(max(Tbus));
Topo(k,2)=G;
draw(G,k,2);

while connected
    
    if all(FlowsMVA<CapacityMVA)
        Central=find(Tline==max(Tline));
        disconnectedLines(ind,:)=[LineIDs(Central), 1];
        LineIDs(Central)=[];
        currentTopo.branch(Central,:)=[];
        G.line(Central,:)=[];
        ind=ind+1;
    else
        MaxOverload=max(FlowsMVA(FlowsMVA>CapacityMVA));
        MaxOverloadInd=find(FlowsMVA==MaxOverload);
        disconnectedLines(ind,:)=[LineIDs(MaxOverloadInd), repmat(2,length(MaxOverloadInd),1)];
        LineIDs(MaxOverloadInd)=[];
        currentTopo.branch(MaxOverloadInd,:)=[];
        G.line(MaxOverloadInd,:)=[];
        ind=ind+1;
    end
    
    [groups, isolated] = find_islands(currentTopo);
    if ~isempty(isolated)
        if size(isolated,2)==1
            LastIsolated=isolated;
            PrevIsolated=[PrevIsolated;LastIsolated];
        end
        LastIsolated = setdiff(isolated',PrevIsolated,'rows');
        PrevIsolated=[PrevIsolated;LastIsolated];
    end
    if size(groups,2)>1
        connected=false;
    elseif size(groups,2)==1 && ~isempty(LastIsolated) %balance gen and load if one is isolated
        if currentTopo.bus(LastIsolated,3)>0 || any(currentTopo.gen(:,1)==LastIsolated)
            ActiveGenInd=find(currentTopo.gen(:,1)~=LastIsolated & currentTopo.gen(:,2)>0);
            NumActiveGenerators=size(ActiveGenInd,1);
            if currentTopo.bus(LastIsolated,3)>0
                currentTopo.gen(ActiveGenInd,2)=currentTopo.gen(ActiveGenInd,2)-currentTopo.bus(LastIsolated,3)/NumActiveGenerators;
                currentTopo.bus(LastIsolated,3)=0;
            end
            if any(currentTopo.gen(:,1)==LastIsolated)
                currentTopo.gen(ActiveGenInd,2)=currentTopo.gen(ActiveGenInd,2)+currentTopo.gen(currentTopo.gen(:,1)==LastIsolated,2)/NumActiveGenerators;
                currentTopo.gen(currentTopo.gen(:,1)==LastIsolated,2)=0;
            end
        end
        k=k+1;
        OPF(k)=runopf(currentTopo);
        FlowsMVA=(OPF(k).branch(:,14).^2+OPF(k).branch(:,14).^2).^0.5;
        [~,~,Tbus,Tline]=electricalBetweenness(currentTopo,1.5);
        Centrality(k,:) = {Tline,Tbus};
        G.line(:,2)=abs(OPF(k).branch(:,14))/max(abs(OPF(k).branch(:,14)));
        G.subst(:,2)=0;
        Topo(k,1)=G;
        draw(G,k,1);
        G.line(:,2)=Tline/max(Tline);
        G.subst(:,2)=Tbus/(max(Tbus));
        Topo(k,2)=G;
        draw(G,k,2);
    else
        k=k+1;
        OPF(k)=runopf(currentTopo);
        FlowsMVA=(OPF(k).branch(:,14).^2+OPF(k).branch(:,14).^2).^0.5;
        [~,~,Tbus,Tline]=electricalBetweenness(currentTopo,1.5);
        Centrality(k,:) = {Tline,Tbus};
        G.line(:,2)=abs(OPF(k).branch(:,14))/max(abs(OPF(k).branch(:,14)));
        G.subst(:,2)=0;
        Topo(k,1)=G;
        draw(G,k,1);
        G.line(:,2)=Tline/max(Tline);
        G.subst(:,2)=Tbus/(max(Tbus));
        Topo(k,2)=G;
        draw(G,k,2);
    end
    
end

end