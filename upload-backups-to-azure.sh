#!/bin/bash
# Script to synchronize Proxmox backups to Azure Storage

src="/mnt/pve/synology-nas-ds214-backup/dump/"
token="token"

echo "Synchronizing Proxmox backups from $src to Azure..."
azcopy sync "$src" "$token" --delete-destination=true --cap-mbps 30

echo "Finished Upload!"
