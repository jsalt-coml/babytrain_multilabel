#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <validate_dir> <protocol_name> <output_dir>"
    exit
fi

VALIDATE_DIR=$1
PROTOCOL=$2
OUTPUT_DIR=$3

RTTM_FOLDER=`echo $PROTOCOL | cut -d . -f 1`

DIR_PATH=$PWD/scripts

echo "Applying the model"
bash ${DIR_PATH}/apply.sh $VALIDATE_DIR $PROTOCOL $OUTPUT_DIR

if [[ $? != 0 ]]; then
    echo "Command failed."
    exit
fi

echo "Converting .npy to .rttm"
echo $VALIDATE_DIR
echo ${OUTPUT_DIR}/$RTTM_FOLDER
python ${DIR_PATH}/npy_to_rttm.py --val ${VALIDATE_DIR} --protocol $PROTOCOL --scores ${OUTPUT_DIR}/$RTTM_FOLDER

if [[ $? != 0 ]]; then
    echo "Command failed."
    exit
fi

find ${OUTPUT_DIR}/$RTTM_FOLDER -name '*.rttm' -exec cat {} + > ${OUTPUT_DIR}/$RTTM_FOLDER/all.mdtm
echo "Computing the metrics ..."
pyannote-metrics.py detection --subset=test $PROTOCOL ${OUTPUT_DIR}/$RTTM_FOLDER/all.mdtm

