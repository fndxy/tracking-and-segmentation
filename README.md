Joint Tracking and Segmentation of Multiple Targets
===================================================

This is a framework for tracking and segmenting multiple targets.
This work is described in the following CVPR 2015 paper [(pdf)](http://www.milanton.de/files/cvpr2015/cvpr2015-anton.pdf)


    Joint Tracking and Segmentation of Multiple Targets
    A. Milan, L. Leal-Taixe, K. Schindler and I. Reid 


Installation
==============

This section describes how to get segTracking running on linux.

Get the latest version of the code and cd into that directory

    hg clone https://bitbucket.org/amilan/segtracking
    cd segtracking
    

Start Matlab and run

	installSegTracker;
    
        
Running
=======

	
Now all should be set up. You can start the tracker with.

    stateInfo = swSegTracker('scene','config/scene.ini','params','config/params.ini');
    

The first run will take some time because certain auxiliary structures
need to be recomputed. Subsequent calls will be much faster.

Note that both discrete inference 
and continuous minimization may lead to slightly different final results, depending on the current 
software environment and hardware architecture.
    
    
    
Other videos
------------

To run the tracker on other videos, adjust the necessary settings in a scene file in 

    scene.ini
    
Parameters can be set in

    params.ini

	
Please do not forget to cite our work if you end up using this code:


    @inproceedings{Milan:2015:CVPR,
	Author = {Anton Milan and Laura Leal-Taixé and Konrad Schindler and Ian Reid},
	Booktitle = {CVPR},
	Title = {Joint Tracking and Segmentation of Multiple Targets},
	Year = {2015}
    }