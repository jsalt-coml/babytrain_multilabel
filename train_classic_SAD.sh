#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/classic_sad/log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/classic_sad/err.txt
#$ -M marvin.lavechin@ensimag.grenoble-inp.fr
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

echo "Began at $(date)"
export CUDA_VISIBLE_DEVICES=`free-gpu`
echo "Found GPU : $CUDA_VISIBLE_DEVICES"

source activate pyannote
SCRIPT_DIR=$HOME/BabyTrain_multilabel # Can't use $dirname $0 visibly (because of the way grid-engine manages scripts)
export EXPERIMENT_DIR=${SCRIPT_DIR}/babytrain/classic_sad
pyannote-speech-detection train --gpu --to=1000 ${EXPERIMENT_DIR} BabyTrain.SpeakerDiarization.BB