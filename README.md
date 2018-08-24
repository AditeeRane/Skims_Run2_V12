# Skims_Run2_V12

NtupleVariables.h : Save only those branches to be kept in skims

SkimmingSR.cc : Has additional cuts to be used for skimming. Produces output skimmed file.

Interactively run as:
./skimmingSR smallrunList.txt ouFile.root TTJets_SingleLeptFromTbar

mkdir TauHad2Multiple
Submitting condor jobs as:

./GetSkimTTbar.sh 0 Aug23 ; 
Output files will be saved in TauHad2Multiple. One file for each of the background sample category.
