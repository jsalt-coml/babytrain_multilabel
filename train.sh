#!/usr/bin/env bash

source activate pyannote
cd $SCRATCH/BabyTrain_multilabel
export EXPERIMENT_DIR=babytrain/multilabels
pyannote-multiclass-babytrain train --gpu --to=1000 ${EXPERIMENT_DIR} BabyTrain.SpeakerDiarization.BB