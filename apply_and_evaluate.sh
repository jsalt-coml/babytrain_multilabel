#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <validate_dir> <protocol_name> <output_dir>"
    exit
fi

VALIDATE_DIR=$1
PROTOCOL=$2
OUTPUT_DIR=$3

DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/scripts

echo "Applying the model"
bash ${DIR_PATH}/apply.sh $VALIDATE_DIR $PROTOCOL $OUTPUT_DIR

echo "Converting .npy to .rttm"
echo $VALIDATE_DIR
echo ${OUTPUT_DIR}/$PROTOCOL
python ${DIR_PATH}/npy_to_rttm.py --val ${VALIDATE_DIR} --protocol $PROTOCOL --scores ${OUTPUT_DIR}/$PROTOCOL
find ${OUTPUT_DIR}/$PROTOCOL -name '*.rttm' -exec cat {} + > ${OUTPUT_DIR}/$PROTOCOL/all.mdtm

echo "Computing the metrics ..."
pyannote-metrics.py detection --subset=test $PROTOCOL ${OUTPUT_DIR}/$PROTOCOL/all.mdtm

