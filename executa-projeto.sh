# ... continuação
# Diretório geral para contar todos os resultados
export EXPEDIR=CHA
# Verificar se projeto experimental é fornecido
PROJETO=projeto-experimental.csv
if [[ -f $PROJETO ]]; then
    echo "O projeto experimental é o seguinte"
    cat $PROJETO | sed -e "s/^/PROJETO|/"
    # Salva o projeto no diretório corrente (da saída)
    cp $PROJETO .
else
    echo "Arquivo $PROJETO está faltando."
    exit
fi
mkdir -p $EXPEDIR
#Criar arquivo de tempos
touch $EXPEDIR/"times"
# Ler o projeto experimental, e para cada experimento
tail -n +2 $PROJETO |
    while IFS=, read -r name runnoinstdorder runno runnostdrp size scheduler Blocks
    do
	# Limpar valores
	export name=$(echo $name | sed ’s/\"//g’)
	export scheduler=$(echo $scheduler | sed ’s/\"//g’)
	export size=$(echo $size | sed ’s/\"//g’)
	export KEY="$name-$scheduler-$size"
	export STARPU_SCHED=$scheduler
	./chameleon/bin/timing/time_dpotrf_tile --nb=960 --n_range=$size:$size:$size --nowarmup -c > $EXPEDIR/${KEY}."stdout"
	out=($(cat $EXPEDIR/${KEY}."stdout" | tail -n 1))
	echo $name","$scheduler","$size","${out[3]} >> $EXPEDIR/"times"
    done
