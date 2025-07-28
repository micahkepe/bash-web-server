#!/bin/bash

# Set safety options
# set -euxo pipefail

# Handle interrupts
trap 'echo -e "\nExiting..."' EXIT

# Constants
PORT=8080
ADDRESS='0.0.0.0'
DIR=$(pwd)
VERBOSITY=0

ANSI_RED="\033[31m"
ANSI_GREEN="\033[32m"
ANSI_YELLOW="\033[33m"
ANSI_CYAN="\033[36m"
ANSI_RESET="\033[0m"

# Check if output is a terminal
if [ ! -t 1 ]; then
  ANSI_RED=""
  ANSI_GREEN=""
  ANSI_YELLOW=""
  ANSI_CYAN=""
  ANSI_RESET=""
fi

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

timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}

debug() {
  if [ $VERBOSITY -ge 3 ]; then
    echo -e "${ANSI_CYAN}[$(timestamp)] [DEBUG][$$]${ANSI_RESET}" "$@" >&2
  fi
}

info() {
  if [ $VERBOSITY -ge 1 ]; then
    echo -e "${ANSI_GREEN}[$(timestamp)] [INFO] [$$]${ANSI_RESET}" "$@" >&2
  fi
}

warn() {
  if [ $VERBOSITY -ge 0 ]; then
    echo -e "${ANSI_YELLOW}[$(timestamp)] [WARN] [$$]${ANSI_RESET}" "$@" >&2
  fi
}

error() {
  # shown unconditionally
  echo -e "${ANSI_RED}[$(timestamp)] [ERROR] [$$]${ANSI_RESET}" "$@" >&2
  exit 1
}

fatal() {
  # shown unconditionally
  echo -e "${ANSI_RED}[$(timestamp)] [FATAL] [$$]${ANSI_RESET}" "$@" >&2
  exit 1
}

# Parse command line arguments
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
    DIR="${1#*=}"
    ;;
  -d | --directory)
    if [ -n "$2" ]; then
      DIR="$2"
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

main() {
  echo "Starting web server on port $PORT at $ADDRESS with directory $DIR"

  warn "This is a warning message"
  info "This is a info message"
  debug "This is a debug message"

  # Loadable functions
  # FIX: these don't come shipped with MacOS
  enable accept || fatal "Failed to enable accept"
}

main "$@"
