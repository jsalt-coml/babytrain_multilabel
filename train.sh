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
conda activate pyannote

# copy database.yml in experiment folder to keep log of everything
mkdir -p $EXPERIMENT_DIR/train/${protocol}.train
cp -r /home/jkaradayi/.pyannote/database.yml $EXPERIMENT_DIR/train/${protocol}.train
pyannote-multilabel-babytrain train --gpu --to=100 ${EXPERIMENT_DIR} $protocol
