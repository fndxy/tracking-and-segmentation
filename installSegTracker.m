%% installs all necessary dependencies
% Required:
%   - configured mex compiler
%   - internet connection

format compact;

segdir = pwd;
nerrors=0;

%%
%%%%%%%%%%%%%%%%%%
%%%% MEX Files %%%
%%%%%%%%%%%%%%%%%%
try
    fprintf('Compiling mex...');
    compileMex;
catch err
    fprintf('FAILED: Mex files could not be compiled! %s\n',err.message);
    nerrors=nerrors+1;
end
    


%%
%%%%%%%%%%%%%%%%%%
%%%% MOT Utils %%%
%%%%%%%%%%%%%%%%%%
try
    fprintf('Installing MOT Utils...');
    if ~exist('../motutils','dir')
        cd ..
        !hg clone -v https://bitbucket.org/amilan/motutils
        cd(segdir);
        fprintf('Success!\n');
    else
        fprintf('IGNORE. Already exist\n');
    end
    
catch err
    fprintf('FAILED: MOT Utils not installed! %s\n',err.message);
    nerrors=nerrors+1;
end

%%%%%%%%%%%%%%%
%%%%%% GCO %%%%
%%%%%%%%%%%%%%%
try
    fprintf('Installing GCO...');
    if ~exist(['external/GCO/matlab/bin/gco_matlab.',mexext],'file')
        cd external
        mkdir('GCO')
        cd GCO
        urlwrite('http://vision.csd.uwo.ca/code/gco-v3.0.zip','gco-v3.0.zip');
        unzip('gco-v3.0.zip');
        cd matlab
        GCO_BuildLib
        
        cd(segdir);
        fprintf('Success!\n');
    else
        fprintf('IGNORE. Already exist\n');
    end
    
catch err
    fprintf('FAILED: GCO not installed! %s\n',err.message);
    nerrors=nerrors+1;
    segdir
end

%%%%%%%%%%%%%%%%%%
%%% LIGHTSPEED %%%
%%%%%%%%%%%%%%%%%%
% This one is optional
try
    fprintf('Installing Lightspeed...');
    if ~exist('external/lightspeed','dir')
        cd external
        mkdir('lightspeed')
        cd lightspeed
        urlwrite('http://ftp.research.microsoft.com/downloads/db1653f0-1308-4b45-b358-d8e1011385a0/lightspeed.zip', ...
            'lightspeed.zip');
        unzip('lightspeed.zip');
        cd lightspeed
        install_lightspeed;
        cd(segdir);
        
        fprintf('Success!\n');
    else
        fprintf('IGNORE. Already exist\n');
    end
    
catch err
    fprintf('FAILED: Lightspeed not installed! %s\n',err.message);
    nerrors=nerrors+1;
    segdir
end



if ~nerrors
    fprintf('SegTracker installed with no errors\n');
else
    fprintf('Installation finished with %d errors. SegTracker may not work properly\n',nerrors);
end

cd(segdir)