function L = rgb2label(RGB)
%% RGB2LABEL converts an RGB image into labeled regions 
%
%   L = rgb2label(RGB) creates a label matrix L from an RGB image. Each
%   separate region of RGB with a distinct color is given a label index in
%   L.
%
%   See also LABEL2RGB

%   Copyright Â© 2009 Computer Vision Lab, 
%   Ã‰cole Polytechnique FÃ©dÃ©rale de Lausanne (EPFL), Switzerland.
%   All rights reserved.
%
%   Authors:    Kevin Smith         http://cvlab.epfl.ch/~ksmith/
%               Aurelien Lucchi     http://cvlab.epfl.ch/~lucchi/
%
%   This program is free software; you can redistribute it and/or modify it 
%   under the terms of the GNU General Public License version 2 (or higher) 
%   as published by the Free Software Foundation.
%                                                                     
% 	This program is distributed WITHOUT ANY WARRANTY; without even the 
%   implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
%   PURPOSE.  See the GNU General Public License for more details.

% % % L = zeros([size(RGB,1) size(RGB,2)]);
% % % colors = squeeze(RGB(1,1,:))';
% % % for r = 1:size(L,1);
% % %     for c = 1:size(L,2);
% % %         
% % %         color =  squeeze(RGB(r,c,:))';
% % % %         if any(color), color, colors, pause; end
% % %         matches = ismember(colors, color,'rows');
% % % %         matches = matches(:,1) .* matches(:,2) .* matches(:,3);
% % %         l = find(matches, 1);
% % % %         if any(color), l,matches, pause; end
% % %         if l
% % %             L(r,c) = l;
% % %         else
% % %             colors = [colors ; color]; %#ok<AGROW>
% % %             L(r,c) = size(colors,1);
% % %         end
% % %     end
% % % end

% SPEEDUP TRICK
L = zeros([size(RGB,1) size(RGB,2)]);
colors = squeeze(RGB(1,1,:))';
for r = 1:size(L,1);
    for c = 1:size(L,2);
        
%         color =  squeeze(RGB(r,c,:))';
    
        color = [RGB(r,c,1) RGB(r,c,2) RGB(r,c,3)];
%         if any(color), color, colors, pause; end
        sameAsPrev=0;
        if r>1 && c>1
            prevCol= [RGB(r,c-1,1) RGB(r,c-1,2) RGB(r,c-1,3)];
            if all(color==prevCol)
                sameAsPrev=1;
            end
            prevCol= [RGB(r-1,c,1) RGB(r-1,c,2) RGB(r-1,c,3)];
            if all(color==prevCol)
                sameAsPrev=2;
            end
            prevCol= [RGB(r-1,c-1,1) RGB(r-1,c-1,2) RGB(r-1,c-1,3)];
            if all(color==prevCol)
                sameAsPrev=3;
            end
        end
        
        
        if ~sameAsPrev
%             matches = ismember(colors, color);
%             matches = matches(:,1) .* matches(:,2) .* matches(:,3);
            matches = ismember(colors, color,'rows');
            l = find(matches, 1);
        elseif sameAsPrev==1
            l = L(r,c-1);
        elseif sameAsPrev==2
            l = L(r-1,c);
        elseif sameAsPrev==3
            l = L(r-1,c-1);
        end            
        if l
            L(r,c) = l;
        else
            colors = [colors ; color]; %#ok<AGROW>
            L(r,c) = size(colors,1);
        end
        
    end
end



% some colors may have been repeated, we must find them and give new labels
nlabels = max(L(:));
for l=1:nlabels
    CC = bwconncomp(L == l);
    if CC.NumObjects > 1
        for n=2:CC.NumObjects
            L(CC.PixelIdxList{n}) = nlabels + 1;
            nlabels = nlabels + 1;
        end
    end
end
