# scripps_hpc_rstudio
This project is based on (https://github.com/RenhaoL/scripps_hpc_rstudio.git).

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
   - If FATAl error run:
   - `singularity remote add sylabs-cloud cloud.sylabs.io`
   - `singularity remote use sylabs-cloud`
   - `singularity remote login`
5. Run the command `singularity build rstudio-hpc-v3.sif rstudio-hpc.def` to build image (Re-run this command if modified .def)
6. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
7. Check the `log.txt` file using `less log.txt` for tunnel access information and the username/password.
8. Copy and paste the SSH tunnel access command to new terminal
9. Open a browser and go to the specified localhost address
10. Login with the password given from `log.txt`

### Option 2
If you have trouble to build the singularity image, you could copy from my repository on HPC. 

1. `git clone` this repository to your HPC directory. 
2. Inside this repository, `cp /gpfs/home/rluo/rstudio-hpc/rstudio-hpc-v3.sif .`
3. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
4. Check out the `log.txt` for tunnel access and username/password.

## Additional package
If you need to install additional R library for your Rstudio, try to install the library in your Rstudio first. If got errors, you could modify the `rstudio-hpc.def` file and rebuild the image. 

## Changes Made
Modify `rstudio-hpc.def` for additional package
- Installed additional system libraries (e.g., zlib1g-dev, libssl-dev, build-essential) to support compilation of R packages from source.
- Switched from basic `apt-get install` to a more complete dependency list, ensuring compatibility for packages for `Seurat`, and `Signac`.
- Used BiocManager to install bioinformatics packages: `GenomeInfoDb`, `GenomicRanges`, `Rsamtools`, etc.
- Used `SeuratObject` version 5.0.0
- Added `devtools::install_version()` to pin `Signac` to version 1.8.0.
- Added cleanup commands (`apt-get clean && rm -rf`) to reduce final image size.
