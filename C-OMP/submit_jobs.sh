#!/bin/bash

# Define the configurations
configs=(
    #Config: Node, tasks per node, CPUs per task, threads, scale, iterations
    "1 4 4 4 4 10000"
    "1 4 4 4 8 5000"
)

output_file="results_summary.txt"
rm -f $output_file

for config in "${configs[@]}"; do
    IFS=' ' read -r -a params <<< "$config"
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
    echo "Submitted job $job_id with config: $config"
done

# Wait for jobs to finish and collect results
echo "Waiting for jobs to finish..."
for config in "${configs[@]}"; do
    IFS=' ' read -r -a params <<< "$config"
    nodes=${params[0]}
    tasks_per_node=${params[1]}
    cpus_per_task=${params[2]}
    omp_num_threads=${params[3]}
    scale=${params[4]}
    iterations=${params[5]}

    slurm_file="cfd_${nodes}_${tasks_per_node}_${cpus_per_task}_${omp_num_threads}_${scale}_${iterations}.slurm"
    job_id=$(grep "Submitted job" slurm_file.out | awk '{print $3}')

    # Wait for the job to finish
    while true; do
        state=$(squeue -j $job_id -h -o %T)
        if [[ "$state" == "COMPLETED" ]]; then
            break
        elif [[ "$state" == "FAILED" ]]; then
            echo "Job $job_id failed."
            break
        fi
        sleep 10
    done

    # Extract results from the output file
    output_file="slurm-${job_id}.out"
    if [[ -f $output_file ]]; then
        error=$(grep "error is" $output_file | awk '{print $5}')
        time=$(grep "Time for" $output_file | awk '{print $4}')
        echo "$config: error = $error, time = $time" >> $output_file
    else
        echo "Output file for job $job_id not found."
    fi
done
