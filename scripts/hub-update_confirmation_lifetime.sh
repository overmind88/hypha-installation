#!/bin/bash

# Set default values
lifetime=""
url=""

# Help message
help_message() {
  echo "Usage: $0 --lifetime <value> --url <url>"
  echo "Arguments:"
  echo "  --lifetime <value>    Set the lifetime value for the request"
  echo "  --url <url>           Set the base URL for the Hub service"
  echo "  --help                Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --lifetime)
      lifetime="$2"
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

# Check if both parameters are provided
if [[ -z "$lifetime" ]] || [[ -z "$url" ]]; then
  echo "Please provide both --lifetime and --url parameters."
  exit 1
fi

# Use the values
RESULT=$(curl --location --insecure --request POST "$url/api/v1/admin/settings/confirmation/code/lifetime" \
--header 'Content-Type: application/json' \
         --data-raw '{
                "data": {
                   "lifeTime": "'$lifetime'"
                         }
                     }'
         )

echo "$RESULT"
