#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## run_tomoman.sh
# A script for running TOMOMAN in parallel on a SLURM cluster.
#
# WW 07-2022


##### RUN OPTIONS #####
n_nodes=1                    # Number of nodes
n_tasks=2
n_tasks_per_node=2
cpus_per_task=5
gpu_per_node=2
gpu_per_task=1



##### DIRECTORIES #####
root_dir='/dors/wan_lab/home/wanw/research/empiar_10453/tm/bin4/tomo7_corr_sgtmpl/'    # Main TOMOMAN directory
paramfilename='params/tm_param.star'          # Relative path to TOMOMAN parameter file. 





################################################################################################################################################################
##### TOMOMAN
################################################################################################################################################################


# Path to MATLAB executables
tomoman="${TOMOMANHOME}/bin/tomoman_slurm.sh"


# Remove previous submission script
rm -f submit_tomoman



echo "Preparing to run TOMOMAN on MPI..."

# Set tasks
mpi_n_task="-np ${n_tasks}"
mpi_cpus_per_task="--map-by slot:PE=${cpus_per_task}" 
mpi_n_tasks_per_node="-npernode ${n_tasks_per_node}"


# Run using MPI
mpirun -np $mpi_n_task $mpi_cpus_per_task $mpi_n_tasks_per_node $TOMOMANHOME/lib/tomoman_mpi.sh ${root_dir} ${paramfilename} $n_nodes $cpus_per_task $gpu_per_node $gpu_per_task 2> ${root_dir}/error_tomoman 1> ${root_dir}/log_tomoman &

exit




