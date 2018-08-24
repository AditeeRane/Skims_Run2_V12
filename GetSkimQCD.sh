#!/bin/sh

type=$1 # 0 control region, 1 signal region
outStr=$2

export SUBMIT_DIR=`pwd -P`

for QCDStr in HT_200_300 HT_300_500 HT_500_700 HT_700_1000 HT_1000_1500 HT_1500_2000 HT_2000_Inf ; do

#for QCDStr in HT_1200_2500 HT_600_800 HT_800_1200 HT_2500_Inf; do
#for QCDStr in HT_2500_Inf; do
#for QCDStr in T_SingleLep Tbar_SingleLep; do
#for QCDStr in Tbar_SingleLep; do

    export SubmitFile=submitScriptQCD_${QCDStr}.jdl
    if [ -e ${SubmitFile} ]; then
	rm ${SubmitFile}
    fi
    let a=1
    Njobs=`ls InputFiles_QCD/filelist_Spring15_QCD_${QCDStr}_* | wc -l `
    #let njobs=Njobs - a
    njobs=`expr $Njobs - $a`

    echo number of jobs: $njobs
    mkdir -p qsub
    
    for i in `seq 0 $njobs`; do
	
	export filenum=$i
	export outStr=$outStr
	#echo $filenum
	#echo $code 
	export QCDStr=$QCDStr
	export Suffix=${QCDStr}_$filenum
	if [ $filenum -lt 10 ]
	then
	    export ArgTwo=filelist_Spring15_QCD_${QCDStr}_00$filenum
	    export ArgTwoB=InputFiles_QCD/${ArgTwo}
	elif [ $filenum -lt 100 ]
	then
	    export ArgTwo=filelist_Spring15_QCD_${QCDStr}_0$filenum
	    export ArgTwoB=InputFiles_QCD/${ArgTwo}
	else
	    export ArgTwo=filelist_Spring15_QCD_${QCDStr}_$filenum
	    export ArgTwoB=InputFiles_QCD/${ArgTwo}
	fi
	export ArgThree=SkimQCD_${QCDStr}
	export ArgFive=${outStr}_${i}_00.root
	export ArgSix=0
	export ArgSeven=$SUBMIT_DIR
	export Output=qsub/condor_${Suffix}.out
	export Error=qsub/condor_${Suffix}.err
	export Log=qsub/condor_${Suffix}.log
	export Proxy=\$ENV\(X509_USER_PROXY\)
	
	
	cd $SUBMIT_DIR
	source /cvmfs/cms.cern.ch/cmsset_default.sh
	eval `scram runtime -sh`
	#echo "ROOTSYS"  ${ROOTSYS}
	
	#
	# Prediction
	#
	    #echo $filenum
	    export ArgFour=TauHad2Multiple
	    export ArgOne=./skimmingSR    
	    #echo $ArgOne
	    #echo $ArgTwo
	    #echo $ArgThree
	    #echo $ArgFour
	    #echo $ArgFive
	    #echo $ArgSix
	    echo $Output
	    #echo $Error
	    #echo $Log
	    #echo $Proxy
	if [ $type -eq 0 ]; then    
	    export Output_root_file=SkimQCD_${QCDStr}_${outStr}_${i}_00.root
	fi
	    
	    
	    if [ -e TauHad2Multiple/${Output_root_file} ]; then
		echo warning !
		echo exist TauHad2Multiple/${Output_root_file}
	    else
		echo submitting TauHad2Multiple/${Output_root_file}
		
                #
                # Creating the submit .jdl file
                #
		if [ $i -eq 0 ]; then
		    echo executable = submitSkimScript.sh>> ${SubmitFile}
		    echo universe =vanilla>> ${SubmitFile}
		    echo x509userproxy = ${Proxy}>> ${SubmitFile}
		    echo notification = never>> ${SubmitFile}
		    echo should_transfer_files = YES>> ${SubmitFile}
		    echo WhenToTransferOutput = ON_EXIT>> ${SubmitFile}
		fi
		
		echo "">> ${SubmitFile}
		echo Arguments =${ArgTwo} ${ArgThree} ${ArgFour} ${ArgFive} ${ArgSix} ${ArgSeven} ${ArgOne}>> ${SubmitFile} 
		echo Output = ${Output}>> ${SubmitFile}
		echo Error = ${Error}>> ${SubmitFile}
		echo Log = ${Log}>> ${SubmitFile}
		echo Transfer_Input_Files = skimmingSR,SkimmingSR.h,SkimmingSR.cc,NtupleVariables.h,NtupleVariables.cc,${ArgTwoB}>> ${SubmitFile}
		if [ $type -eq 0 ]; then    
		    echo Transfer_Output_Files = SkimQCD_${QCDStr}_${outStr}_${i}_00.root>> ${SubmitFile}
		#echo Transfer_Output_Files = MuJetMatchRate_QCD_${QCDStr}_${outStr}_${i}_00.root>> ${SubmitFile}        
		    echo transfer_output_remaps = '"'SkimQCD_${QCDStr}_${outStr}_${i}_00.root = TauHad2Multiple/SkimQCD_${QCDStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}
		fi

#		echo transfer_output_remaps = '"'MuJetMatchRate_QCD_${QCDStr}_${outStr}_${i}_00.root = TauHad2Multiple/MuJetMatchRate_QCD_${QCDStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}
		
		echo queue>> ${SubmitFile}	
		
	    fi # if [ -e TauHad2Multiple/${Output_root_file} ]; then
	    
	

	#
	# Expectation
	#
	
	#sleep 1
	
    done
    
    #
    # Actual submission
    # 
    condor_submit ${SubmitFile}
    
done

