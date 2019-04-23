#!/usr/bin/env bash

SCRIPT_DIR=$HOME/BabyTrain_multilabel # Can't use $dirname $0 visibly (because of the way grid-engine manages scripts)
source activate pyannote
export EXPERIMENT_DIR=${SCRIPT_DIR}/babytrain/multilabel
echo "Asking tensorboard"
tensorboard --logdir=${EXPERIMENT_DIR}eval