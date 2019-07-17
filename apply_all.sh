#!/bin/bash
# This script is used to apply a model of the super VAD to all its classes 
# for all the subsets {train, dev, test}, for all classes {KCHI, CHI, FEM, MAL, SPEECH}
# of a given corpora.
source ~/.bashrc
echo oui
if [ $# -ne 3 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <training_dir> <protocol_name> <output_dir>"
    exit
fi

TRAINING_DIR=$1
PROTOCOL=$2
OUTPUT_DIR=$3

RTTM_DIR=`echo $PROTOCOL | cut -d . -f 1`

DIR_PATH=$PWD/scripts

mkdir $OUTPUT_DIR

for SUBSET in 'train' 'development' 'test'
do
    echo "Subset: ${SUBSET^^}"
    mkdir $OUTPUT_DIR/$SUBSET
    for CLASS in `ls $TRAINING_DIR | grep "validate_[[:upper:]]" | cut -d _ -f 2`
    do
        echo "Class: ${CLASS}"
	VALIDATE_DIR=$TRAINING_DIR/validate_$CLASS
        mkdir $OUTPUT_DIR/$SUBSET/$CLASS
	
	echo "Applying the model"
        bash ${DIR_PATH}/apply.sh $VALIDATE_DIR $PROTOCOL $SUBSET tmp_output_vad_$PROTOCOL

        if [[ $? != 0 ]]; then
            echo "Command failed."
            exit
        fi

        echo "Converting .npy to .rttm"
	conda activate pyannote
        python ${DIR_PATH}/npy_to_rttm.py --val ${VALIDATE_DIR} --protocol $PROTOCOL --scores tmp_output_vad_$PROTOCOL/$RTTM_DIR

        if [[ $? != 0 ]]; then
            echo "Command failed."
            exit
        fi

        find tmp_output_vad_$PROTOCOL/$RTTM_DIR -name '*.rttm' -exec cat {} + > tmp_output_vad_$PROTOCOL/$RTTM_DIR/$CLASS/all_$CLASS.mdtm
        mv tmp_output_vad_$PROTOCOL/$RTTM_DIR/$CLASS $OUTPUT_DIR/$SUBSET/
	rm -rf tmp_output_vad_$PROTOCOL
	
	# echo "Computing the metrics ..."
        # pyannote-metrics.py detection --subset=test $PROTOCOL ${OUTPUT_DIR}/$RTTM_DIR/all.mdtm

    done
    echo "Done ${SUBSET^^}"
done
echo "Done all"
