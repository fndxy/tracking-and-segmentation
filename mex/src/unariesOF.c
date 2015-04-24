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
	const mxArray *isallData = prhs[0];
	const mxArray *insideData = prhs[1];
    

	double *fr;	
	bool *insideany;
	double *ISall;
	double *Xi, *Yi, *W, *H, *dX, *dY;
	double *objMask, *allnorms,*opt;
	double x1,y1,bw,bh;
	double mu,mv,vx,vy,vxh,vyh,vdiff,w;
	
	
	
	
	double tmp;
    	
	int t,h;
	int muR,mvR,mW,mH;
	int idxT,idxH, idxD, nH, nSP, F, nLabels;
	
	int cnt;
	
	double *res;

	/* //Get matrix x */
	insideany = mxGetLogicals(insideData);
	ISall = mxGetPr(isallData);

	Xi = mxGetPr(prhs[2]);
	Yi = mxGetPr(prhs[3]);
	W = mxGetPr(prhs[4]);
	H = mxGetPr(prhs[5]);
	dX = mxGetPr(prhs[6]);
	dY = mxGetPr(prhs[7]);
	
	objMask = mxGetPr(prhs[8]);
	allnorms = mxGetPr(prhs[9]);
	opt = mxGetPr(prhs[10]); // opt.ofmask, maxEn

	
	
	// number of hypotheses
	nH = mxGetN(insideData);
	nLabels = nH+1; // last one is background
	
	// number of superpixels
	nSP = mxGetM(insideData);

	// mask dimension
	mH = mxGetM(prhs[8]); mW = mxGetN(prhs[8]);
	
	// number of frames
	F = mxGetM(prhs[2]);	
	
	
	// getM = rows, getN = cols
//  	mexPrintf("%d %d\n",mH,mW);
	
	/* Allocate memory and assign output pointer */
	plhs[0] = mxCreateDoubleMatrix(nLabels,nSP,mxREAL);
	res = mxGetPr(plhs[0]);	
	
	res[0] = 0;
	// loop through all frames of this hypothesis
	cnt=0;
	for (int q=0; q<nSP; q++) {
	  
	  mu=ISall[q + 4*nSP]; mv=ISall[q + 3*nSP];
	  vx=ISall[q + 8*nSP]; vy=ISall[q + 9*nSP];
	  
	  for (int h=0; h < nH; h++) {
	    idxH = q + h*nSP;	    
	    idxD = h + q*nLabels;
	    
	    res[idxD]=opt[1];
	    
	    if (!insideany[idxH])
	      continue;
	  
	    
	    t = ISall[q + 2*nSP] - 1;
	    
	    idxT = t + h*F;
	    
	    vxh = dX[idxT];
	    vyh = dY[idxT];
	    
	    vdiff=sqrt(  ((vx-vxh)*(vx-vxh))  + ((vy-vyh)*(vy-vyh)) );
	    
	    w=1;
	    // if ofmask flag, weigh according to mask
	    if (opt[0])	    {
	      bw=W[idxT]; bh=H[idxT]; x1=Xi[idxT]-bw/2; y1=Yi[idxT]-bh;	      
// 	      mu=ISall[q + 4*nSP]; mv=ISall[q + 3*nSP];
	      
	      mvR = round((mv-x1)/bw * mW);
	      muR = round((mu-y1)/bh * mH);
	      mvR = max(1,mvR); mvR = min(mW,mvR)-1;
	      muR = max(1,muR); muR = min(mH,muR)-1;
	      w=objMask[muR + mvR*mH];	      
	    }
	    
	    
	    res[idxD] = w * vdiff;
	    

	  }
	  // background unary
	  res[nH + q*nLabels] = allnorms[q];
	}
	
// 	mexPrintf("%d\n",cnt);
    

	
	
	

}