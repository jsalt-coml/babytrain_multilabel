#!/usr/bin/env bash
#SBATCH --job-name=validate-%j.txt
#SBATCH --output=validate-%j.log
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task 10
#SBATCH --time=24:00:00

cd ..

if [ $# -le 2 ]; then
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

# if no protocol_train given, assume the validation protocol is the same as the one used for training
if [[ ! $protocol_train ]]; then
    echo "assuming you're validating on same protocol as train..."
    protocol_train=$protocol;
fi

if [[ ! $CLASS =~ ^(KCHI|CHI|FEM|MAL|SPEECH)$ ]]; then
    echo "The first parameter must belong to [KCHI,CHI,FEM,MAL,SPEECH]."
    exit
fi

echo "Began at $(date)"
echo "Found GPU : $CUDA_VISIBLE_DEVICES"

source activate pyannote
export EXPERIMENT_DIR=$experiment_dir
export TRAIN_DIR=${EXPERIMENT_DIR}/train/${protocol_train}.train

pyannote-multilabel validate --parallel=2 --every=1 $CLASS ${TRAIN_DIR} $protocol --use_der

echo "End at $(date)"
echo "Done"
