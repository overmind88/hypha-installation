#!/bin/bash

# Define usage function
usage() {
  echo "Usage: $0 --solver-id <solver_id> --solver-json <solver_json> [--auth-token <auth_token>] [--url <url>]"
  echo ""
  echo "Options:"
  echo "  --solver-id <string>         Set the solver ID"
  echo "  --solver-json <path>         Set the path to the solver JSON file"
  echo "  --auth-token <string>        Set the authentication token (optional)"
  echo "  --url <URL>                  Set the base URL for the Resources manager service (default: localhost:8096)"
  echo "  --help                       Display this help message"
  exit 1
}

# Set default values for optional parameters
auth_token="eyJhbGciOiJIUzUxMiJ9.eyJ1c2VySWQiOiIwIiwicm9sZSI6IlNZU1RFTSIsImV4cCI6NDgxMjExNzkzNn0.91oYe8M2ZEl-M_la5te--jsI66gO3XIgAxAH-TXIKp7olWlEapLN_UZi2JSPfcdr23XRzn5BSUwzuFRbbx6P_A"
url="localhost:8096"

# Parse named parameters
while [ "$#" -gt 0 ]; do
  case $1 in
    --solver-id)
      solver_id="$2"
      shift 2
      ;;
    --solver-json)
      solver_json="$2"
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
if [ -z "$solver_id" ]; then
  echo "Error: --solver-id is required."
  echo ""
  usage
fi

if [ -z "$solver_json" ]; then
  echo "Error: --solver-json is required."
  echo ""
  usage
fi

# Send the request
auth_header="Authorization-Internal: Bearer ${auth_token}"
solver=$(curl -f -X PATCH "http://${url}/api/v1/solver/${solver_id}" -H 'Content-Type: application/json' -H "${auth_header}" -d "@${solver_json}")

echo "${solver}"
