#!/bin/bash

# Define the configurations
configs=(
    #Config: Node, tasks per node, CPUs per task, threads, scale, iterations
    "1 4 4 4 4 10000"
    "1 4 4 4 8 5000"
)

output_summary="results_summary.txt"
rm -f $output_summary

declare -A job_ids

for config in "${configs[@]}"; do
    IFS='#' read -r config_params config_comment <<< "$config"
    IFS=' ' read -r -a params <<< "$config_params"
    nodes=${params[0]}
    tasks_per_node=${params[1]}
    cpus_per_task=${params[2]}
    omp_num_threads=${params[3]}
    scale=${params[4]}
    iterations=${params[5]}

    # Create a unique SLURM script for each configuration
    slurm_file="cfd_${nodes}_${tasks_per_node}_${cpus_per_task}_${omp_num_threads}_${scale}_${iterations}.slurm"
    cp cfd_template.slurm $slurm_file

    # Replace placeholders with actual values
    sed -i "s/{{nodes}}/$nodes/g" $slurm_file
    sed -i "s/{{tasks_per_node}}/$tasks_per_node/g" $slurm_file
    sed -i "s/{{cpus_per_task}}/$cpus_per_task/g" $slurm_file
    sed -i "s/{{omp_num_threads}}/$omp_num_threads/g" $slurm_file
    sed -i "s/{{scale}}/$scale/g" $slurm_file
    sed -i "s/{{iterations}}/$iterations/g" $slurm_file

    # Submit the job and get the job ID
    job_id=$(sbatch $slurm_file | awk '{print $4}')
    job_ids[$job_id]=$config_comment
    echo "Submitted job $job_id with config: $config_comment"
done

# Wait for all jobs to complete
for job_id in "${!job_ids[@]}"; do
    while : ; do
        squeue -j $job_id > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Job $job_id (${job_ids[$job_id]}) has completed."
            break
        fi
        sleep 10
    done
done

echo "All jobs have finished" > $output_summary
