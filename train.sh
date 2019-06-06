#!/bin/bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/err.txt
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <experiment_dir> <protocol_name>"
    echo "Example : "
    echo "export EXPERIMENT_DIR=babytrain/multilabel"
    echo "sbatch train.sh ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT"
    exit
fi

EXPERIMENT_DIR=$1
PROTOCOL_NAME=$2

echo "Began at $(date)"
export CUDA_VISIBLE_DEVICES=`free-gpu`
echo "Found GPU : $CUDA_VISIBLE_DEVICES"

source activate pyannote
pyannote-multilabel-babytrain train --gpu --to=1000 ${EXPERIMENT_DIR} ${PROTOCOL_NAME}