# ENPM_808F_Homework4_Timothy_werder
In order to utilize this content's Q Learner and Functional Approximator to play the game of Dots and Boxes you will need the following
1. MATLAB
2. Python3.5 or greater
3. Tensor Flow

Start by moving all attached files to a desired folder. 
Open up the Matlab file named "ENPM808F_DotBox_Timothy_Werder.m"
Run "ENPM808F_DotBox_Timothy_Werder.m" 
Enter the size of game as either [2 2] or [3 3] and press enter
Enter the number of Training Sessions
This will run until all training sessions have been completed. 
The user will then be prompted to whether they would like to use the Functional Approximator or by default the the QLearner
The game will then computer the neccesary needs to run the game and will run it for 100 games for 5 sets
This will take a while if using the Functional Approximator due to the need to write out and call to the pyuthon scripts.


Debug:
When developing this code, there was a known issue of importing Tensor Flow into the the python code
ensure that the command prompt is able to follow the path for Tensor Flow. 

For instance a path may be needed to be created by going into: 
Control Panel>System and Security>System>Advanced System Settings>Advanced>Enviornment Variables and creating a new path
