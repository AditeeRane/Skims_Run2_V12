#!/bin/sh

type=$1 # 0 control region, 1 signal region
outStr=$2

export SUBMIT_DIR=`pwd -P`

for WJetStr in 200_400 400_600 600_800 800_1200 1200_2500 2500_Inf; do
#for WJetStr in 100_200; do

#for TTbarStr in HT_1200_2500 HT_600_800 HT_800_1200 HT_2500_Inf; do
#for TTbarStr in HT_2500_Inf; do
#for TTbarStr in T_SingleLep Tbar_SingleLep; do
#for TTbarStr in Tbar_SingleLep; do

    export SubmitFile=submitScriptWJet_${WJetStr}.jdl
    if [ -e ${SubmitFile} ]; then
	rm ${SubmitFile}
    fi
    let a=1
    Njobs=`ls InputFiles_WJet_${WJetStr}/filelist_Spring15_WJet_HT_${WJetStr}_* | wc -l `
    #let njobs=Njobs - a
    njobs=`expr $Njobs - $a`

    echo number of jobs: $njobs
    mkdir -p qsub
    
    for i in `seq 0 $njobs`; do
	
	export filenum=$i
	export outStr=$outStr
	#echo $filenum
	#echo $code 
	export WJetStr=$WJetStr
	export Suffix=${WJetStr}_$filenum
	if [ $filenum -lt 10 ]
	then
	    export ArgTwo=filelist_Spring15_WJet_HT_${WJetStr}_00$filenum
	    export ArgTwoB=InputFiles_WJet_${WJetStr}/${ArgTwo}
	elif [ $filenum -lt 100 ]
	then
	    export ArgTwo=filelist_Spring15_WJet_HT_${WJetStr}_0$filenum
	    export ArgTwoB=InputFiles_WJet_${WJetStr}/${ArgTwo}
	else
	    export ArgTwo=filelist_Spring15_WJet_HT_${WJetStr}_$filenum
	    export ArgTwoB=InputFiles_WJet_${WJetStr}/${ArgTwo}
	fi
	export ArgThree=SkimWJet_${WJetStr}
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
	    export Output_root_file=SkimWJet_${WJetStr}_${outStr}_${i}_00.root
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
		    echo Transfer_Output_Files = SkimWJet_${WJetStr}_${outStr}_${i}_00.root>> ${SubmitFile}
		#echo Transfer_Output_Files = MuJetMatchRate_WJet_${WJetStr}_${outStr}_${i}_00.root>> ${SubmitFile}        
		    echo transfer_output_remaps = '"'SkimWJet_${WJetStr}_${outStr}_${i}_00.root = TauHad2Multiple/SkimWJet_${WJetStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}
		fi

#		echo transfer_output_remaps = '"'MuJetMatchRate_WJet_${WJetStr}_${outStr}_${i}_00.root = TauHad2Multiple/MuJetMatchRate_WJet_${WJetStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}
		
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

