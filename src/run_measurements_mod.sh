#! /bin/bash
set -o xtrace
MEASUREMENTS=10
SIZE_ITERATIONS=10
THREAD_ITERATIONS=6
INITIAL_SIZE=16
INITIAL_THREAD_NUM=2
NAMES=('mandelbrot_seq' 'mandelbrot_pth' 'mandelbrot_omp')
make
echo "VERSION,REGION,SIZE,THREAD_NUM,MEASURAMENT,EXEC_TIME,TOTAL_TIME" >>  experiment.csv
for NAME in ${NAMES[@]}; do
    SIZE=$INITIAL_SIZE
    for ((i=1; i<=$SIZE_ITERATIONS; i++)); do
        THREAD_NUM=$INITIAL_THREAD_NUM
        for ((j=1; j<=$THREAD_ITERATIONS; j++)); do
            for ((k=1; k<=$MEASUREMENTS; k++)); do
                echo -n "${NAME},full,${SIZE},${THREAD_NUM},${k}," >> experiment.csv
                ./$NAME -2.5 1.5 -2.0 2.0 $SIZE $THREAD_NUM >> experiment.csv
                echo -n "${NAME},seahorse,${SIZE},${THREAD_NUM},${k}," >> experiment.csv
                ./$NAME -0.8 -0.7 0.05 0.15 $SIZE $THREAD_NUM >> experiment.csv
                echo -n "${NAME},elephant,${SIZE},${THREAD_NUM},${k}," >> experiment.csv
                ./$NAME 0.175 0.375 -0.1 0.1 $SIZE $THREAD_NUM >> experiment.csv
                echo -n "${NAME},spiral,${SIZE},${THREAD_NUM},${k}," >> experiment.csv
                ./$NAME -0.188 -0.012 0.554 0.754 $SIZE $THREAD_NUM >> experiment.csv
            done
            
            if [ $NAME == "mandelbrot_seq" ]; then
                break
            fi
            
            THREAD_NUM=$(($THREAD_NUM * 2))
        done
        SIZE=$(($SIZE * 2))
    done

    rm output.ppm
done    
