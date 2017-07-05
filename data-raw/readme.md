# The `data-raw` directory
This directory contains the three scripts used to create the data in 
this package. The content of this directory should be:

* `formatterHBA-0.0.4.r`
* `concatenate_results.sh`
* `create_factors.py`
* `readme.md`

## Using the Scripts

In order to use these scripts, you'll first need to download the raw 
data from the [allen 
instutue](http://human.brain-map.org/static/download). The data comes as 
6 large zip file. Uncompress each of them and then place all 6 into a 
base directory do the data is formated as:

```
cwd
   |_dirHBA
           |_ donor1
           |_ donor2
           |_ ...
```

All of these scripts can then be run in `cwd`

### `formatterHBA-0.0.4.r`
This script is the heavy lifter of the 3. It create a new directory in 
`cwd` and puts a reformatted version of the data from the `donor` files 
into it. The function requires that you go and change the `dirHBA` 
variable to run it. This is clearly annotated in the script. After 
running the script you `cwd` should look like this
 
```
cwd
   |_resultFrameCollapse
   |                    |_ resultFrame1.csv
   |                    |_ resultFrame2.csv
   |                    |_ ...
   |_dirHBA
           |_ donor1
           |_ donor2
           |_ ...
```

### `concatenate_results.sh`
This script concatentates the resulting `csv`s from 
`formatterHBA-0.0.4.r` together to create one large `csv`, 
`resultFrameTotal.csv`. This script should be run in the current workign 
directory as follows

```
$ bash concatenate_results.sh
```

Currently there is no Windows Equivalent. However, it does run in 
cygwin.

After running, you `cwd` should look like

```
cwd
   |_resultFrameCollapse
   |                    |_ resultFrame1.csv
   |                    |_ resultFrame2.csv
   |                    |_ ...
   |
   |_dirHBA
   |       |_ donor1
   |       |_ donor2
   |       |_ ...
   |
   |_resultFrameTotal.csv
```

### `create_factors.py`
This script scapes through each `csv` in the original zip files and 
create a new directory with the unique entries of donors, probes, genes, 
and structures.

Use this script in the `cwd` by calling python
```
$ python create_factors.py
```

After running, you're cwd will look like
```
cwd
   |_ resultFrameTotal.csv
   |
   |_ resultFrameCollapse
   |                    |_ resultFrame1.csv
   |                    |_ resultFrame2.csv
   |                    |_ ...
   |
   |_ factorsHBA
   |           |_ donors.txt
   |           |_ genes.txt
   |           |_ probes.txt
   |           |_ structure_acronyms.txt
   |           |_ structure_IDs.txt
   |
   |_ dirHBA
           |_ donor1
           |_ donor2
           |_ ...
```
