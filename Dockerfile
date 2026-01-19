# Multistage Dockefile to compose Pachinko.AI images
ARG UBUNTU_VERSION=ubuntu:24.04
ARG SLURM_VERSION=25.11.0
ARG SLURM_MD5=b80465f2dd9f763f26fd8f7906b52aa9

################################
# Base OS: Ubuntu LTS.  
#   Add necessary packages.
################################
FROM ${UBUNTU_VERSION} as base_os
ARG SLURM_VERSION
ARG SLURM_MD5

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl \
                       bzip2 \
                       build-essential \
                       fakeroot \
                       devscripts \
                       equivs\
                       munge \
                       libmunge-dev\
                       python3 \
                       python3-pip \
                       python3-venv \
                       dnsutils \
                       vim 

################################
# SLURM installation
################################
FROM base_os as slurm_base

RUN useradd -ms /bin/sh slurm

WORKDIR /tmp

RUN curl https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 -o slurm-${SLURM_VERSION}.tar.bz2 && \
    echo ${SLURM_MD5} slurm-${SLURM_VERSION}.tar.bz2 > /tmp/slurm.md5 && \
    md5sum -c --quiet /tmp/slurm.md5 && \
    tar -xvjf slurm-${SLURM_VERSION}.tar.bz2 && \
    cd slurm-${SLURM_VERSION} && \
    ./configure && \
    make install && \
    ldconfig -n /usr/local/lib/slurm

################################
# SLURM configuration
################################
FROM slurm_base as slurm_deployment

WORKDIR /tmp
RUN /usr/sbin/mungekey -c -f -b 8192 -v -k /etc/munge/munge.key && \
    chown munge /etc/munge/munge.key
RUN python3 -m venv .venv && \
    . .venv/bin/activate && \
    pip install jupyterlab_slurm

RUN echo "\
ClusterName=Linux\n\
SlurmctldHost=slurmctl\n\
ProctrackType=proctrack/linuxproc\n\
ReturnToService=1\n\
SlurmctldPidFile=/var/run/slurm/slurmctld.pid\n\
SlurmctldPort=6817\n\
SlurmdPidFile=/var/run/slurm/slurmd.pid\n\
SlurmdPort=6818\n\
SlurmdSpoolDir=/var/spool/slurm\n\
SlurmUser=slurm\n\
StateSaveLocation=/var/lib/slurm\n\
TaskPlugin=task/affinity\n\
InactiveLimit=0\n\
KillWait=30\n\
MinJobAge=300\n\
SlurmctldTimeout=120\n\
SlurmdTimeout=300\n\
SchedulerType=sched/backfill\n\
SelectType=select/cons_tres\n\
AccountingStorageHost=slurmdbd\n\
JobCompLoc=/var/log/slurm/jobcomp.log\n\
JobCompType=jobcomp/filetxt\n\
JobAcctGatherFrequency=30\n\
SlurmctldDebug=debug3\n\
SlurmctldLogFile=/var/log/slurm/slurmctld.log\n\
SlurmdDebug=debug3\n\
SlurmdLogFile=/var/log/slurm/slurmd.log\n\
AuthType=auth/munge\n\
MaxNodeCount=65535\n\
PartitionName=normal Nodes=ALL Default=YES MaxTime=INFINITE State=UP\n\
"> /usr/local/etc/slurm.conf

RUN chmod 600 /usr/local/etc/slurm*.conf && \
    chown slurm /usr/local/etc/slurm*.conf && \
    mkdir /run/slurm && \
    chown slurm /run/slurm && \
    mkdir /var/lib/slurm && \
    chown -R slurm /var/lib/slurm && \
    mkdir /var/log/slurm && \
    chown -R slurm /var/log/slurm
RUN echo "\
CgroupPlugin=disabled\n \
"> /usr/local/etc/cgroup.conf

RUN echo "\
#!/bin/sh\n\
service munge start\n\
slurmdbd -D\n\
tail -f /dev/null\n\
"> /usr/local/bin/start_dbd.sh && \
    chmod +x /usr/local/bin/start_dbd.sh

RUN echo "\
#!/bin/sh\n\
service munge start\n\
slurmctld -D\n\
"> /usr/local/bin/start_controller.sh && \
    chmod +x /usr/local/bin/start_controller.sh

RUN echo "\
#!/bin/sh\n\
service munge start\n\
. /tmp/.venv/bin/activate\n\
jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''\n\
"> /usr/local/bin/start_jupyter.sh && \
    chmod +x /usr/local/bin/start_jupyter.sh

RUN echo "\
#!/bin/sh\n\
service dbus start\n\
service munge start\n\
slurmd -N \`hostname\` -Z -D\n\
tail -f /dev/null\n\
"> /usr/local/bin/start_node.sh && \
    chmod +x /usr/local/bin/start_node.sh

RUN mkdir /root/.pachinko
WORKDIR /root/.pachinko

