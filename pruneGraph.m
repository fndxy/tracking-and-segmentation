function [Dcost,NB,strongs]=pruneGraph(Dcost,NB)
% don't bother about weak unaries
% they're likely not to be covered by any hypothesis anyway

% TODO  FIX max value
maxval=max(Dcost(:));

% if all are max value, consider weak
weaks=Dcost(1:end-1,:)==maxval;
% weaks=Dcost(1:end-1,:)==.001*maxval;

strongs=find(sum(~weaks));

if isempty(strongs)
    warning('nothing to prune?');
    return;
end


Dcost=Dcost(:,strongs);
NB=NB(strongs,:); NB=NB(:,strongs);