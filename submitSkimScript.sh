#!/bin/sh

#ArgOne=$1   # 
ArgTwo=$1   # 
ArgThree=$2 # 
ArgFour=$3  # 
ArgFive=$4  # 
ArgSix=$5  # 
ArgSeven=$6 #  
ArgOne=$7

#
# first go to the submission dir, and set up the environment
#
#cd $ArgSeven 
#source /cvmfs/cms.cern.ch/cmsset_default.sh
#eval `scram runtime -sh`

#
# now go to the condor's scratch area, where we copied the contents of New_RA2b_2015
#
cd ${_CONDOR_SCRATCH_DIR} 
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
eval `scramv1 project CMSSW CMSSW_8_0_25`
cd CMSSW_8_0_25/src/
eval `scramv1 runtime -sh` # cmsenv is an alias not on the workers
echo "CMSSW: "$CMSSW_BASE
cd -  #goes back one directory; equivalent to cd ${_CONDOR_SCRATCH_DIR}
#mkdir -p TauHadMultiple
mkdir -p TauHad2Multiple
pwd
ls -l
#mkdir -p HadTauMultiple
#mkdir -p HadTau2Multiple
#make all

echo "compilation done"
ls -l
#
# run the job
#
echo $ArgOne $ArgTwo $ArgThree "." $ArgFive $ArgSix 
$ArgOne $ArgTwo $ArgFive $ArgThree

#output will be: ArgThree_ArgFive = SkimTTbar_${TTbarStr}_${outStr}_${i}_00.root
#root -l -b -q 'MakeSFs.C+("'$ArgTwo'","'$ArgThree'",".","'$ArgFive'","'$ArgSix'")'


#root -l 'MakeSFs.C+("InputFiles_TTbar/filelist_Spring15_TTJets_Tbar_SingleLep_000","TTbar",".","","0")'


#./skimmingSR InputFiles_TTbar/filelist_Spring15_TTJets_Tbar_SingleLep_000 ouFile.root TTbar_SigleLep

#Generates output file TTbar_SigleLep_ouFile.root


#./run_tauHad "InputFiles_TTbar/filelist_Spring15_TTJets_Tbar_SingleLep_000" "Tbar_SingleLep" "." "" "0"
