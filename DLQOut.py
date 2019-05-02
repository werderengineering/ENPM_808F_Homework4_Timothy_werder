from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.models import load_model
import numpy as np
import sys
   

if __name__ == "__main__":

    #Load Model from Approximator
    DLQM=load_model('DLQModel.h5')

    #import the Matlab string from the terminal
    inputSAPS=str(sys.argv[1])
    
    #Evaluate the string as a numeric
    inputSAPS=eval(inputSAPS)

    #Make the numeric into an array
    inputSAPSL=np.array(inputSAPS)
    
    #Use the model from the approximator to predict the Q values given the state action pair
    Learnt = DLQM.predict(inputSAPSL)
    print(Learnt)
    
 
    


