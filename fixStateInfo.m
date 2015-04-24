function stateInfo=fixStateInfo(stateInfo, minHeight)
% remove all states with negative width / height


if nargin<2
    minHeight=0;
end

% remove states ...
rmb=find(stateInfo.W(:)<0);
rmb=[rmb; find(stateInfo.H(:)<minHeight)];

if isfield(stateInfo,'Xi')
    stateInfo.Xi(rmb)=0;stateInfo.Yi(rmb)=0;
end
if isfield(stateInfo,'Xgp')
    stateInfo.Xgp(rmb)=0;stateInfo.Ygp(rmb)=0;
end
if isfield(stateInfo,'W')
    stateInfo.W(rmb)=0;stateInfo.H(rmb)=0;
end
if isfield(stateInfo,'X')
    stateInfo.X(rmb)=0;stateInfo.Y(rmb)=0;
end





[stateInfo.X, stateInfo.Y, stateInfo]= ...
    cleanState(stateInfo.X, stateInfo.Y,stateInfo);
