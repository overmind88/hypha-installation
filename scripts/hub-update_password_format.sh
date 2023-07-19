#!/bin/bash

# Set default values
url="localhost:8098"
min_length=8
max_length=255
diff_registers=true
letters=true
numbers=true
special_symbols=true
allowed_symbols="+.,?!"

# Help message
help_message() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --url <url>                       Set the base URL for the Hub service (default: localhost:8098)"
  echo "  --min-length <integer>            Set the minimum password length (default: 8)"
  echo "  --max-length <integer>            Set the maximum password length (default: 255)"
  echo "  --different-registers <true|false> Require different character registers (default: true)"
  echo "  --letters <true|false>            Require letters in password (default: true)"
  echo "  --numbers <true|false>            Require numbers in password (default: true)"
  echo "  --special-symbols <true|false>    Require special symbols in password (default: true)"
  echo "  --allowed-symbols <symbols>       Set allowed special symbols (default: '+.,?!')"
  echo "  --help                            Display this help message"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --url)
      url="$2"
      shift 2
      ;;
    --min-length)
      min_length="$2"
      shift 2
      ;;
    --max-length)
      max_length="$2"
      shift 2
      ;;
    --different-registers)
      diff_registers="$2"
      shift 2
      ;;
    --letters)
      letters="$2"
      shift 2
      ;;
    --numbers)
      numbers="$2"
      shift 2
      ;;
    --special-symbols)
      special_symbols="$2"
      shift 2
      ;;
    --allowed-symbols)
      allowed_symbols="$2"
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

# Use the values
RESULT=$(curl --location --request POST "$url/api/v1/admin/settings/password/update" \
         --header 'Content-Type: application/json' \
         --data-raw '{
                "data": {
                   "minLength": '$min_length',
                   "maxLength": '$max_length',
                   "differentRegistersRequired": '$diff_registers',
                   "lettersRequired": '$letters',
                   "numbersRequired": '$numbers',
                   "specialSymbolsRequired": '$special_symbols',
                   "allowedSpecialSymbols": "'$allowed_symbols'"
                         }
                     }'
         )

echo "$RESULT"