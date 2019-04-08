#!/usr/bin/env bash

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
