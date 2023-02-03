#! /usr/bin/env bash
set -e              # Crash on error
set -o nounset      # Crash on unset variables

## run_stopgap.sh
# A script for performing subtomogram averaging using 'stopgap'.
# This script first generates a submission file and then launches 
# 'stopgap_watcher', a MATLAB executable that manages the flow of parallel 
# stopgap averging jobs.
#
# Stopgap uses a special .star file to define the subtomogram averaging 
# parameters. These .star files can be generated using 'stopgap_job_parser.sh'.
#
# WW 06-2018

### MPI Biochem specifics ###
# hpcl4001 queues: p.192g p.512g - 40 cores/node
# hpcl7001 queues: p.512g - 32 cores/node
# hpcl8001 queues: p.hpcl8 - 24 cores/node

### ACCRE specifics ###
# AMD Zen nodes have 128 cores/node and 8G memory/core


##### RUN OPTIONS #####
run_type='slurm'            # Types supported are 'local' and 'slurm', for local and slurm-cluster submissions.
nodes=4                     # Number of nodes
n_cores=256                 # Number of subtomogram alignment cores; should be in multiples of cores/node.
queue='production'          # Queue for alignment jobs. Ignored for local jobs.
mem_limit='12G'              # Amount of memory per node (G = gigabytes). Ignored for local jobs.
wall_time='03-00:00:00'        # Maximum run time in seconds (format: [dd-hh:mm:ss], ACCRE production limit: 14 days). Ignored for local jobs.
job_name='stopgap'     # SLURM job name
account='wan_lab'           # Account to charge
copy_local=1                # Copy processing data to local temporary storage

##### DIRECTORIES #####
rootdir='/dors/wan_lab/home/wanw/research/empiar_10453/tm/bin4/tomo7_corr_sgtmpl/'    # Main subtomogram averaging directory
paramfilename='params/tm_param.star'          # Relative path to stopgap parameter file. 





################################################################################################################################################################
##### SUBTOMOGRAM AVERAGING WORKFLOW                                                                                                       ie. the nasty bits...
################################################################################################################################################################


# Path to MATLAB executables
watcher="${STOPGAPHOME}/bin/stopgap_watcher.sh"
subtomo="${STOPGAPHOME}/bin/stopgap_mpi_slurm.sh"


# Remove previous submission script
rm -f submit_stopgap

if [ "${run_type}" = "local" ]; then
    echo "Running stopgap locally..."


    # Local submit command
    submit_cmd="mpiexec -np ${n_cores} ${subtomo} ${rootdir} ${paramfilename} ${n_cores}  2> ${rootdir}/error_stopgap 1> ${rootdir}/log_stopgap &"
    # echo ${submit_cmd}



elif [ "${run_type}" = "slurm" ]; then
    # Default SLURM parameters
    cpus_per_task=1             # CPUs per task; for STOPGAP this should always be 1
    # Check tasks per node
    if [[ "$(( $n_cores % $nodes ))" = 0 ]]; then    # Check for integer division
        ntasks_per_node=$(( $n_cores / $nodes ))     # Integer tasks per node
    else
        echo "ACHTUNG!!! Cores not evenly distributed across nodes!!!"
        exit
    fi
    
    echo "Preparing to run stopgap on slurm-cluster..."


    # Write submission script
    echo "#!/bin/bash" > submit_stopgap                                                # Use BASH environment
    echo "#SBATCH -D ${rootdir}" >> submit_stopgap                                              # Set working directory
    echo "#SBATCH -e error_stopgap" >> submit_stopgap                                           # Output error file
    echo "#SBATCH -o log_stopgap" >> submit_stopgap                                             # Output log file
    echo "#SBATCH -J ${job_name}" >> submit_stopgap                                             # Job name
    echo "#SBATCH --partition=${queue} " >> submit_stopgap                                      # Partition name
    echo "#SBATCH --nodes=${nodes} " >> submit_stopgap                                          # Number of nodes
    echo "#SBATCH --ntasks=${n_cores}" >> submit_stopgap                                        # Number of tasks; i.e. CPUs
    echo "#SBATCH --ntasks-per-node=${ntasks_per_node}" >> submit_stopgap                       # Number of tasks per node; set to evenly split.
    echo "#SBATCH --cpus-per-task=${cpus_per_task}" >> submit_stopgap                           # CPUs per task, should generally be 1
    echo "#SBATCH --mem-per-cpu=${mem_limit}" >> submit_stopgap                                 # Memory per CPU
    echo "#SBATCH --time=${wall_time}" >> submit_stopgap                                        # Max wall time
    echo "#SBATCH --account=${account}" >> submit_stopgap                                       # Account to charge
    echo "srun ${subtomo} ${rootdir} ${paramfilename} ${n_cores} ${copy_local}" >> submit_stopgap

    # Make executable
    chmod +x submit_stopgap
    
    # Submission command
    submit_cmd="sbatch submit_stopgap"

else
    echo 'ACHTUNG!!! Invalid run_type!!!'
    echo 'Only supported run_types are "local", and "slurm"!!!'
    exit 1
fi



# Run watcher
eval "${watcher} ${rootdir} ${paramfilename} ${n_cores} '${submit_cmd}'"
rm -f submit_stopgap

exit




