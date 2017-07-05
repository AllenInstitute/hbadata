#!/usr/bin/env python
""" 
Script to parse through each of the directories in the human brain atlas and
construct unique list of donorIDs, probes, genes, and subregions found across
all of the brains.

In order to use this scrpit, it is required that you orgainize the sample
directories as follows:

dirHBA
    |_ donorID1
    |_ donorID2
    |_ ...

Additionally, there should be no extra directories or files in the base
directory. If your files are not organized as such, this script is not
garunteed to create the same output.

author: edelsonc<charlese@alleninstitute.org>
created: 07/02/2017
"""
import os

def write_list(alist, path):
    """helper function to quickly write list"""
    with open(path,'w') as f:
        for i in alist:
            f.write('{}\n'.format(i))


def create_output_directory():
    """
    Function creates the directory to place the output files in. It will
    be in the directory the script is run in.
    """
    print("Creating factorsHBA in {}".format(os.getcwd()))
    output_dir = "factorsHBA"
    if output_dir in os.listdir():
        print("factorsHBA already exists in cwd")
    else: 
        os.makedirs("factorsHBA")


def write_donors(path):
    """
    A function to get the donorIDs when given the base directory as described
    above

    Arguments
    --------
    path -- file path to the base directory 
    """
    donors = []
    for dirc in os.listdir(path): # get donorID from dir name
        donor = "donor{}".format(dirc[27:])
        donors.append(donor)

    # write result to list in new directory of factors
    write_list(donors, "factorsHBA/donors.txt")


def write_probes_genes(path):
    """
    A function to get the probes and genes when given the base directory as
    described above.

    Arguments
    ---------
    path -- file path to the base directory
    """
    probes = set()  # set object to eliminate duplicates
    genes = set()
    # parse through each csv in each file to find all genes and probes
    for dirc in os.listdir(path):
        with open("{}/{}/Probes.csv".format(path,dirc), 'r') as f:
            for i,line in enumerate(f):  # to skip the header
                if i == 0:
                    pass
                else:
                    row = line.strip().split(',')
                    probes.add(row[1])
                    genes.add(row[3])

    # write results to factor 
    write_list(probes, "factorsHBA/probes.txt")
    write_list(genes, "factorsHBA/genes.txt")


def write_subregions(path):
    """
    Function to get the subregions acronyms when given the base directory as
    above

    Arguments
    --------
    path -- file path to the base directory
    """
    struct_id = set()  # set to avoid duplicates
    struct_acro = set()
    # for each dir and for each file find the structures and acros
    for dirc in os.listdir(path):
        with open("{}/{}/SampleAnnot.csv".format(path,dirc), 'r') as f:
            for i,line in enumerate(f):  # to skip the header
                if i == 0:
                    pass
                else:
                    row = line.strip().split(",")
                    struct_id.add(row[0])
                    struct_acro.add(row[4])

    write_list(struct_id, "factorsHBA/structure_IDs.txt")
    write_list(struct_acro, "factorsHBA/structure_acronyms.txt")


if __name__ == "__main__":

    dirHBA = "C:/Users/charlese/Desktop/Data_Exploration/dir_HBA"
    
    create_output_directory()
    write_donors(dirHBA)
    write_probes_genes(dirHBA)
    write_subregions(dirHBA)
