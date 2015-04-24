#include "mex.h"
#include <math.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {


	/* //Declarations */		
	const mxArray *isallData = prhs[0];    

	double *ISall;
	double *Xi, *Yi, *W, *H;
		
	double *res;
	
	double x1,y1,bw,bh;
	double mu,mv;
	
	int nH, nSP, F;
	
	int t, idxH, idxD;

	/* //Get matrix x */
	ISall = mxGetPr(isallData);

	Xi = mxGetPr(prhs[1]);
	Yi = mxGetPr(prhs[2]);
	W = mxGetPr(prhs[3]);
	H = mxGetPr(prhs[4]);
	
	
	// number of superpixels
	nSP = mxGetM(isallData);

	
	// number of frames
	F = mxGetM(prhs[1]);		

	// number of hypotheses
	nH = mxGetN(prhs[1]);
	
	// getM = rows, getN = cols
	
	/* Allocate memory and assign output pointer */
	plhs[0] = mxCreateDoubleMatrix(nSP,nH,mxREAL);
	res = mxGetPr(plhs[0]);	
	
	res[0] = 0;
// 	memset(res,0,nSP*nH*sizeof(double));
	
	
	for (int q=0; q<nSP; q++) {
	  t = ISall[q + 2*nSP] - 1;
	  
	  mv=ISall[q + 3*nSP]; mu=ISall[q + 4*nSP];
	  
	  for (int h=0; h<nH; h++) {	    
	    idxH = q + h*nSP;
	    res[idxH]=0;
	    	    
	    // (t,i) index
	    idxD = t + h*F;
	    
	    // target does not exist in this frame
	    if (!W[idxD])
	      continue;
	    
	     bw=W[idxD]; bh=H[idxD]; x1=Xi[idxD]-bw/2.; y1=Yi[idxD]-bh;
	    	    
	    // check if superpixel inside hypothesis
	    if (mv >= x1 && mu >= y1 && mv <= x1+bw && mu <= y1+bh) {
	      res[idxH]=1;	      
	    }
	  }
	}
	

}