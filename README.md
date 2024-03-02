# scripps_hpc_rstudio
Setting up Rstuido Server on the Scripps Research HPC

Desgined for users do not have root access in a HPC.
## Rationale: 
- Create a shared R environment
- Take the advantage of the resources of HPC for large data analysis (high RAM, high CPU)

## Implementation
Create a Singularity image containing Rstudio Server and all required R libraries for analysis (Currently mainly the packages for single-cell analysis)

## Tutorial

### Option 1
1. `git clone` this repository to your HPC directory. 
2. Create an online account with [Sylabs](https://sylabs.io/), and generate a personal token. (Usually good for a month)
3. In HPC, run `singularity remote login`, and enter your username and personal token. 
4. Run `singularity build --remote rstudio-hpc-v3.sif rstudio-hpc.def` to build the image (this could take a long time)
5. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
6. Check out the `log.txt` for tunnel access and username/password.

### Option 2
If you have trouble to build the singularity image, you could copy from my repository on HPC. 

1. `git clone` this repository to your HPC directory. 
2. Inside this repository, `cp /gpfs/home/rluo/rstudio-hpc/rstudio-hpc-v3.sif .`
3. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
4. Check out the `log.txt` for tunnel access and username/password.

## Additional package
If you need to install additional R library for your Rstudio, try to install the library in your Rstudio first. If got errors, you could modify the `rstudio-hpc.def` file and rebuild the image. 