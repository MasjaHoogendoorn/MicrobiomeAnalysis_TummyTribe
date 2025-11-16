#!/bin/bash
#SBATCH --job-name=qiime-train-silva
#SBATCH --output=logs/qiime-train-%j.out
#SBATCH --error=logs/qiime-train-%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=12500M   # 8 CPUs × 12.5 GB = 100 GB total

# === SETUP ===
# Load conda and activate your QIIME2 environment
source ~/.bashrc
conda activate qiime2-moshpit-2025.7

# Define directories
project_dir=~/project_tummy_tribe
raw_data_dir=$project_dir/raw_data
processed_data_dir=$project_dir/processed_data

# Make sure output and logs folders exist
mkdir -p $processed_data_dir
mkdir -p logs

# === FULL TRAINING RUN ===
echo "Starting full Naive Bayes training on SILVA reference set..."
date

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads  $raw_data_dir/silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
  --i-reference-taxonomy $raw_data_dir/silva-138.2-ssu-nr99-tax-derep-uniq.qza \
  --p-classify--chunk-size 10 \
  --o-classifier $processed_data_dir/silva-138.2-ssu-nr99-classifier.qza

# === CHECK SUCCESS ===
if [ $? -eq 0 ]; then
    echo "Classifier training finished successfully."
else
    echo "Command failed — most likely due to insufficient memory."
fi

date
