#!/bin/sh
# run this as "./GetSkimData.sh V12 Nov30"
sample=$1 # 0 control region, 1 signal region
outStr=$2

export SUBMIT_DIR=`pwd -P`

#for DataStr in HT_1200_2500 HT_600_800 HT_800_1200 HT_2500_Inf DiLept T_SingleLep Tbar_SingleLep ; do
for DataStr in MET ; do

#for DataStr in HT_1200_2500 HT_600_800 HT_800_1200 HT_2500_Inf; do
#for DataStr in HT_2500_Inf; do
#for DataStr in T_SingleLep Tbar_SingleLep; do
#for DataStr in Tbar_SingleLep; do

    export SubmitFile=submitScriptData_${DataStr}.jdl
    if [ -e ${SubmitFile} ]; then
	rm ${SubmitFile}
    fi
    let a=1
    Njobs=`ls InputFiles_Data/filelist_data_${DataStr}_${sample}_* | wc -l `
    #let njobs=Njobs - a
    njobs=`expr $Njobs - $a`

    echo number of jobs: $njobs
    mkdir -p qsub
    
    for i in `seq 0 $njobs`; do
	
	export filenum=$i
	export outStr=$outStr
	#echo $filenum
	#echo $code 
	export DataStr=$DataStr
	export Suffix=${DataStr}_$filenum
	if [ $filenum -lt 10 ]
	then
	    export ArgTwo=filelist_data_${DataStr}_${sample}_00$filenum
	    export ArgTwoB=InputFiles_Data/${ArgTwo}
	elif [ $filenum -lt 100 ]
	then
	    export ArgTwo=filelist_data_${DataStr}_${sample}_0$filenum
	    export ArgTwoB=InputFiles_Data/${ArgTwo}
	else
	    export ArgTwo=filelist_data_${DataStr}_${sample}_$filenum
	    export ArgTwoB=InputFiles_Data/${ArgTwo}
	fi
	export ArgThree=SkimData_${DataStr}
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
	    export Output_root_file=SkimData_${DataStr}_${outStr}_${i}_00.root
	    
	    
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
		    echo Transfer_Output_Files = SkimData_${DataStr}_${outStr}_${i}_00.root>> ${SubmitFile}
		#echo Transfer_Output_Files = MuJetMatchRate_Data_${DataStr}_${outStr}_${i}_00.root>> ${SubmitFile}        
		    echo transfer_output_remaps = '"'SkimData_${DataStr}_${outStr}_${i}_00.root = TauHad2Multiple/SkimData_${DataStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}

#		echo transfer_output_remaps = '"'MuJetMatchRate_Data_${DataStr}_${outStr}_${i}_00.root = TauHad2Multiple/MuJetMatchRate_Data_${DataStr}_${outStr}_${i}_00.root'"'>> ${SubmitFile}
		
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

