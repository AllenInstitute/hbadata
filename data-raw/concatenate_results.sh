#!/usr/bin/env bash
#    Copyright (C) 2017 Allen Institute
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
