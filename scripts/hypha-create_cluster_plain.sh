#!/bin/bash

# Set default values
url="localhost:8096"
name=""
description=""
cluster_type="plain"
nodes_user=""
is_default="false"
auth_token="eyJhbGciOiJIUzUxMiJ9.eyJ1c2VySWQiOiIwIiwicm9sZSI6IlNZU1RFTSIsImV4cCI6NDgxMjExNzkzNn0.91oYe8M2ZEl-M_la5te--jsI66gO3XIgAxAH-TXIKp7olWlEapLN_UZi2JSPfcdr23XRzn5BSUwzuFRbbx6P_A"

# Help message
help_message() {
  echo "Usage: $0 --name <name> --user <user> --auth-token <token> [--description <description>] [--is-default <true|false>] [--url <url>]"
  echo "Options:"
  echo "  --name <string>                    Set the cluster name"
  echo "  --description <string>             Set the cluster description (optional)"
  echo "  --user <string>                    Set the user to access the nodes"
  echo "  --is-default <true|false>          Set the cluster default flag (default: false)"
  echo "  --auth-token <string>              Set the authentication token"
  echo "  --url <URL>                        Set the base URL for the Resources manager service (default: localhost:8096)"
  echo "  --help                             Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --name)
      name="$2"
      shift 2
      ;;
    --description)
      description="$2"
      shift 2
      ;;
    --user)
      nodes_user="$2"
      shift 2
      ;;
    --is-default)
      is_default="$2"
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
if [ -z "$name" ]; then
  echo "Cluster name is not specified. Use --name <name> to provide the name."
  exit 1
fi

if [ -z "$auth_token" ]; then
  echo "Authentication token is not specified. Use --auth-token <token> to provide the token."
  exit 1
fi

if [ -z "$nodes_user" ]; then
  echo "User for nodes access is not specified. Use --user <user> to provide the user."
  exit 1
fi


# Prepare the JSON payload
json_payload=$(cat <<EOF
{
  "data": {
    "name": "${name}",
    "description": "${description}",
    "properties": {
      "type": "plain",
      "defaultLogin": "${nodes_user}"
    },
    "default": ${is_default}
  }
}
EOF
)

# Send the request
auth_header="Authorization-Internal: Bearer ${auth_token}"
cluster=$(curl -f -X POST "http://${url}/api/v1/cluster" -H 'Content-Type: application/json' -H "${auth_header}" -d "${json_payload}")

echo "${cluster}"
echo "${cluster}" >> created_clusters.txt
