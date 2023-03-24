#!/bin/bash
rsync -azvh /home/jarservice/sausage-store.jar user-backup@51.250.19.25:/opt/backup/$(date +"%Y-%m-%d-%H")/ >> /var/log/backup-sausage-store.log