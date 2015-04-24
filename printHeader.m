function printHeader(sceneInfo,scenario,randrun)


printMessage(2,' =====================================================================\n');
printMessage(2,'|                Segmentation-based Tracking                          |\n');
printMessage(2,'|                                                                     |\n');
printMessage(2,'|       Scenario: %10d           Random Run: %15d    |\n', ...
    scenario, randrun);

if all(isfield(sceneInfo,{'dataset','sequence'}))
printMessage(2,'|       Dataset: %11s           Sequence: %17s    |\n',sceneInfo.dataset,sceneInfo.sequence);
end

printMessage(2,' =====================================================================\n\n');

end