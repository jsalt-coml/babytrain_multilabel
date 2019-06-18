#!/bin/bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/err.txt
#$ -l mem_free=16G
#$ -l ram_free=16G
#$ -l gpu=4
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

if [ $# -ne 2 ]; then
    echo "Usage :"
    echo "./train.sh <experiment_dir> <protocol_name>"
    echo "Example : "
    echo "export EXPERIMENT_DIR=babytrain/multilabel"
    echo "sbatch train.sh ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT"
    exit
fi

experiment_dir=$1
protocol=$2

export EXPERIMENT_DIR=$experiment_dir

# activate conda environment
source activate pyannote

# copy database.yml in experiment folder to keep log of everything
mkdir -p $EXPERIMENT_DIR/train/${protocol}.train
cp -r $HOME/.pyannote/database.yml $EXPERIMENT_DIR/train/${protocol}.train
pyannote-multilabel train --gpu --to=100 ${EXPERIMENT_DIR} $protocol
