#!/bin/bash
# Script to upload Proxmox backups to Azure Storage

src="/mnt/pve/synology-nas-ds214-backup/dump/"
token="Blob SAS URL"

echo "Synchronizing Proxmox backups from $src to Azure..."
azcopy sync "$src" "$token" --delete-destination=true

echo "Finished Synchronizing!"
