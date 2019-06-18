#!/usr/bin/env bash
#$ -j y -o /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_log.txt
#$ -e /home/lmarvin/BabyTrain_multilabel/babytrain/multilabel/validate_err.txt
#$ -M marvin.lavechin@ensimag.grenoble-inp.fr
#$ -l mem_free=10G
#$ -l ram_free=10G
#$ -l gpu=1
#$ -l "hostname=b1[12345678]*|c*"
#$ -cwd

if [ $# -le 3 ]; then
    echo "Usage :"
    echo "./validate.sh <CLASS> <experiment_dir> <protocol> <OPTIONAL protocol_train> <OPTION precision>"
    echo "<CLASS> needs to be in [KCHI, CHI, FEM, MAL, speech]"
    echo "<protocol> is the protocol on which the model will be validating"
    echo "<protocol_train> is the name of the protocol on which the model was trained (if not specified, assuming it's the same one as <protocol>)"
    echo "<precision> specifies the fixed precision for validation. If not specified, assumes 0.8"
    echo "Example :"
    echo "export EXPERIMENT_DIR=babytrain/multilabel"
    echo "sbatch validate.sh speech ${EXPERIMENT_DIR} BabyTrain.SpeakerRole.JSALT X.SpeakerRole.JSALT 0.5"
    exit
fi


CLASS=$1
experiment_dir=$2
protocol=$3
protocol_train=$4
precision=$5

# if no protocol_train given, assume the validation protocol is the same as the one used for training
if [[ ! $protocol_train ]]; then
    echo "assuming you're validating on same protocol as train..."
    protocol_train=$protocol;
fi

# if no precision, use 0.8
if [[ ! $precision ]]; then
    $precision=0.8
fi

if [[ ! $CLASS =~ ^(KCHI|CHI|FEM|MAL|speech)$ ]]; then
    echo "The first parameter must belong to [KCHI,CHI,FEM,MAL,speech]."
    exit
fi

source activate pyannote
export EXPERIMENT_DIR=$experiment_dir
export TRAIN_DIR=${EXPERIMENT_DIR}/train/${protocol_train}.train

# copy database.yml in output folder to keep trace of what was used when launching the experiment
mkdir -p $TRAIN_DIR/validate_$CLASS
cp -r $HOME/.pyannote/database.yml $TRAIN_DIR/validate_$CLASS/
pyannote-multilabel validate --gpu --precision=$precision --to=100 --every=5 $CLASS ${TRAIN_DIR} $protocol
