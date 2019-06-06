#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_err.txt
#$ -M marvin.lavechin@ensimag.grenoble-inp.fr
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

if [ $# -ne 3 ]; then
    echo "Usage :"
    echo "./apply_and_evaluate.sh <experiment_dir> <protocol_name>"
    echo "Example :"
    echo "export EXPERIMENT_DIR=babytrain/multilabel"
    echo "export TRAIN_DIR=${EXPERIMENT_DIR}/train/BabyTrain.SpeakerRole.JSALT.train"
    echo "sbatch validate.sh ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT speech"
    exit
fi

TRAIN_DIR=$1
PROTOCOL_NAME=$2
CLASS=$3

if [[ ! $CLASS =~ ^(KCHI|CHI|FEM|MAL|speech)$ ]]; then
    echo "The first parameter must belong to [KCHI,CHI,FEM,MAL,speech]."
    exit
fi

source activate pyannote
pyannote-multilabel-babytrain validate $CLASS ${TRAIN_DIR} ${PROTOCOL_NAME} --every 5 --gpu
