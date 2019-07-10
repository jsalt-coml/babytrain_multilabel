#!/usr/bin/env bash
#SBATCH --job-name=train-%j.txt
#SBATCH --output=train-%j.log
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task 10
#SBATCH --time=24:00:00

cd ..

echo "Found GPU : $CUDA_VISIBLE_DEVICES"
echo "Done"