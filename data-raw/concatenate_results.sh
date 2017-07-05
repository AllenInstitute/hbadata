#!/usr/bin/env bash
# script to concatenate the resulting individual csvs from formatter into
# one large csv; should be run in the directory containing
# `resultFrameCollapse`.
touch resultFrameTotal.csv
i=1
for f in $(ls resultFrameCollapse)
do
    if [[ $i == 1 ]]
    then
        cat "resultFrameCollapse/$f" > resultFrameTotal.csv
    else
        tail -n +2 "resultFrameCollapse/$f" >> resultFrameTotal.csv
    fi
    i=$(( i + 1 ))
done
