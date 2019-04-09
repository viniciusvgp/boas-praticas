#!/bin/bash

#SBATCH --nodes=2
#SBATCH --time=02:00:00
#SBATCH --partition=hype
#SBATCH --job-name=erad-2019-tutorial

# Working on scratch
cd $SCRATCH
mkdir erad-tuto
cd erad-tuto

# Spack and hwloc
git clone https://github.com/spack/spack.git
cd spack
./bin/spack install hwloc@2.0.2~gl+cairo~cuda+pci
cd ..

# Application
wget https://www.nas.nasa.gov/assets/npb/NPB3.4-MZ.tar.gz
tar -xf NPB3.4-MZ.tar.gz
cd NPB3.4-MZ/NPB3.4-MZ-MPI
cp config/NAS.samples/make.def.gcc_mpich config/make.def
make bt-mz CLASS=A
make bt-mz CLASS=W
cd ../..

# Experiments design (copy) 
cp ~/btmz-exec-order.csv ./

# MPI Machine file
MACHINEFILE="nodes.$SLURM_JOB_ID"
srun -l hostname | sort -n | awk '{print $2}' > $MACHINEFILE

tail -n +2 btmz-exec-order.csv |
while IFS=, read -r name runnoinstdorder runno runnostdrp \
	 threads processes class Blocks
do
    # OpenMP threads
    runline="OMP_NUM_THREADS=$threads "
    # MPI processes
    runline+="mpirun -np $processes "
    # MPI machine file
    runline+=" -machinefile $MACHINEFILE "
    # Binary
    runline+="bin/bt-mz.$class.x "
    # Log
    runline+="> btmz-$runno-$threads-$processes-$class.log"
 
    echo "Running >> $runline <<"
    eval "$runline < /dev/null"
    echo "Done!"
done 
# Get info
