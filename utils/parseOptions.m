function opt=parseOptions(inifile)
% parse configuration for segmentation-based Tracking

if ~exist(inifile,'file')
    fprintf('WARNING! Config file %s does not exist! Using default setting...\n',inifile);
    inifile='config/default2d.ini';
end


ini=IniConfig();
ini.ReadFile(inifile);

opt=[];

% General
opt=fillInOpt(opt,ini,'General');
% take care of frames vector
if isfield(opt,'ff') && isfield(opt,'lf')
    opt.frames=opt.ff:opt.lf;
    opt=rmfield(opt,'ff');opt=rmfield(opt,'lf');
end

% Main Parameters
opt=fillInOpt(opt,ini,'Parameters');

% Hypothesis Space management
opt=fillInOpt(opt,ini,'Hypothesis Space');

% Misc
opt=fillInOpt(opt,ini,'Miscellaneous');

end


function opt = fillInOpt(opt, ini, sec)
% loop through all keys in section and
% append to struct

keys = ini.GetKeys(sec);
for k=1:length(keys)
    key=char(keys{k});
    val=ini.GetValues(sec,key);
    
    % parameters are numeric
    if isstr(val) && strcmpi(sec,'Parameters')
        val=str2double(val);
    end
    opt = setfield(opt,key,val);
end

end