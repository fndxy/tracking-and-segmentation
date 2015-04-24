#include "mex.h" 

void mexFunction( int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[] )
{
	double *mat, *s, *res;
	double sc;
	
	int cols, rows;

	if(nrhs!=2) {
		mexErrMsgTxt("Two inputs required.");
	} else if(nlhs>1) {
		mexErrMsgTxt("Too many output arguments");
	}
	plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);

	rows = mxGetM(prhs[0]);
	cols = mxGetN(prhs[0]);
	
	mat = mxGetPr(prhs[0]);
	s = mxGetPr(prhs[1]);
	sc = s[0];
	
	
	
	res = mxGetPr(plhs[0]);
	res[0] = 0.;
	
	for (int i=0; i<cols*rows; i++){
	}
	
	
	
}
