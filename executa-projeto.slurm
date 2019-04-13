#!/bin/bash
#SBATCH --job-name=exp0
#SBATCH --time=01:00:00
#SBATCH --nodes=2
#SBATCH --tasks-per-node=10
#SBATCH --ntasks=20
#SBATCH --partition=tupi

# Diretório de base (atualize para seu caso
export BASE=~/SEUNOME/

# Ingressar no diretório de base
pushd $BASE

# Criar um diretório para conter todos os resultados
rm -rf $SLURM_JOB_NAME
mkdir -p $SLURM_JOB_NAME
pushd $SLURM_JOB_NAME

# Define o Machine File necessário para MPI
MACHINEFILE="nodes.$SLURM_JOB_ID"
srun $SRUN_PACK /bin/hostname | sort -n | awk "{print $2}" > $MACHINEFILE

# Verificar se projeto experimental é fornecido
PROJETO=$BASE/projeto-experimental.csv
if [[ -f $PROJETO ]]; then
  echo "O projeto experimental é o seguinte"
  cat $PROJETO | sed -e "s/^/PROJETO|/"
  # Salva o projeto no diretório corrente (da saída)
  cp $PROJETO .
else
  echo "Arquivo $PROJETO está faltando."
  exit
fi

# Verificar se programa é fornecido
PROGRAMA=$BASE/mpi_mm.c
if [[ -f $PROGRAMA ]]; then
  echo "O programa é o seguinte"
  cat $PROGRAMA | sed -e "s/^/PROGRAMA|/"
  # Salva o programa no diretório corrente (da saída)
  cp $PROGRAMA .
else
  echo "Arquivo $PROGRAMA está faltando."
  exit
fi

# Ler o projeto experimental, e para cada experimento
tail -n +2 $PROJETO |
while IFS=, read -r name runnoinstdorder runno runnostdrp \
	 size processes Blocks
do
    # Limpar valores
    export name=$(echo $name | sed "s/\"//g")
    export processes=$(echo $processes | sed "s/\"//g")
    export size=$(echo $size | sed "s/\"//g")

    # Definir uma chave única
    KEY="$name-$processes-$size"

    # Usar a versão apropriada de MPI
    MPICC=mpicc   #$(spack location -i openmpi@$mpi)/bin/mpicc
    MPIRUN=mpirun #$(spack location -i openmpi@$mpi)/bin/mpirun

    # Altera o código fonte com o tamanho do problema
    sed -i -e "s/#define NRA \(.*\)$/#define NRA $size/" \
           -e "s/#define NCA \(.*\)$/#define NCA $size/" $PROGRAMA

    # Compilar o programa com a versão apropriada
    $MPICC $PROGRAMA -o mpi_mm
    ls -l mpi_mm
    ldd mpi_mm
    sync

    echo $KEY

    # Prepara comando de execução
    runline=""
    runline+="mpirun -np $processes "

    runline+=" -machinefile $MACHINEFILE "
#    runline+="--mca oob_tcp_if_include 192.168.30.0/24 --mca btl_tcp_if_include 192.168.30.0/24 "
    runline+="./mpi_mm "
    runline+="> ${KEY}.log"

    # 3.3 Executar o experimento
    echo "Running >> $runline <<"
    eval "$runline < /dev/null"
    echo "Done!"
done

cp $BASE/slurm-$SLURM_JOB_ID.out .

exit
