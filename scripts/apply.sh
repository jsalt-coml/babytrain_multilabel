#!/bin/bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_err.txt
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd


if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./apply.sh <validate_dir> <output_dir>"
    exit
fi

VALIDATE_DIR=$1
OUTPUT_DIR=$2

if [ ! -d ${VALIDATE_DIR} ] || [ -z "$VALIDATE_DIR" ]; then
    echo "Folder \$VALIDATE_DIR = $VALIDATE_DIR doesn't exist."
    exit
fi

if [ -d ${OUTPUT_DIR} ]; then
    echo "Folder \$OUTPUT_DIR = $OUTPUT_DIR already exists ! Please delete it."
    exit
fi

BEST_EPOCH=$(cat ${VALIDATE_DIR}/*.development/params.yml | grep -oP 'epoch: \K[0-9]{1,4}')
BEST_EPOCH=$(printf "%04d" $BEST_EPOCH)
MODEL_PATH=${VALIDATE_DIR}/../weights/${BEST_EPOCH}.pt

echo "Best model : ${BEST_EPOCH}.pt"

if [ ! -f $MODEL_PATH ]; then
    echo "Something went wrong : $MODEL_PATH can't be found"
    exit
fi

source activate pyannote
pyannote-multilabel-babytrain apply $MODEL_PATH BabyTrain.SpeakerRole.JSALT $OUTPUT_DIR

