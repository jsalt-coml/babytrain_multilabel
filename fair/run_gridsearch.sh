#!/usr/bin/env bash

cd ..
for dir in gridsearch_experiments/*; do
    protocol=$(basename $dir)
    protocol=${protocol%.*}
    sbatch train.sh $dir $protocol
    sbatch validate_der.sh SPEECH $dir $protocol
done