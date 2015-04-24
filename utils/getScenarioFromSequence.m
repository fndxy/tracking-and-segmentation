function sceneInfo=getScenarioFromSequence(sceneInfo)
% sequence name and ID (scenario)

if ~isfield(sceneInfo,'sequence')
    sceneInfo.sequence='unknown';
elseif isempty(sceneInfo.sequence)
    sceneInfo.sequence='unknown';
end


scenario=0;
switch (sceneInfo.sequence)
    case 'TUD-Campus'
        scenario=40;
    case 'TUD-Crossing'
        scenario=41;
    case 'TUD-Stadtmitte'
        scenario=42;        
    otherwise
        fprintf('Unknown sequence\n');
end

sceneInfo.scenario = scenario;