#!/bin/bash

# Set default values
url="localhost:8098"
license_file=""

# Help message
help_message() {
  echo "Usage: $0 --license-file <file> [--url <url>]"
  echo "Options:"
  echo "  --license-file <file>  Set the path to the license file. To obtain the license file please visit www.mycesys.com"
  echo "  --url <url>            Set the base URL for the Hub service (default: localhost:8098)"
  echo "  --help                 Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --license-file)
      license_file="$2"
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

# Check if the license file is provided
if [ -z "$license_file" ]; then
  echo "License file is not specified. Use --license-file <file> to provide the path."
  exit 1
fi

# Read the license and send the request
license=$(cat "$license_file")
RESULT=$(curl --location --request POST "$url/system/license/user" \
         --header 'Content-Type: application/json' \
         --data-raw '{
             "data": {
                 "license": "'"$license"'"
             }
         }')

echo "$RESULT"