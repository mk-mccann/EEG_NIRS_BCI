# EEG_NIRS_BCI

This was an early attempt at a multimodal BCI using EEG, tEEG, and NIRS signals to control a robotic hand. I barely know how to program at this point, so the code is pretty bad. 

Matthew McCann
July 2015

To successfully perform offline analysis and control the robotic hand using the BCI, the following instructions must be followed. 

1) Run runEEGlab.m to preprocesses offline EEG data. Make sure the directory for the files of interest is correctly entered. Notice that subj and subjnum are both variables included in the script. These are used to allow the user to simply give the initials of the subject and the dataset number for the script to locate for preprocessing. On lines 61-68, a switch structure is used to differentiate between EEG and tEEG data. The user is asked to specify which type of data is of interest.

2) Use NIRSlab (NITRC) to preprocess NIRS data. Use the probeInfo.mat and NIRS_event_info.txt files to correctly set up and process the data. Data was bandpass filtered between 0.01 and 0.2 Hz, and all processed channels were exported.

3) Check EEG_setup.m, NIRS_setup.m, and make_classifier.m for channel elimination. Follow the instructions in the comments.

5) Run EEG_NIRS_class.m. Make sure to set the direct variable to the correct directory. The user will be asked to load specific tEEG and EEG files. Simply entering the filename is sufficient. This program will export the classifier matrix.

6) Connect the hand to the serial port, power on, and run EEG_NIRX_learn.m. This script only asks the user for a subject, loads the relevant classifier matrix (training data), removes a random 15% for testing, and classifies the test data based on the training data.
