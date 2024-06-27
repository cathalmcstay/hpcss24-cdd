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

# Wait for jobs to finish and collect results
echo "Waiting for jobs to finish..."
while [[ ${#job_ids[@]} -gt 0 ]]; do
    for job_id in "${!job_ids[@]}"; do
        state=$(squeue -j $job_id -h -o %T)
        if [[ "$state" == "COMPLETED" ]]; then
            echo "Job $job_id completed."
            output_file="slurm-${job_id}.out"
            if [[ -f $output_file ]]; then
                # Extract the relevant statistics from the output file
                error=$(grep "error is" $output_file | awk '{print $5}')
                time=$(grep "Time for" $output_file | awk '{print $4}')
                # Add the extracted statistics to the summary file with the corresponding configuration comment
                echo "${job_ids[$job_id]}: error = $error, time = $time" >> $output_summary
            else
                # If the output file is not found, log an error message
                echo "${job_ids[$job_id]}: Output file for job $job_id not found." >> $output_summary
            fi
            # Remove the completed job from the job_ids array
            unset job_ids[$job_id]
        elif [[ "$state" == "FAILED" ]]; then
            echo "Job $job_id failed."
            # Log the failure in the summary file
            echo "${job_ids[$job_id]}: Job $job_id failed." >> $output_summary
            # Remove the failed job from the job_ids array
            unset job_ids[$job_id]
        fi
    done
    # Sleep for a short interval before checking the job status again
    sleep 10
done

# Print a message indicating that all jobs have finished and where the results summary is located
echo "All jobs have finished. Results summary written to $output_summary."