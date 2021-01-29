# pubtcrs (forked from https://github.com/phbradley/pubtcrs.git)

** This repo is used for COVID-19 FDA competation **

First of all, compile apps as original instructions below.

Then make sure perl module `Parallel::ForkManager` is avliable, otherwise install this module by `cpan install Parallel::ForkManager`. And make sure R package `ggplot2` is OK, otherwise run `install.packages(ggplot2)` in R command lines.

Finally download TCR data from https://doi.org/10.21417/ADPT2020COVID, unzip datasets. Process datasets using following commands:

```
mkdir -p ./vdjtools && mkdir -p ./pgen
unzip sampleExport.202*-**-**_**-**-**.zip # Data exported by immuneACCESS
vdjtools Convert -S ImmunoSeqV2 ./sampleExport.202*-**-**_**-**-**/XXX_TCR.tsv ./vdjtools/ # convert immunoSeqV2 format to vdjtools, using vdjtools v1.2.1
perl vdjtools_Add_pgen.pl -in ./vdjtools/XXX_TCR.txt -out ./pgen/XXX_TCR.txt -threads 24 # add PGen value and Poisson p value to evaluate whether the TCR was amplified
```

Here is an example of TCR with pgen information:

| count | freq        | cdr3nt                                                    | cdr3aa              | v           | d       | j       | VEnd | DStart | DEnd | JStart | pgen     | pvalue | qvalue | Status    |
|-------|-------------|-----------------------------------------------------------|---------------------|-------------|---------|---------|------|--------|------|--------|----------|--------|--------|-----------|
| 24830 | 0.040235873 | TGTGCCAGCAGCTTACTGATCGGGACTACCAAGGGAAAGCAGTACTTC          | CASSLLIGTTKGKQYF    | TRBV5-6     | TRBD2-1 | TRBJ2-7 | 13   | 21     | 27   | 37     | 9.91E-16 | 0      | 0      | Amplified |
| 23800 | 0.038566806 | TGCAGTGCTAGAGGATACGGCACCGCTCCTACGAGCAGTACTTCG             | CSARGYGTAPTSSTS     | TRBV20      | TRBD1   | TRBJ2-7 | 12   | 18     | 20   | 25     | NA       | NA     | NA     | -         |
| 3913  | 0.006340837 | TGTGCCAGCAGCCGTCCGGGACTAGCGGGTGTCTACAATGAGCAGTTCTTC       | CASSRPGLAGVYNEQFF   | TRBV3-1/3-2 | TRBD2-1 | TRBJ2-1 | 12   | 17     | 28   | 32     | 6.36E-10 | 0      | 0      | Amplified |
| 2559  | 0.004146742 | TGCGCCAGCAGCCACATCTTTCAGAGGGCCTATGGCTACACCTTC             | CASSHIFQRAYGYTF     | TRBV4-1     | TRBD2-1 | TRBJ1-2 | 13   | 23     | 27   | 29     | 3.10E-13 | 0      | 0      | Amplified |
| 2069  | 0.003352719 | TGTGCCAGCAGCTTACTCTACGTCCTGGGCACTGAAGCTTTCTTT             | CASSLLYVLGTEAFF     | TRBV7-9     | TRBD1   | TRBJ1-1 | 14   | 26     | -1   | 29     | 2.83E-12 | 0      | 0      | Amplified |
| 1800  | 0.002916817 | TGCGCCAGCAGTGATTGGAAGGAGGCGGGACTTGATCACCGGGGAGCTGTTTTTTGG | CASSDWKEAGLDHRGAVFW | TRBV10-1    | TRBD2-1 | TRBJ2-2 | 13   | 26     | 31   | 36     | NA       | NA     | NA     | -         |
| 1672  | 0.002709399 | TGCGCCAGCAGCCTCAACCCTAGGGGAGATGGCTACACCTTC                | CASSLNPRGDGYTF      | TRBV4-1     | TRBD1   | TRBJ1-2 | 12   | 21     | 25   | 28     | 2.08E-11 | 0      | 0      | Amplified |
| 1586  | 0.00257004  | TGTGCCAGCAGCGACAGGCCCGAGGATGAGCAGTTCTTC                   | CASSDRPEDEQFF       | TRBV6-2     | TRBD1-1 | TRBJ2-1 | -1   | 12     | 17   | 25     | 8.34E-10 | 0      | 0      | Amplified |


The first 11 columns are data in vdjtools format, and last 4 columns are pgen and assumption of TCR amplification status. Here p value was calculated using Poission model based on total TCR count and pgen value, q values were calculed using bonferroni method. If q value < 0.00001 then TCR will be marked as `Amplified` at last `Status` column.

To select amplified TCR of all samples, using following command:

```
ls ./*.txt|perl TCR.Select.pl > SelectedTCR.pl
```

Selected data in following format:

| Sample          | count | freq        | cdr3nt                | cdr3aa            | v        | d       | j       | VEnd | DStart | DEnd | JStart | pgen     | pvalue    | qvalue    | Status    |
|-----------------|-------|-------------|-----------------------|-------------------|----------|---------|---------|------|--------|------|--------|----------|-----------|-----------|-----------|
| KH20-09950_TCRB | 96    | 0.000169938 | V06,CASSEGNQPQHF      | CASSEGNQPQHF      | TRBV6-1  | TRBD1   | TRBJ1-5 | -1   | 14     | -1   | 18     | 2.17E-07 | 2.25E-238 | 8.23E-233 | Amplified |
| KH20-09950_TCRB | 95    | 0.000168168 | V07,CASSSRASPAYEQYF   | CASSSRASPAYEQYF   | TRBV7-9  | TRBD1   | TRBJ2-7 | 12   | 16     | 19   | 28     | 1.31E-10 | 0         | 0         | Amplified |
| KH20-09950_TCRB | 94    | 0.000166398 | V12,CASSSTPDRAGYTF    | CASSSTPDRAGYTF    | TRBV12   | TRBD1-1 | TRBJ1-2 | 12   | 20     | 25   | 29     | 2.26E-11 | 0         | 0         | Amplified |
| KH20-09950_TCRB | 94    | 0.000166398 | V28,CASSLRGNQPQHF     | CASSLRGNQPQHF     | TRBV28-1 | TRBD2-1 | TRBJ1-5 | -1   | 15     | -1   | 21     | 5.76E-08 | 1.29E-286 | 4.73E-281 | Amplified |
| KH20-09950_TCRB | 89    | 0.000157547 | V07,CASSLSSGRSYEQYF   | CASSLSSGRSYEQYF   | TRBV7-9  | TRBD2-1 | TRBJ2-7 | 14   | 17     | 25   | 27     | 3.13E-08 | 7.01E-293 | 2.57E-287 | Amplified |
| KH20-09950_TCRB | 87    | 0.000154007 | V04,CASSRDIAGGPESEQFF | CASSRDIAGGPESEQFF | TRBV4-2  | TRBD2-1 | TRBJ2-1 | 12   | 19     | 29   | 38     | 9.44E-14 | 0         | 0         | Amplified |
| KH20-09950_TCRB | 87    | 0.000154007 | V05,CASSLLVGGYNEQFF   | CASSLLVGGYNEQFF   | TRBV5-1  | TRBD1-1 | TRBJ2-1 | 14   | 20     | 25   | 27     | 4.00E-09 | 0         | 0         | Amplified |


First column is sample ID, and fourth column, were V_gene+CDR3 sequence, representing TCR beta chains. 

# Original Readme:


This repository contains C++ source code for the TCR clustering and correlation analyses described in the manuscript "Human T cell receptor occurrence patterns encode immune history, genetic background, and receptor specificity" by William S DeWitt III, Anajane Smith, Gary Schoch, John A Hansen, Frederick A Matsen IV and Philip Bradley, available on [bioRxiv](https://www.biorxiv.org/content/early/2018/05/02/313106).

At the moment (version 0.1), the code is specialized for beta-chain repertoire analysis and uses a TCR representation that includes the V-gene family and the CDR3 sequence (for example, "V19,CASSIRSSYEQYF"). We plan on extending to the alpha chain and adding other TCR representations in the future. (Actually, now we've started doing that, for the `pgen` and `tcrdists` executables so far). 

- `pgen` computes TCR generation probabilities.

- `tcrdists` computes TCR-TCR sequence distances using the TCRdist measure

- `neighbors` computes TCR-TCR neighbor relations based on co-occurrence and sequence similarity. It can also perform DBSCAN clustering if desired.

- `correlations` computes TCR-feature correlation p-values for user-defined features.

Usage examples can be found in the shell scripts: `tests/*/run.bash`

## REQUIREMENTS

This software depends on header files included with the BOOST C++ library.
You can download the library [here](https://www.boost.org/users/download/).

## COMPILING

Edit the "BOOSTDIR" line in the Makefile to point to the location where your BOOST download is installed. Then type `make`. The binary executable files will be placed in the `bin/` directory.

## THANKS

We are using the [TCLAP](http://tclap.sourceforge.net/) header library for parsing command line arguments. As suggested by the TCLAP docs, we have included the header files within this repository for ease of compiling. Please see the author and license information in `include/tclap/`.

## TESTING

There are some simple bash scripts that run simple tests in the `test/*/` directories. To run them all:

```
cd test/
./runall.bash
```

## DOCKER
An automatic Docker build is available at <https://hub.docker.com/r/pbradley/pubtcrs/>, and a nice mini-intro to Docker [here](http://erick.matsen.org/2018/04/19/docker.html).

