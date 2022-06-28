#! /bin/bash
set -o xtrace

MEASUREMENTS=10
SIZE_ITERATIONS=3 #10
THREAD_ITERATIONS=6 #6
INITIAL_SIZE=16
INITIAL_THREAD_NUM=1
IO_MALLOC_FLAG=0
NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp')

formating(){
tail -n 2| grep -o -E '[0-9][,][0-9]+[%]?' | sed ':a;N;$!ba;s/\,/\./g;s/\n/,/g'
}

make
echo "VERSION,REGION,IO_MALLOC_FLAG,SIZE,THREAD_NUM,AVG_TOTAL_TIME,STD_TOTAL_TIME,%STD" >>  experiments.csv
for NAME in ${NAMES[@]}; do
    SIZE=$INITIAL_SIZE
    
    for ((i=1; i<=$SIZE_ITERATIONS; i++)); do
        
        THREAD_NUM=$INITIAL_THREAD_NUM
        
        for ((j=1; j<=$THREAD_ITERATIONS; j++)); do
            echo -n "${NAME},full,${IO_MALLOC_FLAG},${SIZE},${THREAD_NUM}," >> experiments.csv
            perf stat -r $MEASUREMENTS ./$NAME -2.5 1.5 -2.0 2.0 $SIZE $THREAD_NUM $IO_MALLOC_FLAG |& formating >> experiments.csv
            
            echo -n "${NAME},seahorse,${IO_MALLOC_FLAG},${SIZE},${THREAD_NUM}," >> experiments.csv
            perf stat -r $MEASUREMENTS ./$NAME -0.8 -0.7 0.05 0.15 $SIZE $THREAD_NUM $IO_MALLOC_FLAG |& formating >> experiments.csv
            
            echo -n "${NAME},elephant,${IO_MALLOC_FLAG},${SIZE},${THREAD_NUM}," >> experiments.csv
            perf stat -r $MEASUREMENTS ./$NAME 0.175 0.375 -0.1 0.1 $SIZE $THREAD_NUM $IO_MALLOC_FLAG |& formating >> experiments.csv
            
            echo -n "${NAME},spiral,${IO_MALLOC_FLAG},${SIZE},${THREAD_NUM}," >> experiments.csv
            perf stat -r $MEASUREMENTS ./$NAME -0.188 -0.012 0.554 0.754 $SIZE $THREAD_NUM $IO_MALLOC_FLAG |& formating >> experiments.csv
            
            if [ $NAME == "mandelbrot_seq" ]; then
                break
            fi
            
            THREAD_NUM=$(($THREAD_NUM * 2))
            
        done
        
        SIZE=$(($SIZE * 2))
        
    done

    rm output.ppm
done    
