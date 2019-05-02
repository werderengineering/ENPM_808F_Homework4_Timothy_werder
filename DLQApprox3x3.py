import tensorflow
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
import numpy as np
import States

#Check to see if the States imported are correct
print(States.someStateActions)

def Approximator(LStates):
   
    #Create the number of Layers used in FA
    Neurons1 = LStates 
    Neurons2 = int(Neurons1/2)
    Neurons3 = int(Neurons2/2)

    # Build the Functional Approximator using the Neuron Layers
    FA = Sequential()
    FA.add(Dense(Neurons1, input_dim=LStates, kernel_initializer="normal", activation="relu"))
    FA.add(Dense(Neurons2, kernel_initializer="normal", activation="relu"))
    FA.add(Dense(Neurons3, kernel_initializer="normal", activation="relu"))


    # Output 1 value for the Q value when called
    FA.add(Dense(1, kernel_initializer="normal"))

    # Output the Mean Squared Error as a loss function for accurancy of FA
    FA.compile(loss="mean_squared_error", optimizer='adam')
    return FA

     

if __name__ == "__main__":

    #Check if Libraries load correctly
    print("Libraries Loaded Properly")

    #Pull the State Action Pairs from the python file written by Matlab
    inputStates = States.someStateActions

    #Pull the Q Tables from the python file written by Matlab
    labels=States.someQs

    #Create the variables in python from the imports
    PredictIPS = inputStates[-1][:]
    PredictLabels = labels[-1]
   
    #Get the Length of the States
    LStates=len(inputStates[0])


    #Build the Approximator 
    FA = Approximator(LStates)
    FA.fit(inputStates, labels, epochs = 100, batch_size=len(inputStates))
 
    #Adjust the Shape so that Matlab can pull the Values
    Learnt = FA.predict(PredictIPS.reshape(49,1).T)
    
    #Output the Model and Labels to the terminal so Matlab can read it in
    print(Learnt)
    print(PredictLabels)

    #Save the Functional Approximator
    FA.save('DLQModel.h5')


