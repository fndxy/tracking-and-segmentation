function newState=fuseTracks(newState, stInfo2, matchToPrev, matchFromNext, fr1,fr2)
% one track only
% move and fuse start of next window to end of current window

[F1,N1]=size(newState.X);    [F2,N2]=size(stInfo2.X);


% fr1=F1-winolap+1:F1; fr2=1:winolap; % relative frames

% fr1
% fr2
assert(length(fr1)==length(fr2),'overlap must be equal in both windows');
winolap=length(fr1);

ex1=find(newState.X(fr1,matchToPrev));
ex2=find(stInfo2.X(fr2,matchFromNext));

% ex1
% ex2
% find frames were both targets exist
% exboth=intersect(ex1,ex2);
% winolap
% newOLState;
% now take average
for t=1:winolap
    newState=meanState(newState,stInfo2,fr1,fr2,t,matchToPrev,matchFromNext);
end

% append rest
newfr1=fr1(end)+1:fr1(end)+F2-winolap;
newfr2=fr2(end)+1:F2;
assert(length(newfr1)==length(newfr2),'overlap must be equal in both windows');
newState=appendState(newState,stInfo2,newfr1,newfr2,matchToPrev,matchFromNext);

end

function newState=meanState(newState,stInfo2,fr1,fr2,t,matchToPrev,matchFromNext)
fields={'X','Y','Xi','Yi','W','H','Xgp','Ygp'};

for f=fields
    cf=char(f);
    if isfield(newState,cf)
        
                a=0;
        s1=getfield(newState,cf); s1=s1(fr1(t),matchToPrev);
        s2=getfield(stInfo2,cf); s2=s2(fr2(t),matchFromNext);

        % if only first exists, take it
        if s1 && ~s2
             s2=s1;
            % if only second exists, take second
        elseif ~s1 && s2
            s1=s2;
            % otherwise, take both
        else
        end
        
        
        % and mean
        mv=mean([s1 s2]);
        
        
        newfield=getfield(newState,cf);
        newfield(fr1(t),matchToPrev)=mv;
        newState=setfield(newState,cf,newfield);
        
        % DEBUG STUFF
% % %         if strcmp(cf,'Xi')
% % %             [t a]
% % %             [s1';s2']
% % %             newState.Xi(fr1(t),matchToPrev)
% % %             stInfo2.Xi(fr2(t),matchFromNext)
% % %             mv
% % %             newState.Xi(:,matchToPrev)'
% % %             pause
% % %         end
        
    end
end

end

