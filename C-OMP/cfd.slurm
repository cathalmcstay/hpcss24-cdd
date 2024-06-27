#!/bin/bash

# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=cfd
#SBATCH --time=0:50:00
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --account=tc063
#SBATCH --partition=standard
#SBATCH --qos=standard


export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK

module load mpt
module load intel-20.4/compilers


cd $SLURM_SUBMIT_DIR


export OMP_NUM_THREADS=1


srun --cpu-bind=cores ./cfd 4 500
