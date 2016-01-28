Important stuff:
------------------------------------------------------------------------------------------------------------------
We provide our pre-trained DPMs (both for images and sketches) in 'Data/DPMs' folder. If the user wants to
train new DPMs for testing our method on other datasets, please refer to the DPM code for training new DPMs.

When comparing with our method, if your proposed new method does not have the functionality of detection, please use
the detected object images in the folder called 'cropped' in each category for testing. These images are obtained by
DPM detection and are exactly the same as the medium results in our framework, so it shall be a fair comparison to use them.

In the testing dataset, we use the last 3 sketches for the final testing, and the sketches are sorted by the file names' alphabetical order.


How to start:
------------------------------------------------------------------------------------------------------------------
1. Download the DPM code from: http://www.cs.berkeley.edu/~rbg/latent/
   and the RRWM code from: http://cv.snu.ac.kr/research/~RRWM/
   Store them in the Libs folder. Do the necessary compilation. And make their names consistent with the names in the code.
2. Go to 'Scripts' folder. 
   a) Run trainingScript.m to perform component alignment.
   b) Run retrievalScript.m to test on the ground truth and obtain benchmark.
   c) Run retrievalVisualizationScript.m to visualize the retrieval results.

Contact author:
------------------------------------------------------------------------------------------------------------------
Please email me through panly099@gmail.com when you have troubles using our code or find errors in the code.





 
