source /afs/enea.it/fra/user/saga_igi/.profile
export PATH=/usr/mpi/intel/openmpi-1.2.8/bin:$PATH
#echo $PATH
#echo $LD_LIBRARY_PATH

hostname
ls -la
#bsub -K < $1 &
bsub -K < $1 &
wait
#sleep 30
