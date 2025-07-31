#!/bin/bash
#
# Bash Web Server
#
# A simple web server written purely in Bash with minimal dependencies.
#
# Author: Micah Kepe <micahkepe@gmail.com>
# License: MIT
#
# STYLE GUIDE
# -----------
# This project follows the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).

# Set safety options, see Man section on 'SHELL BUILTIN COMMANDS'
# -e = exit on error
# -u = treat unset variables as errors
# -o pipefail = exit if any command in a pipeline fails
set -eu
set -o pipefail

# Handle interrupts
trap 'echo -e "\nSIGINT received, exiting..."; exit 130' SIGINT   # 128 + 2
trap 'echo -e "\nSIGTERM received, exiting..."; exit 143' SIGTERM # 128 + 15

# Program arguments
PORT=8080
ADDRESS='0.0.0.0'
DIR=$(pwd)
VERBOSITY=0

# ANSI escape codes (constant)
readonly ANSI_RED="\033[31m"
readonly ANSI_GREEN="\033[32m"
readonly ANSI_YELLOW="\033[33m"
readonly ANSI_CYAN="\033[36m"
readonly ANSI_RESET="\033[0m"

# Check if output is a terminal
if [ ! -t 1 ]; then
  ANSI_RED=""
  ANSI_GREEN=""
  ANSI_YELLOW=""
  ANSI_CYAN=""
  ANSI_RESET=""
fi

#####################################
# Print usage message for this script
# Arguments:
#   None
# Outputs:
#   Writes usage message to stdout
#####################################
usage() {
  echo "Usage: bash web-server.sh [-p | --port=<port>] [-a | --address=<address>] [-d | --directory=<directory>] [-h | --help]"
  echo "Starts a web server on the specified port and address with the specified directory as the root."
  echo "Arguments:"
  echo "  -p <port>        Port to listen on (default: 8080)"
  echo "  -a <address>     Address to listen on (default: 0.0.0.0)"
  echo "  -d <directory>   Directory to serve (default: current directory)"
  echo "  -v | -vv | -vvv  Verbosity level (default: 0)"
  echo "  -h | --help      Show this help message and exit"
}

########################################
# Print timestamp in a consistent format (YYYY-MM-DD HH:MM:SS)
# Arguments:
#   None
# Outputs:
#   Writes timestamp to stdout
########################################
timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}

########################################
# Print debug message to stdout if verbosity is enabled
# Arguments:
#   None
# Outputs:
#   Writes message to stdout if verbosity is enabled
########################################
debug() {
  if [ ${VERBOSITY:-0} -ge 3 ]; then
    echo -e "${ANSI_CYAN}[$(timestamp)] [DEBUG][$$]${ANSI_RESET}" "$@" >&2
  fi
}

########################################
# Print info message to stdout if verbosity is enabled
# Arguments:
#   None
# Outputs:
#   Writes message to stdout if verbosity is enabled
########################################
info() {
  if [ ${VERBOSITY:-0} -ge 1 ]; then
    echo -e "${ANSI_GREEN}[$(timestamp)] [INFO] [$$]${ANSI_RESET}" "$@" >&2
  fi
}

########################################
# Print warning message to stdout if verbosity is enabled
# Arguments:
#   None
# Outputs:
#   Writes message to stdout if verbosity is enabled
########################################
warn() {
  if [ ${VERBOSITY:-0} -ge 0 ]; then
    echo -e "${ANSI_YELLOW}[$(timestamp)] [WARN] [$$]${ANSI_RESET}" "$@" >&2
  fi
}

########################################
# Print error message to stderr and exit with status 1
# Arguments:
#   None
# Outputs:
#   Writes message to stderr
# Returns:
#   Exits with status 1
########################################
error() {
  # shown unconditionally
  echo -e "${ANSI_RED}[$(timestamp)] [ERROR] [$$]${ANSI_RESET}" "$@" >&2
  exit 1
}

########################################
# Print fatal message to stderr and exit with status 1
# Arguments:
#   None
# Outputs:
#   Writes message to stderr
# Returns:
#   Exits with status 1
########################################
fatal() {
  # shown unconditionally
  echo -e "${ANSI_RED}[$(timestamp)] [FATAL] [$$]${ANSI_RESET}" "$@" >&2
  exit 1
}

########################################
# Parse command line arguments
# Globals:
#   PORT
#   ADDRESS
#   DIR
#   VERBOSITY
# Arguments:
#   None
# Outputs:
#   Writes usage message to stdout if --help is passed as an argument
# Returns:
#   Exits with status 1 if --help is passed as an argument
########################################
argparse() {
  while [ $# -gt 0 ]; do
    case $1 in
    -p=* | --port=*)
      PORT="${1#*=}"
      ;;
    -p | --port)
      if [ -n "$2" ]; then
        PORT="$2"
        shift
      else
        error "Port argument requires a value"
      fi
      ;;
    -a=* | --address=*)
      ADDRESS="${1#*=}"
      ;;
    -a | --address)
      if [ -n "$2" ]; then
        ADDRESS="$2"
        shift
      else
        error "Address argument requires a value"
      fi
      ;;
    -d=* | --directory=*)
      DIR=$(realpath "${1#*=}")
      ;;
    -d | --directory)
      if [ -n "$2" ]; then
        if [ -d "$2" ]; then
          DIR="$2"
        else
          error "Directory argument must be a valid directory"
        fi
        shift
      else
        error "Directory argument requires a value"
      fi
      ;;
    -v)
      VERBOSITY=1
      ;;
    -vv)
      VERBOSITY=2
      ;;
    -vvv)
      VERBOSITY=3
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
    esac
    shift
  done
}

accept() {
  # Response
  printf 'HTTP/1.1 200 OK\nContent-Type: text/plain\n\nHello, world!'
}

########################################
# Main function
# Globals:
#   PORT
#   ADDRESS
#   DIR
#   VERBOSITY
# Arguments:
#   None
# Outputs:
#   Writes usage message to stdout if --help is passed as an argument
# Returns:
#   Exits with status 1 if --help is passed as an argument
########################################
main() {
  argparse "$@"
  info "Starting web server on port $PORT at $ADDRESS with directory $DIR"
  info "View the server at http://$ADDRESS:$PORT"

  # Check for `ncat` utility
  if ! command -v ncat &>/dev/null; then
    fatal "netcat utility not found, please install it"
  fi

  # Export functions and variables for downstream subshells
  export -f accept

  # Listen for incoming connections
  while true; do
    ncat -l "$ADDRESS" "$PORT" -c accept
  done
}

main "$@"
