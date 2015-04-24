function imtight(I, crange)
% show image with tight fit
if usejava('desktop')
    s=warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

    if nargin==2
        imshow(I,crange,'border','tight','parent',gca);
    else
        imshow(I,'border','tight','parent',gca);
    end
    warning(s);
end
end