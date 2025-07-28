# Bash Web Server

A simple web server written in Bash with minimal dependencies.

## Usage

```
Usage: bash web-server.sh [-p | --port=<port>] [-a | --address=<address>] [-d | --directory=<directory>] [-h | --help]
Starts a web server on the specified port and address with the specified directory as the root.
Arguments:
  -p <port>        Port to listen on (default: 8080)
  -a <address>     Address to listen on (default: 0.0.0.0)
  -d <directory>   Directory to serve (default: current directory)
  -v | -vv | -vvv  Verbosity level (default: 0)
  -h | --help      Show this help message and exit
```

Starts a web server on the specified port and address with the specified
directory as the root, serving files from the current directory by default.
