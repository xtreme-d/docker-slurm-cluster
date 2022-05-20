#!/bin/bash

set -e

if [ ! -z "$IS_HEADNODE" ]; then
  # Create munge key
  if [ ! -f /etc/munge/munge.key ]; then
    create-munge-key -f
  fi

  # Create slurmcltd data directory
  if [ ! -d /var/spool/slurm/ctld ]; then
    mkdir -p /var/spool/slurm/ctld
    chown -R slurm: /var/spool/slurm
  fi

  # Init slurm acct database
  IS_DATABASE_EXIST='0'
  while [ "1" != "$IS_DATABASE_EXIST" ]; do
    echo "Waiting for database $MARIADB_DATABASE on $MARIADB_HOST..."
    IS_DATABASE_EXIST="`mysql -h $MARIADB_HOST -u root -p"$MARIADB_ROOT_PASSWORD" -qfsBe "select count(*) as c from information_schema.schemata where schema_name='$MARIADB_DATABASE'" -H | sed -E 's/c|<[^>]+>//gi' 2>&1`"
    sleep 5
  done
fi

# Prepare munge dirs
chown -R munge: /etc/munge /var/lib/munge /var/run/munge
chmod 0700 /etc/munge
chmod 0711 /var/lib/munge
chmod 0755 /var/run/munge

# Prepare slurm and munge spool dirs
if [ ! -d /var/spool/slurm/d -o ! -d /var/spool/slurm/ctld ]; then
  mkdir -p /var/spool/slurm/d /var/spool/slurm/ctld
  chown -R slurm: /var/spool/slurm
fi
if [ ! -d /var/spool/munge ]; then
  mkdir /var/spool/munge
  chown -R munge: /var/spool/munge
fi

# Ensure file permissions and ownership
chmod 600 /etc/slurm/slurmdbd.conf
chown slurm:slurm /etc/slurm/slurm.conf
chown slurm:slurm /etc/slurm/slurmdbd.conf

exec "$@"
