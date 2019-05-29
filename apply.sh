#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_err.txt
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

usage () {
  echo "Usage :"
  echo "./apply.sh model.pt /path/to/sad"
  echo "where model.pt is the .pt file where the model has been stored"
  echo "and /path/to/sad is the path to the folder where the raw scores will be stored"
}

MODEL_VERSION=$1
OUTPUT_FOLDER=$2

if [ "$#" -ne 2 ] || [ ! -f ${TRAIN_DIR}/weights/$MODEL_VERSION ]; then
    usage
fi

SCRIPT_DIR=$HOME/Bureau/BabyTrain_multilabel # Can't use $dirname $0 visibly (because of the way grid-engine manages scripts)
export EXPERIMENT_DIR=${SCRIPT_DIR}/babytrain/multilabel
export TRAIN_DIR=${EXPERIMENT_DIR}/train/BabyTrain.SpeakerRole.JSALT.train
source activate pyannote
pyannote-multilabel-babytrain apply ${TRAIN_DIR}/weights/0060.pt BabyTrain.SpeakerRole.JSALT ${EXPERIMENT_DIR}/test_sad

