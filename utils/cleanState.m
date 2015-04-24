function [X, Y, stateInfo]=cleanState(X, Y,stateInfo)
% remove zero-columns from state
%


noshows=~sum(X);

texist=~~sum(X);		% which columns actually contain targets?
X=X(:,texist); Y=Y(:,texist);	% keep only these
if isfield(stateInfo,'Xgp')
    stateInfo.Xgp=stateInfo.Xgp(:,texist);stateInfo.Ygp=stateInfo.Ygp(:,texist);
end
if isfield(stateInfo,'Xi')
    stateInfo.Xi=stateInfo.Xi(:,texist);stateInfo.Yi=stateInfo.Yi(:,texist);
end
if isfield(stateInfo,'W')
    stateInfo.W=stateInfo.W(:,texist);stateInfo.H=stateInfo.H(:,texist);
end


stateInfo.X=X; stateInfo.Y=Y;
% also split fragmented trajectories
[~, N]=size(X);
for i=1:N
    frags=~~stateInfo.X(:,i);
    starts=find(frags(1:end-1)==frags(2:end)-1)+1;
    ends=find(frags(1:end-1)==frags(2:end)+1);
    if frags(1), starts=[1; starts]; end
    if frags(end), ends=[ends; numel(frags)]; end
    for s=2:numel(starts)
        stateInfo.X(starts(s):ends(s),end+1)=stateInfo.X(starts(s):ends(s),i);stateInfo.X(starts(s):ends(s),i)=0;
        stateInfo.Y(starts(s):ends(s),end+1)=stateInfo.Y(starts(s):ends(s),i);stateInfo.Y(starts(s):ends(s),i)=0;
        if isfield(stateInfo,'Xi')
            stateInfo.Xi(starts(s):ends(s),end+1)=stateInfo.Xi(starts(s):ends(s),i);stateInfo.Xi(starts(s):ends(s),i)=0;
            stateInfo.Yi(starts(s):ends(s),end+1)=stateInfo.Yi(starts(s):ends(s),i);stateInfo.Yi(starts(s):ends(s),i)=0;
        end
        if isfield(stateInfo,'Xgp')
            stateInfo.Xgp(starts(s):ends(s),end+1)=stateInfo.Xgp(starts(s):ends(s),i);stateInfo.Xgp(starts(s):ends(s),i)=0;
            stateInfo.Ygp(starts(s):ends(s),end+1)=stateInfo.Ygp(starts(s):ends(s),i);stateInfo.Ygp(starts(s):ends(s),i)=0;
        end
        if isfield(stateInfo,'W')
            stateInfo.W(starts(s):ends(s),end+1)=stateInfo.W(starts(s):ends(s),i);stateInfo.W(starts(s):ends(s),i)=0;
            stateInfo.H(starts(s):ends(s),end+1)=stateInfo.H(starts(s):ends(s),i);stateInfo.H(starts(s):ends(s),i)=0;
        end
    end
end


end