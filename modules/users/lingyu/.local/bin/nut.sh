#!/usr/bin/env sh

case "$0" in
    sh|bash|dash|ksh|zsh|-sh|-bash)
        echo "Do not source this script. Execute it as a normal program." >&2
        return 1 2>/dev/null || exit 1
        ;;
esac

show_help_info() {
    cat << EOF
Usage:
  $(basename "$0") --push LOCAL_PATH REMOTE_SUBPATH [RCLONE_OPTIONS...]
  $(basename "$0") --pull REMOTE_SUBPATH LOCAL_PATH [RCLONE_OPTIONS...]
  $(basename "$0") -h | --help

Options:
  -h, --help                Show this help message
  push                      Sync from LOCAL_PATH to nutstore:REMOTE_SUBPATH
  pull                      Sync from nutstore:REMOTE_SUBPATH to LOCAL_PATH

Examples:
  $(basename "$0") --push /home/user/data data
  $(basename "$0") --pull data /home/user/data
  $(basename "$0") --push /home/user/data data --exclude .git --exclude node_modules
  $(basename "$0") --pull data /home/user/data --exclude '*.tmp' --dry-run

Notes:
  - REMOTE_SUBPATH is relative to the root of nutstore remote (no leading / or ./)
  - LOCAL_PATH can be absolute or relative
  - Any additional arguments after the first three are passed directly to 'rclone sync'.
    This allows you to use any rclone flags (e.g., --exclude, --dry-run, --bwlimit).

EOF
}

show_error_info() {
    echo "[ERROR] Invalid Command!"
    echo
    show_help_info
}

rclone_sync () {
    source="$1"
    destination="$2"
    shift 2
    rclone sync "$source" "$destination" \
           --create-empty-src-dirs \
           --transfers 1 \
           --checkers 1 \
           --tpslimit 1 \
           --order-by "size,ascending" \
           --fast-list \
           --retries 5 \
           --retries-sleep 30s \
           --low-level-retries 5 \
           --timeout 2m \
           --progress "$@"
}

case "${1:-}" in
    "-h"|"--help")
	    show_help_info
	    exit 0
	    ;;
    "")
        show_error_info
	    exit 1
	    ;;
    "push")
        case "${2:-}" in
            "-h"|"--help")
	            show_help_info
	            exit 0
	            ;;
            "")
                show_error_info
	            exit 1
	            ;;
            *)
                case "${3:-}" in
                    "")
                        show_error_info
	                    exit 1
	                    ;;
                    *)
                        local_path="$2"
                        remote_subpath="$3"
                        shift 3
                        rclone_sync "$local_path" "nutstore:$remote_subpath" "$@"
	                    ;;
                esac
	            ;;
        esac
        ;;
    "pull")
        case "${2:-}" in
            "-h"|"--help")
	            show_help_info
	            exit 0
	            ;;
            "")
                show_error_info
	            exit 1
	            ;;
            *)
                case "${3:-}" in
                    "")
                        show_error_info
	                    exit 1
	                    ;;
                    *)
                        remote_subpath="$2"
                        local_path="$3"
                        shift 3
	                    rclone_sync "nutstore:$remote_subpath" "$local_path" "$@"
	                    ;;
                esac
	            ;;
        esac
        ;;
    *)
        show_error_info
	    exit 1
        ;;
esac
