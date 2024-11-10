#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_times>"
    exit 1
fi

# Number of times to run the command
n=$1

# CSV file to store the results
output_file="timing_results.csv"

# Write the header to the CSV file
echo "Run,Real Time,User Time,System Time" > $output_file


# Function to pull the image and record the time
pull_image() {
    local image=$1
    local allplatforms

    local accumulated_time=0

    for ((i=1; i<=n; i++))
    do
        # Clear the containerd cache
        sudo ctr image prune --all

        # Run the command and capture the timing information
        start_time=$(date +%s.%3N)
        sudo ctr image pull $2 $image;
        end_time=$(date +%s.%3N)

        accumulated_time=$(echo "$accumulated_time + $end_time - $start_time" | bc)

    done

    accumulated_time=$(echo "scale=3; $accumulated_time / $n" | bc)
    
    # Write the results to the CSV file
    echo "$image,$accumulated_time" >> $output_file

}

image_name="docker.io/matsbror/fd-wasm:latest"
pull_image $image_name "--all-platforms"

image_name="docker.io/matsbror/fd-multiarch:1.0"
pull_image $image_name ""



echo "Timing results have been recorded in $output_file"
