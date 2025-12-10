#!/bin/bash 
#SBATCH --job-name=taxonomy       # Job name
#SBATCH --output=tax_output.log   # Output file
#SBATCH --error=tax_error.log     # Error log
#SBATCH --time=24:00:00            # Adjust the time as needed
#SBATCH --mem-per-cpu=14G          # Adjust memory per CPU as needed
#SBATCH --cpus-per-task=8          # Number of CPUs per task
#SBATCH --mail-type=END,FAIL #Email to me when finished

cd $SCRATCH

# paths 
data_dir=/lnieba/microbiomes

qiime fragment-insertion sepp \
  --i-representative-sequences $data_dir/dada2_rep_seq_filtered.qza \
  --i-reference-database $data_dir/silva-128-sepp-refs.qza \
  --p-threads 4 \
  --o-tree $data_dir/sepp-tree.qza \
  --o-placements $data_dir/sepp-tree-placements.qza \
  --verbose
