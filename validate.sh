#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_err.txt
#$ -M marvin.lavechin@ensimag.grenoble-inp.fr
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

CLASS=$1
if [[ ! $CLASS =~ ^(KCHI|CHI|FEM|MAL|speech)$ ]]; then
    echo "The first parameter must belong to [KCHI,CHI,FEM,MAL,speech]."
    exit
fi

source activate pyannote
SCRIPT_DIR=$HOME/BabyTrain_multilabel # Can't use $dirname $0 visibly (because of the way grid-engine manages scripts)
export EXPERIMENT_DIR=${SCRIPT_DIR}/babytrain/multilabel
export TRAIN_DIR=${EXPERIMENT_DIR}/train/BabyTrain.SpeakerDiarization.BB.train
pyannote-multiclass-babytrain validate $CLASS ${TRAIN_DIR} BabyTrain.SpeakerDiarization.BB
