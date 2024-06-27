#!/bin/bash

# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=cfd
#SBATCH --time=0:50:00
#SBATCH --exclusive
#SBATCH --nodes={{nodes}}
#SBATCH --tasks-per-node={{tasks_per_node}}
#SBATCH --cpus-per-task={{cpus_per_task}}
#SBATCH --account=tc063
#SBATCH --partition=standard
#SBATCH --qos=standard

export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

module load mpt
module load intel-20.4/compilers

cd $SLURM_SUBMIT_DIR

export OMP_NUM_THREADS={{omp_num_threads}}

srun --cpu-bind=cores ./cfd {{scale}} {{iterations}}
