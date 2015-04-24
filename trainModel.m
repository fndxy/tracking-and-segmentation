function trainModel(jobname,jobid,maxexper)

%% determine paths for config, logs, etc...
addpath(genpath('./motutils/'));
format compact

settingsDir=strsplit(jobname,'-');
runname=char(settingsDir{1})
learniter=char(settingsDir{2})
jid=char(settingsDir{3}); % unused

settingsDir=[runname '-' learniter];

confdir=sprintf('config/%s',settingsDir);

jobid=str2double(jobid);
confdir

resdir=sprintf('results/%s',settingsDir);
if ~exist(resdir,'dir'), mkdir(resdir); end
resdir


resultsfile=sprintf('%s/res_%03d.mat',resdir,jobid);

% if computed alread, just load it
if exist(resultsfile,'file')
  load(resultsfile);
else

  conffile=fullfile(confdir,sprintf('%04d.ini',jobid));
  conffile

  inifile=fullfile(confdir,'0001.ini');
  inifile
  if ~exist(inifile,'file')
	  error('You must provide initial options file 0001.ini');
  end

  opt=readSTOptions(inifile);

  %% zip up logs (previous)
  if jobid==1
    prevSetting=sprintf('%s-%d',runname,str2double(learniter)-1)
    zipstr=sprintf('!sh ziplogs.sh %s',prevSetting)
    eval(zipstr);
  end


  % take care of parameters
  jobid

  rng(jobid);
  % if jobid==1, leave as is
  if jobid==1
  % otherwise, randomize and write out new ini file
  else
	  ini=IniConfig();
	  ini.ReadFile(inifile);

	  params=[];
	  % we are only interested in [Parameters]
	  sec='Parameters';
	  keys = ini.GetKeys(sec);

	  for k=1:length(keys)
	      key=char(keys{k});
	      %params = setfield(params,key,ini.GetValues(sec,key));
	      params = [params ini.GetValues(sec,key)];
	  end

	  rnmeans = params; % mean values are the starting point
	  rmvars = rnmeans ./ 10; % variance is one tenth

	  if jobid <= maxexper/2
		  params = 2*rand(1,length(params)) .* rnmeans; % uniform [0, 2*max]
	  else
		  params = abs(rnmeans + rmvars .* randn(1,length(rnmeans))); % normal sampling
	  end


	  for k=1:length(keys)
	      key=char(keys{k});
	      %params = setfield(params,key,ini.GetValues(sec,key));
	      opt = setfield(opt, key, params(k));
	  end

	  % write out new opt file
	  status = writeSTOptions(opt,conffile);
	  

	  
  end
  rng(1);

  allscensfile=fullfile(confdir,'doscens.txt');
  if ~exist(allscensfile)
	  warning('Doing the standard PETS TUD combo...');
	  dlmwrite(fullfile(confdir,'doscens.txt'),[23 25 27 71 72 42]);
  end
  allscen=dlmread(fullfile(confdir,'doscens.txt'));
  allscen

  learniter=str2double(learniter)

  mets2d=zeros(max(allscen),14);
  mets3d=zeros(max(allscen),14);
  ens=zeros(max(allscen),1);

  for scenario=allscen
	  fprintf('jobid: %d,   learn iteration %d\n',jobid,learniter);
	  scensolfile=sprintf('%s/prt_res_%03d-scen%02d.mat',resdir,jobid,scenario)

	  try
	    load(scensolfile);
	  catch err
	    fprintf('Could not load result: %s\n',err.message);
	    [metrics2d, metrics3d, energies, stateInfo]=swSegTracker(scenario,conffile);
	    save(scensolfile,'stateInfo','metrics2d','metrics3d','energies');
	  end	  

	  mets2d(scenario,:)=metrics2d;
	  mets3d(scenario,:)=metrics3d;
	  ens(scenario)=double(energies);
	  infos(scenario).stateInfo=stateInfo;

  end


    
  save(resultsfile,'opt','mets2d','mets3d','ens','infos','allscen');
  
  
  % remove temp scene files
  for scenario=allscen
    scensolfile=sprintf('%s/prt_res_%03d-scen%02d.mat',resdir,jobid,scenario)
    if exist(scensolfile,'file')
      delete(scensolfile);
    end
  end
end

% evaluate what we have so far
% bestexper=combineResultsRemote(settingsDir);
bestexper=combineResultsBenchmark(settingsDir,maxexper);

resfiles=dir(sprintf('%s/res_*.mat',resdir))
fprintf('done %d experiments\n',length(resfiles));

querystring=sprintf('qstat -t | grep %s | wc -l',settingsDir)
[rs,rjobs] = system(querystring) 
rjobs=str2double(rjobs)-1; % subtract currently running


fprintf('%d other jobs still running\n',rjobs);

rjobs = maxexper-length(resfiles);
fprintf('%d other jobs still running\n',rjobs);


% if last one, resubmit
if bestexper==1 && length(resfiles)==maxexper
	fprintf('Training Done!');
else
%   if rjobs<=0
  if length(resfiles) == maxexper
	fprintf('resubmitting ... \n');
    runname
    if isstr(learniter), learniter=str2double(learniter); end
	newSetting=sprintf('%s-%d',runname,learniter+1)	
	newConfdir=sprintf('config/%s',newSetting)
	cpstr=sprintf('!cp -R %s %s',confdir,newConfdir)
	fprintf('copy config dir\n');
	eval(cpstr);
	
	% copy relevant config into first one
	conffile=sprintf('%s/%04d.ini',confdir,bestexper)
	cpstr=sprintf('!cp %s %s/0001.ini',conffile,newConfdir)
	fprintf('copy best config file');
	eval(cpstr);
	
	% 
	submitstr=sprintf('!ssh moby \"cd research/projects/segtracking; sh submitTrain.sh %s\"',newSetting)
	fprintf('submit: %s\n',newSetting)
  	eval(submitstr);	
  else
    fprintf('waiting for other jobs to finish\n');
  end
end

