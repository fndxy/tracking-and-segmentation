#include "mex.h"
#include <math.h>


int min(int a, int b) {
  return (a<b ? a : b);
}

int max(int a, int b) {
  return (a>b ? a : b);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {


	/* //Declarations */
	const mxArray *frData = prhs[0];
	const mxArray *insideData = prhs[1];
	const mxArray *isallData = prhs[2];
    

	double *fr;	
	bool *insideany;
	double *ISall;
	double *Xi, *Yi, *W, *H;
	double *objMask, *Q;
	double x1,y1,bw,bh;
	double mu,mv,w;
	
	
	
	
	double tmp;
    	
	int s,e,h;
	int muR,mvR,mW,mH;
	int idxT,idxH, nH, nSP, F;
	
	int cnt;
	
	double *res;

	/* //Get matrix x */
	fr = mxGetPr(frData);
	insideany = mxGetLogicals(insideData);
	ISall = mxGetPr(isallData);

	Xi = mxGetPr(prhs[3]);
	Yi = mxGetPr(prhs[4]);
	W = mxGetPr(prhs[5]);
	H = mxGetPr(prhs[6]);
	
	objMask = mxGetPr(prhs[7]);
	Q = mxGetPr(prhs[8]);

	
	s = fr[0]-1; e=fr[1]-1;
	h = fr[2]-1; // hypothesis
	
	// number of hypotheses
	nH = mxGetN(insideData);
	
	// number of superpixels
	nSP = mxGetM(insideData);
	
	// number of frames
	F = mxGetM(prhs[3]);
	
	// mask dimension
	mH = mxGetM(prhs[7]); mW = mxGetN(prhs[7]);
	
	
	
	// getM = rows, getN = cols
//  	mexPrintf("%d %d\n",mH,mW);
	
	/* Allocate memory and assign output pointer */
	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	res = mxGetPr(plhs[0]);	
	
	res[0] = 0;
	// loop through all frames of this hypothesis
	cnt=0;
	for (int t=s; t<=e; t++) {
	  idxT = t + h*F;
	  bw=W[idxT]; bh=H[idxT]; x1=Xi[idxT]-bw/2; y1=Yi[idxT]-bh;
	  
	  for (int q=0; q<nSP; q++) {
	    idxH = q + h*nSP;
	    
	    if (insideany[idxH] && ((ISall[q + 2*nSP])==(t+1))) {
	      cnt++;  
	      
	      mu=ISall[q + 4*nSP]; mv=ISall[q + 3*nSP];
	      
	      mvR = round((mv-x1)/bw * mW);
	      muR = round((mu-y1)/bh * mH);
	      mvR = max(1,mvR); mvR = min(mW,mvR)-1;
	      muR = max(1,muR); muR = min(mH,muR)-1;
	      w=objMask[muR + mvR*mH];
	      
// 	      mexPrintf("%d %d %f %f %f %f %d %d\n",t,q,Q[q],mu,mv,w,muR,mvR);
	      
	      tmp = (w-Q[q]); tmp=tmp*tmp;
 	      res[0] += w * tmp;
	
	    }
	    
	    
	    
	  }
	  
	}
	
// 	mexPrintf("%d\n",cnt);
    

	
	
	

}