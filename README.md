# scripps_hpc_rstudio
Setting up Rstuido Server on the Scripps Research HPC

## Rationale: 
- Create a shared R environment
- Take the advantage of the resources of HPC for large data analysis (high RAM, high CPU)

## Implementation
Create a Singularity image containing Rstudio Server and all required R libraries for analysis (Currently mainly the packages for single-cell analysis)

## Tutorial

1. `git clone` this repository to your HPC directory. 
2. 