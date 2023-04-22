#!/bin/bash

# Set default values
url="localhost:8096"
cluster_id=""
node_name=""
node_description=""
node_address=""
node_work_dir=""
node_os_type=""
auth_token="eyJhbGciOiJIUzUxMiJ9.eyJ1c2VySWQiOiIwIiwicm9sZSI6IlNZU1RFTSIsImV4cCI6NDgxMjExNzkzNn0.91oYe8M2ZEl-M_la5te--jsI66gO3XIgAxAH-TXIKp7olWlEapLN_UZi2JSPfcdr23XRzn5BSUwzuFRbbx6P_A"

# Help message
help_message() {
  echo "Usage: $0 --cluster-id <id> --node-name <name> --node-address <address> --node-work-dir <dir> [--node-description <description>] [--node-os-type <os-type>] [--auth-token <token>] [--url <url>]"
  echo "Options:"
  echo "  --cluster-id <string>              Set the cluster ID"
  echo "  --node-name <string>               Set the node name"
  echo "  --node-address <URL>               Set the node address (with port for ssh)"
  echo "  --node-work-dir <string>           Set the working directory used for tasks data"
  echo "  --node-description <string>        Set the node description (optional)"
  echo "  --node-os-type <UNIX|WINDOWS>      Set the node OS type (default: UNIX)"
  echo "  --auth-token <string>              Set the authentication token (optional)"
  echo "  --url <URL>                        Set the base URL for the Resources Manager service (default: localhost:8096)"
  echo "  --help                             Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --cluster-id)
      cluster_id="$2"
      shift 2
      ;;
    --node-name)
      node_name="$2"
      shift 2
      ;;
    --node-address)
      node_address="$2"
      shift 2
      ;;
    --node-work-dir)
      node_work_dir="$2"
      shift 2
      ;;
    --node-description)
      node_description="$2"
      shift 2
      ;;
    --node-os-type)
      node_os_type="$2"
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
      help_message
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if the required parameters are provided
if [ -z "$cluster_id" ]; then
  echo "Cluster ID is not specified. Use --cluster-id <id> to provide the ID."
  exit 1
fi

if [ -z "$node_name" ]; then
  echo "Node name is not specified. Use --node-name <name> to provide the name."
  exit 1
fi

if [ -z "$node_address" ]; then
  echo "Node address is not specified. Use --node-address <address> to provide the address."
  exit 1
fi

if [ -z "$node_work_dir" ]; then
  echo "Node working directory is not specified. Use --node-work-dir <dir> to provide the directory."
  exit 1
fi

# Set default values for optional parameters
if [ -z "$node_os_type" ]; then
  node_os_type="UNIX"
fi

# Prepare the JSON payload
json_payload=$(cat <<EOF
{
  "data": {
    "name": "${node_name}",
    "description": "${node_description}",
    "address": "${node_address}",
    "workDir": "${node_work_dir}",
    "osType": "${node_os_type}"
  }
}
EOF
)

# Send the request
auth_header="Authorization-Internal: Bearer ${auth_token}"
node=$(curl -f -X POST "http://${url}/api/v1/cluster/${cluster_id}/node" -H 'Content-Type: application/json' -H "${auth_header}" -d "${json_payload}")

echo "${node}"
echo "${node}" >> created_nodes.txt
