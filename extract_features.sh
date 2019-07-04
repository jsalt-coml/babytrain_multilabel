#!/usr/bin/env bash
#$ -j y -o /home/mlavechin/BabyTrain_multilabel/log.txt
#$ -e /home/mlavechin/BabyTrain_multilabel/err.txt
#$ -l mem_free=16G
#$ -l ram_free=16G
#$ -cwd

if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./train.sh <experiment_dir> <protocol_name>"
    echo "Example : "
    echo "export EXPERIMENT_DIR=babytrain/multilabel"
    echo "sbatch train.sh ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT"
    exit
fi

export EXPERIMENT_DIR=$1
export PROTOCOL=$2

# activate conda environment
source activate pyannote
pyannote-speech-feature ${EXPERIMENT_DIR} $PROTOCOL
echo "Done"
