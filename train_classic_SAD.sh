#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/classic_sad/log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/classic_sad/err.txt
#$ -l mem_free=16G
#$ -l ram_free=16G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

EXPERIMENT_DIR=$1
PROTOCOL_NAME=$2

if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./train_classic_SAD.sh <experiment_dir> <protocol_name>"
    echo "Example : "
    echo "export EXPERIMENT_DIR=babytrain/classic_sad"
    echo "sbatch train_classic_SAD.sh ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT"
    exit
fi

echo "Began at $(date)"
export CUDA_VISIBLE_DEVICES=`free-gpu`
echo "Found GPU : $CUDA_VISIBLE_DEVICES"

source activate pyannote
pyannote-speech-detection train --gpu --to=1000 ${EXPERIMENT_DIR} ${PROTOCOL_NAME}