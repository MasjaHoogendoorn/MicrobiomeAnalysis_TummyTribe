#!/bin/bash 
#SBATCH --job-name=taxonomy       # Job name
#SBATCH --output=tax_output.log   # Output file
#SBATCH --error=tax_error.log     # Error log
#SBATCH --time=24:00:00            # Adjust the time as needed
#SBATCH --mem-per-cpu=14G          # Adjust memory per CPU as needed
#SBATCH --cpus-per-task=8          # Number of CPUs per task
#SBATCH --mail-type=END,FAIL #Email to me when finished

# Initialize Conda for bash shell 
source /cluster/home/jfrank/miniconda3/etc/profile.d/conda.sh
# Activate the conda environment
conda activate microbiomes 

# Navigate to the directory for all the data
cd "/cluster/scratch/jfrank/taxonomy" || { echo "Directory not found"; exit 1; }

# 1. Download Silva reference (RNA) 
# Please do this step on the login node, otherwise it won’t give you permission to download the data
# qiime rescript get-silva-data \
#     --p-version '138.2' \
#     --p-target 'SSURef_NR99' \
#     --o-silva-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
#     --o-silva-taxonomy silva-138.2-ssu-nr99-tax.qza
# 2. Reverse transcribe the RNA into DNA
qiime rescript reverse-transcribe \
    --i-rna-sequences silva-138.2-ssu-nr99-rna-seqs.qza \
    --o-dna-sequences silva-138.2-ssu-nr99-seqs.qza
# 3. Filter out poor quality (e.g. > 4 ambiguous bases or homopolymers of length > 7)
qiime rescript cull-seqs \
    --i-sequences silva-138.2-ssu-nr99-seqs.qza \
    --o-clean-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza
# 4. Filtering sequences by length and taxonomy
qiime rescript filter-seqs-length-by-taxon \
    --i-sequences silva-138.2-ssu-nr99-seqs-cleaned.qza \
    --i-taxonomy silva-138.2-ssu-nr99-tax.qza \
    --p-labels Archaea Bacteria Eukaryota \
    --p-min-lens 900 1200 1400 \
    --o-filtered-seqs silva-138.2-ssu-nr99-seqs-filt.qza \
    --o-discarded-seqs silva-138.2-ssu-nr99-seqs-discard.qza
# 5. Dereplicate
qiime rescript dereplicate \
    --i-sequences silva-138.2-ssu-nr99-seqs-filt.qza  \
    --i-taxa silva-138.2-ssu-nr99-tax.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
    --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza
# 6. Make amplicon-region specific classifier
qiime feature-classifier extract-reads \
    --i-sequences silva-138.2-ssu-nr99-seqs-derep-uniq.qza \
    --p-f-primer GTGYCAGCMGCCGCGGTAA \
    --p-r-primer GGACTACNVGGGTWTCTAAT \
    --p-n-jobs 2 \
    --p-read-orientation 'forward' \
    --o-reads silva-138.2-ssu-nr99-seqs-515f-806r.qza
# 7. Dereplicate again (could have new replicates in the shorter regions)
qiime rescript dereplicate \
    --i-sequences silva-138.2-ssu-nr99-seqs-515f-806r.qza \
    --i-taxa silva-138.2-ssu-nr99-tax-derep-uniq.qza \
    --p-mode 'uniq' \
    --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
    --o-dereplicated-taxa  silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza
# 8. Train amplicon-region specific classifier
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
    --i-reference-taxonomy silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza \
    --o-classifier silva-138.2-ssu-nr99-515f-806r-classifier.qza
# 9.  Evaluate the classifier
qiime rescript evaluate-fit-classifier \
  --i-sequences silva-138.2-ssu-nr99-seqs-515f-806r-uniq.qza \
  --i-taxonomy silva-138.2-ssu-nr99-tax-515f-806r-derep-uniq.qza \
  --o-classifier silva-138.2-ssu-nr99-515f-806r-fit-classifier.qza \
  --o-observed-taxonomy silva-138.2-ssu-nr99-515f-806r-predicted-taxonomy.qza \
  --o-evaluation silva-138.2-ssu-nr99-515f-806r-fit-classifier-evaluation.qzv
echo "fully executed!"

