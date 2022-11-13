#!/bin/bash

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Used to provide DDNS service from anywhere
# DNS redord needs to be pre-created on Cloudflare

# Proxy - uncomment and provide details if using a proxy
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>

# Cloudflare zone is the zone which holds the record
zone=
# dnsrecord is the A record which will be updated
dnsrecord=
# Flag for cloudflare proxy status (ALL LOWER CAPS)
use_proxy=true

## Cloudflare authentication details
## keep these private
cloudflare_auth_key=""


# Get the current external IP address
current_ip=$(curl -s -X GET https://checkip.amazonaws.com)

echo "Current IP is $current_ip"

if [[ "$use_proxy" != "true" ]] && [[ $(host $dnsrecord 1.1.1.1 | grep "has address" | grep "$current_ip") ]]; then
        echo "$dnsrecord is currently set to $current_ip; no changes needed"
        exit
fi

cloudflare_zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

cloudflare_dnsrecord=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$cloudflare_zone_id/dns_records?type=A&name=$dnsrecord" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json")

cloudflare_dnsrecord_ip=$(echo $cloudflare_dnsrecord|jq -r '{"result"}[] | .[0] | .content')
cloudflare_dnsrecord_proxied=$(echo $cloudflare_dnsrecord|jq -r '{"result"}[] | .[0] | .proxied')

if [[ "$current_ip" == "$cloudflare_dnsrecord_ip" ]] && [[ "$cloudflare_dnsrecord_proxied" == "$use_proxy" ]];then
        echo "DNS record is up to date"
        exit
else
        cloudflare_dnsrecord_id=$(echo $cloudflare_dnsrecord| jq -r '{"result"}[] | .[0] | .id')
        # update the record
        curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$cloudflare_zone_id/dns_records/$cloudflare_dnsrecord_id" \
          -H "Authorization: Bearer $cloudflare_auth_key" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$current_ip\",\"ttl\":1,\"proxied\":$use_proxy}" | jq
fi
