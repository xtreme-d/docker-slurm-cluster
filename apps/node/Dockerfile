FROM centos:7

ENV MUNGE_USER '511'
ENV SLURM_USER '512'
ENV SLURM_VERSION '20.02.7'
RUN groupadd -g $MUNGE_USER munge && \
    useradd  -m -d /var/lib/munge -u $MUNGE_USER -g munge -s /bin/bash munge
RUN groupadd -g $SLURM_USER slurm && \
    useradd  -m -d /var/lib/slurm -u $SLURM_USER -g slurm -s /bin/bash slurm

RUN rpm --rebuilddb && \
    yum install -y epel-release && \
    yum update -y && \
    yum install -y \
        bzip2 \
        gcc \
        initscripts \
        mailx \
        make \
        mariadb-devel \
        mariadb-server \
        munge \
        munge-devel \
        munge-libs \
        pam-devel \
        perl-ExtUtils-MakeMaker \
        python3 \
        python3-dev \
        readline-devel \
        rng-tools \
        rpm-build \
        supervisor \
        tar \
        wget \
        && \
    yum clean all

# Install Slurm
RUN cd /tmp && \
    wget https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 && \
    ls -la && \
    rpmbuild -ta slurm-${SLURM_VERSION}.tar.bz2 && \
    yum --nogpgcheck -y localinstall /root/rpmbuild/RPMS/x86_64/*.rpm

# Set permissions for munge
RUN chown -R munge: /var/lib/munge /var/run/munge && \
    chmod 0711 /var/lib/munge && \
    chmod 0755 /var/run/munge

ADD docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 6817 6818 6819

VOLUME ["/etc/munge", "/var/spool/slurm"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD /usr/bin/supervisord
