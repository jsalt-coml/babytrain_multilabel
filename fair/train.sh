#!/bin/bash
#SBATCH --job-name=train-%j.txt
#SBATCH --output=train-%j.log
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task 10
#SBATCH --time=24:00:00

cd ..

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

echo "Began at $(date)"
echo "Found GPU : $CUDA_VISIBLE_DEVICES"

export EXPERIMENT_DIR=$experiment_dir

# activate conda environment
source activate pyannote

# copy database.yml in experiment folder to keep log of everything
mkdir -p $EXPERIMENT_DIR/train/${protocol}.train
cp -r $HOME/.pyannote/database.yml $EXPERIMENT_DIR/train/${protocol}.train
pyannote-multilabel train --gpu --to=500 ${EXPERIMENT_DIR} $protocol

echo "End at $(date)"
echo "Done"
