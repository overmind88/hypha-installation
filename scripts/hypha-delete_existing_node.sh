#!/bin/bash

# Define usage function
usage() {
  echo "Usage: $0 --cluster-id <cluster_id> --node-id <node_id> [--auth-token <auth_token>] [--url <url>]"
  echo ""
  echo "Options:"
  echo "  --cluster-id <string>      Set the ID of the cluster"
  echo "  --node-id <string>         Set the ID of the node to be deleted"
  echo "  --auth-token <string>      Set the Authentication token (optional)"
  echo "  --url <URL>                Set the base URL for the Resources manager service (default: localhost:8096)"
  echo "  --help                     Display this help message"
  exit 1
}

# Set default values for optional parameters
auth_token="eyJhbGciOiJIUzUxMiJ9.eyJ1c2VySWQiOiIwIiwicm9sZSI6IlNZU1RFTSIsImV4cCI6NDgxMjExNzkzNn0.91oYe8M2ZEl-M_la5te--jsI66gO3XIgAxAH-TXIKp7olWlEapLN_UZi2JSPfcdr23XRzn5BSUwzuFRbbx6P_A"
url="localhost:8096"

# Parse named parameters
while [ "$#" -gt 0 ]; do
  case $1 in
    --cluster-id)
      cluster_id="$2"
      shift 2
      ;;
    --node-id)
      node_id="$2"
      shift 2
      ;;
    --auth-token)
      auth_token="$2"
      shift 2
      ;;
    --url)
      url="$2"
      shift 2
      ;;
    --help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      echo ""
      usage
      ;;
  esac
done

# Validate mandatory parameters
if [ -z "$cluster_id" ] || [ -z "$node_id" ]; then
  echo "Error: --cluster-id and --node-id are required."
  echo ""
  usage
fi

# Send the request
auth_header="Authorization-Internal: Bearer ${auth_token}"
node=$(curl -f -X DELETE "http://${url}/api/v1/cluster/${cluster_id}/node?ids=${node_id}" -H 'Content-Type: application/json' -H "${auth_header}")

echo "${node}"
