# Mastiff_ModelFittingTools

Hello! Welcome to MASTIFF - a tool for fitting model spectra to observed spectra

by Megan Tannock

Contact: mtannock@uwo.ca

If you make use of these codes, please cite the following two publications:
 
 Tannock M. E., et al., 2021, AJ, 161, 224
 
 Tannock M. E., et al., 2022, MNRAS, 514, 3160

The IDL Codes required for this tool are all contained in the IDLCodes/ folder. You will 
also need the IDL Astronomy User's Library which is available at this website:
https://idlastro.gsfc.nasa.gov/

You should place all of these IDL codes in your IDLWorkspace directory, and ensure they are
added to your IDL paths.

Extensive documentation on using these codes is given in the GUIDE.pdf file, as well as the 
headers of all of the .pro files in the IDLCodes/ folder.

Two sets of sample data and models are provided in the ExampleFitting1/ and ExampleFitting2/
folders. The data and models in ExampleFitting1/ are the data and models used in the
GUIDE.pdf examples.

To get started quickly, edit the UPDATEPATH text in config.txt files of ExampleFitting1/ and
ExampleFitting2/ folders, and run the fitting with the following commands in IDL, where
PATH needs to be replaced with the path where you placed these files:

IDL> FITMODELGRID_FINAL, '/PATH/ModelFittingTools/ExampleFitting1/config1.txt', /MAKEFIGURES

IDL> FITMODELGRID_FINAL, '/PATH/ModelFittingTools/ExampleFitting2/config2.txt', /MAKEFIGURES

Inside of each of the ExampleFitting1/ and ExampleFitting2/ folders there is also a
folder named OutputForASuccessfulRun/ where you can see what the outputs (data files and
figures) should look like.

If you have any problems or questions, feel free to reach out!
Thanks for using my tools!
