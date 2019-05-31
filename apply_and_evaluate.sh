#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <validate_dir> <output_dir>"
    exit
fi

VALIDATE_DIR=$1
OUTPUT_DIR=$2

abort_if_fail() {
    if [[ $? = 0 ]]; then
        echo "Aborting"
        exit
    fi
}

DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/scripts

echo "Applying the model"
bash ${DIR_PATH}/apply.sh $VALIDATE_DIR $OUTPUT_DIR

abort_if_fail

echo "Converting .npy to .rttm"
python ${DIR_PATH}/npy_to_rttm.py --val ${VALIDATE_DIR} --scores ${OUTPUT_DIR}/BabyTrain
find ${OUTPUT_DIR}/BabyTrain -name '*.rttm' -exec cat {} + > ${OUTPUT_DIR}/BabyTrain/all.mdtm

abort_if_fail

echo "Computing the metrics ..."
pyannote-metrics.py detection --subset=test BabyTrain.SpeakerRole.JSALT ${OUTPUT_DIR}/BabyTrain/all.mdtm

