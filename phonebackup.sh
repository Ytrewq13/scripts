#!/bin/sh
#
# TODO: turn this into a usable backup script
# (maybe with interactive instructions for setting up the backup - e.g.:
# - First run with no arguments, it tells you to plug in the phone and the SSD
# - Second run (with argument "mount") creates mount points and mounts everything
# - Third run (arg "backup") runs rsync
# - Fourth run (arg "cleanup") unmounts everything
# - Option "auto" runs all functions with no stopping.

cat <<EOF
# Mount the phone
#jmtpfs /home/sam/Downloads/mnt/

# Mount the SSD
#mount /dev/sda1 /mnt

# Copy the data
#cd /home/sam/Downloads/mnt
#rsync -ah --info=progress2 --no-group DCIM Documents Download Movies Pictures /mnt/sam-nothing-backup/
EOF
