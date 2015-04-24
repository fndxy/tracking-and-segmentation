function outspline = ...
    adjustHypStruct(sfit, sstart, send,  T, lastused, sceneInfo, opt)
	% we need to append some fields to our spline struct

outspline=sfit;
outspline.start=sstart; outspline.end=send;


fr=sstart:send;
xys=ppval(sfit,fr);
bbox.Xi(fr)=xys(1,:);
bbox.Yi(fr)=xys(2,:);
bbox.H(fr)=xys(3,:);
bbox.W(fr)=xys(4,:);
outspline.bbox=bbox;

% outspline.labelCost=0;
% outspline.lcComponents=0;

% global ISallglob
% ISall=ISallglob;

% insideany=false(size(ISall,1),1);
% for t=fr    
%         %             if dd~=dett, continue; end
%         bh=bbox.H(t); bw=hyps.W(t);
%         bx=bbox.Xi(dd)-bw/2;
%         by=bbox.Yi(dd)-bh;
%         
%         insidehyp=find(ISall(:,3)==t & ...
%             ISall(:,4)>=bx & ISall(:,5)>=by & ...
%             ISall(:,4)<=bx+bw & ...
%             ISall(:,5)<=by+bh); % inside hyp box
%         insideany(insidehyp)=1;
% end
% outspline.insideany=insideany;

[outspline.labelCost, outspline.lcComponents]= ...
    getHypLabelCost2(outspline,sceneInfo,opt);
outspline.lastused=lastused;

end