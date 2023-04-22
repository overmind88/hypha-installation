#!/bin/bash

display_help() {
    echo "Usage: $0 --name <name> [--description <description>] --type <type> --default-login <login> --address <address> --work-dir <workdir> [--partition <partition>] [--auth-token <token>] [--help]"
    echo ""
    echo "   --name <name>                 Set the cluster name."
    echo "   --description <description>   Set the cluster description (optional)."
    echo "   --type <slurm|torque>         Set the HPC cluster type (default 'slurm')."
    echo "   --user <string>               Set the user to access the master node."
    echo "   --address <URL>               Set the address of the cluster."
    echo "   --work-dir <string>           Set the work directory for the task data on the cluster"
    echo "   --partition <string>          Set the HPC cluster partition."
    echo "   --auth-token <string>         Set the authentication token (optional)."
    echo "   --url <URL>                   Set the base URL for the Resources manager service (default: localhost:8096)"
    echo "   --help                        Display this help message."
    echo ""
}

auth_token='eyJhbGciOiJIUzUxMiJ9.eyJ1c2VySWQiOiIwIiwicm9sZSI6IlNZU1RFTSIsImV4cCI6NDgxMjExNzkzNn0.91oYe8M2ZEl-M_la5te--jsI66gO3XIgAxAH-TXIKp7olWlEapLN_UZi2JSPfcdr23XRzn5BSUwzuFRbbx6P_A'
description=""
partition=""
cluster_type="slurm"
cluster_user=""
name=""
url="localhost:8096"

while [ $# -gt 0 ]; do
    case "$1" in
        --name)
            name="$2"
            shift 2
            ;;
        --description)
            description="$2"
            shift 2
            ;;
        --type)
            cluster_type="$2"
            shift 2
            ;;
        --user)
            cluster_user="$2"
            shift 2
            ;;
        --address)
            address="$2"
            shift 2
            ;;
        --work-dir)
            work_dir="$2"
            shift 2
            ;;
        --partition)
            partition="$2"
            shift 2
            ;;
        --auth-token)
            auth_token="Authorization-Internal: Bearer $2"
            shift 2
            ;;
        --url)
      	    url="$2"
      	    shift 2
            ;;
    	--help)
            display_help
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            display_help
            exit 1
            ;;
    esac
done

if [ -z "$name" ]; then
    echo "Error: --name parameter is missing"
    display_help
    exit 1
fi

if [ -z "$cluster_type" ]; then
    echo "Error: --type parameter is missing"
    display_help
    exit 1
fi

if [ -z "$cluster_user" ]; then
    echo "Error: --user parameter is missing"
    display_help
    exit 1
fi

if [ -z "$address" ]; then
    echo "Error: --address parameter is missing"
    display_help
    exit 1
fi

if [ -z "$work_dir" ]; then
    echo "Error: --work-dir parameter is missing"
    display_help
    exit 1
fi

cluster_json=$(cat << EOF
{
    "data": {
        "name": "${name}",
        "description": "${description}",
        "properties": {
            "type": "${cluster_type}",
            "defaultLogin": "${cluser_user}",
            "address": "${address}",
            "workDir": "${work_dir}",
            "partition": "${partition}"
        },
        "default": false
    }
}
EOF
)

cluster=$(curl -f -X POST "http://${url}/api/v1/cluster" -H 'Content-Type: application/json' -H "${auth_token}" -d "${cluster_json}")

echo "${cluster}"
echo "${cluster}" >> created_clusters.txt
