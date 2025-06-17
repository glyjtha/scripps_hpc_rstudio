#!/bin/bash
#SBATCH --output="r_studio.log"
#SBATCH --job-name="rstudio_server"
#SBATCH --time=12:00:00    # walltime
#SBATCH --cpus-per-task=8  # number of cores
#SBATCH --mem-per-cpu=8G   # memory per CPU core
#SBATCH --error="r_studio.err"   # error log

# File       : start_rstudio.sh
# Created    : Sat Mar 2 2024 10:03:57 AM
# Author     : Renhao Luo
# Description: Start Rstudio Server
# Copyright 2024 The Scripps Research Institute. All Rights Reserved.

# modified from https://www.rocker-project.org/use/singularity/

export PASSWORD=$(openssl rand -base64 15)

# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the python & singularity commands
readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

echo "ssh -L 8787:${HOSTNAME}:${PORT} ${USER}@login03"
echo "user: ${USER}"
echo "password: ${PASSWORD}"

cat >> ${HOME}/scripps_hpc_rstudio/log.txt << END

--- `date` ---
1. SSH tunnel from your workstation using the following command:

   ssh -L 8787:${HOSTNAME}:${PORT} ${USER}@login03

   and point your web browser to http://localhost:8787

2. log in to RStudio Server using the following credentials:

   user: ${USER}
   password: ${PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ('power' button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      qdel -x ${PBS_JOBID}
END

export TMPDIR="${HOME}/scripps_hpc_rstudio/rstudio-tmp"

# make ssh key for passwordless internode ssh
# if you already have a public key copy it to .ssh/authorized_keys
if [ ! -e ${HOME}/.ssh/id_rsa.pub ]
then
  cat /dev/zero | ssh-keygen -t rsa -N ""
  cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys
  chmod 700 ${HOME}/.ssh; chmod 640 ${HOME}/.ssh/authorized_keys
fi

# User-installed R packages go into their home directory
if [ ! -e ${HOME}/.Renviron ]
then
  printf '\nNOTE: creating ~/.Renviron file\n\n'
  echo 'R_LIBS_USER=~/R/%p-library/%v' >> ${HOME}/.Renviron
  # env vars need to go in the .Renviron file
fi

# make outfolder (check for errors)
mkdir -p ${HOME}/rstudio-hpc/output

# create secure-cookie-key (thanks @MboiTui)
if [ ! -e ${TMPDIR}/tmp/rstudio-server/${USER}_secure-cookie-key ]
then
   mkdir -p ${TMPDIR}/tmp/rstudio-server/
   export UUID=$(python  -c 'import uuid; print(uuid.uuid1())')
   echo ${UUID} > ${TMPDIR}/tmp/rstudio-server/${USER}_secure-cookie-key
fi


mkdir -p ${TMPDIR}/var/lib
mkdir -p ${TMPDIR}/var/run

# By default the only host file systems mounted within the container are $HOME, /tmp, /proc, /sys, and /dev.
# you can use --bind [-B] to bind other file systems

singularity exec \
   --bind="$TMPDIR/var/lib:/var/lib/rstudio-server" \
   --bind="$TMPDIR/var/run:/var/run/rstudio-server" \
   --bind="$TMPDIR/tmp:/tmp" \
   --bind="/gpfs/group/jin:/gpfs/group/jin" \
   ${HOME}/scripps_hpc_rstudio/rstudio-hpc-v3.sif bash -c "\
   rserver --www-port ${PORT} --auth-none=0 --auth-pam-helper-path=pam-helper \
   --auth-timeout-minutes=0 --auth-stay-signed-in-days=30 --server-user ${USER} \
   --secure-cookie-key-file ${HOME}/tmp/rstudio-server/${USER}_secure-cookie-key \
   "
