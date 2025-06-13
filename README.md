# scripps_hpc_rstudio
This project is based on (https://github.com/RenhaoL/scripps_hpc_rstudio.git).

Setting up Rstudio Server on the Scripps Research HPC

Desgined for users do not have root access in a HPC.

## Rationale: 
- Create a shared R environment
- Take the advantage of the resources of HPC for large data analysis (high RAM, high CPU)

## Implementation
Create a Singularity image containing Rstudio Server and all required R libraries for analysis (Currently mainly the packages for single-cell analysis)

## Tutorial
1. Log into the HPC by opening terminal and entering `ssh youremail@login00.scripps.edu`. Other login nodes can also be used, read [HPC FAQ](https://scrippsresearch.sharepoint.com/sites/its/SitePages/HPC-FAQ.aspx)  
2. Enter `git clone https://github.com/asunboi/scripps_hpc_rstudio`. This will create a folder named scripps_hpc_rstudio in your home directory.
3. Create an online account with [Sylabs](https://sylabs.io/), and generate a personal token. (Usually good for a month)
4. In HPC, run `singularity remote login`, and enter your username and personal token.   
   - If FATAl error run:
   - `singularity remote add sylabs-cloud cloud.sylabs.io`
   - `singularity remote use sylabs-cloud`
   - `singularity remote login`
5. Run the command `cd ~/scripps_hpc_rstudio` to enter the folder generated in step 2.
6. Run the command `singularity build rstudio-hpc-v3.sif rstudio-hpc.def` to build image (Re-run this command if modified .def)
7. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
8. Check the `log.txt` file using `less log.txt` for tunnel access information and the username/password.
9. Copy and paste the SSH tunnel access command to new terminal
10. Open a browser and go to the specified localhost address
11. Login with the password given from `log.txt`

## Additional packages
If you need to install additional R library for your Rstudio, try to install the library in your Rstudio first. If got errors, you could modify the `rstudio-hpc.def` file and rebuild the image. 

## Changes Made
Modified `rstudio-hpc.def` for additional package
- Installed additional system libraries (e.g., zlib1g-dev, libssl-dev, build-essential) to support compilation of R packages from source.
- Switched from basic `apt-get install` to a more complete dependency list, ensuring compatibility for packages for `Seurat`, and `Signac`.
- Used BiocManager to install bioinformatics packages: `GenomeInfoDb`, `GenomicRanges`, `Rsamtools`, etc.
- Used `SeuratObject` version 5.0.0
- Added `devtools::install_version()` to pin `Signac` to version 1.8.0.
- Added cleanup commands (`apt-get clean && rm -rf`) to reduce final image size.

## Troubleshooting
If you have trouble building the singularity image, you can copy from my repository on HPC. 

1. `git clone` this repository to your HPC directory. 
2. Inside this repository, `cp /gpfs/home/asun/rstudio-hpc/rstudio-hpc-v3.sif .`
3. `sbatch start_rstudio.sh` to submit the job to a computing node. 
    - Note, modify the `#SBATCH` tags to request different number of CPUs and RAMs.
4. Check out the `log.txt` for tunnel access and username/password.

