function printMessage(L,F,varargin)
% print a formatted string as F with values from varargin and debug level L


global glopt

if ~isfield(glopt,'verbosity'), glopt.verbosity=3; end

if L<=glopt.verbosity
    fprintf(F,varargin{:});
end
end