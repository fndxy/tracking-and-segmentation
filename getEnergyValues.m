function [totEn, D, S, L, PL, Lcomp]= ...
    getEnergyValues(energy)
% retrieve individual energy components from struct

totEn = energy.value;
D = energy.data;
S = energy.smoothness;
L = energy.lC;
PL = energy.pwLC;

Lcomp=energy.labelCost;

enTol=1e-5;

assert(abs(totEn - (D+S+L+PL)) < enTol, 'energy value is wrong: %f %f %f %f %f', ...
    totEn, D, S, L, PL);
% energy
% energy.labelCost
% (hreg+hlin+hang+hper+hocc)
assert(abs(L-(sum(Lcomp))) < enTol,'label cost value is wrong: %f %f', L, sum(Lcomp));

end