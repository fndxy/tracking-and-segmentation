function energy=printEnergies( it, labeling, hypotheses, Dcost, Nhood, sceneInfo, opt)


global stStartTime

if opt.verbosity>=3    
    energy=evaluateEnergy(labeling, hypotheses, Dcost, Nhood, sceneInfo, opt);

    if it==0
        printMessage(3,'\n  it| time|*to|*ac|*ad|*rm||    Energy|      Data| Smooth|  Lcost| PLcost||\n');
    end

[totEn, D, S, L, PL, lc]= getEnergyValues(energy);

    N=length(hypotheses);


    printMessage(2,' %3i|%5.1f|  -|%3i|  0|  0||%10.1f|%10.1f|%7.1f|%7.1f|%7.1f||%6.1f|%6.1f|%6.1f||\n', ...
    it, toc(stStartTime)/60,N, ...
    totEn,D,S,L,PL,lc(1),lc(2),lc(3)); %%% iter output
% 

%     LOG_allens(globiter,:)=[EdetValue EdynValue EexcValue EappValue EperValue EregValue,EoriValue];
end
        
end