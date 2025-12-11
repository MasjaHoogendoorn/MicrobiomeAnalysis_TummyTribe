#!/bin/bash 
#SBATCH --job-name=SEPP_tree       # Job name
#SBATCH --output=sepp_output.log   # Output file
#SBATCH --error=sepp_error.log     # Error log
#SBATCH --time=24:00:00            # Adjust the time as needed
#SBATCH --mem-per-cpu=14G          # Adjust memory per CPU as needed
#SBATCH --cpus-per-task=8          # Number of CPUs per task
#SBATCH --mail-type=END,FAIL #Email to me when finished

cd $SCRATCH
cd microbiomes


qiime fragment-insertion sepp \
  --i-representative-sequences dada2_rep_seq_filtered.qza \
  --i-reference-database silva-128-sepp-refs.qza \
  --p-threads 4 \
  --o-tree sepp-tree.qza \
  --o-placements sepp-tree-placements.qza \
  --verbose
