#!/bin/bash 
#SBATCH --job-name=functional_prediction       # Job name
#SBATCH --output=fun_output.log               # Output file
#SBATCH --error=fun_error.log                 # Error log
#SBATCH --time=12:00:00                       # Adjust the time as needed
#SBATCH --mem-per-cpu=14G                     # Adjust memory per CPU as needed
#SBATCH --cpus-per-task=8                     # Number of CPUs per task
#SBATCH --mail-type=END,FAIL                  # Email notification

# Initialize Conda for bash shell 
source /cluster/home/jfrank/miniconda3/etc/profile.d/conda.sh

# Activate the conda environment
conda activate microbiomes || { echo "Conda env not found"; exit 1; }

# Navigate to the directory with input files
cd "/cluster/scratch/jfrank/function_preds" || { echo "Directory not found"; exit 1; }

# Define output folder 
function_preds_data_dir="results"

# Check input files
for f in dna-sequences.fasta feature-table.biom; do
    if [ ! -f "$f" ]; then
        echo "Input file $f not found in current directory"
        exit 1
    fi
done

# Run PICRUSt2 using the installed executable in the conda environment
echo "Running PICRUSt2 pipeline..."
picrust2_pipeline.py \
   -s "dna-sequences.fasta" \
   -i "feature-table.biom" \
   -o "$function_preds_data_dir" \
   -p 3 \
   --placement_tool epa-ng \
   --hsp_method mp \
   --max_nsti 2 \
   --verbose || { echo "PICRUSt2 pipeline failed"; exit 1; }

echo "PICRUSt2 pipeline completed successfully!"

