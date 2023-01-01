#!/bin/bash
# Script to upload Proxmox backups to Azure Storage

src="/mnt/pve/synology-nas-ds214-backup/dump/*"
token="sastoken"

echo "Uploading Proxmox backups from $src to Azure..."
/azure-cli/azcopy copy "$src" "$token" --recursive=true

echo "Finished Upload!"
