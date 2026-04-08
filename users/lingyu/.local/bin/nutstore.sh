#!/bin/bash

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTION1] [OPTION2]...

Option1:
  -p, --push      rclone sync LOCAL REMOTE
  -c, --clone     rclone sync REMOTE LOCAL
  -h, --help      Show this help message

Option2:
  -o, --org       
  -k, --knowhub   
  -h, --help      Show this help message
EOF
}

case "$1" in
    "-h"|"--help")
	    show_help
	    exit 0
	    ;;
    "-p"|"--push")
        case "$2" in
            "-h"|"--help")
	            show_help
	            exit 0
	            ;;
            "-o"|"--org")
	            rclone sync "$HOME/org" "nutstore:WSL/org" \
                       --create-empty-src-dirs \
                       --exclude ".git/**" \
                       --exclude ".git" \
                       --transfers 2 \
                       --checkers 4 \
                       --low-level-retries 10 \
                       --retries 10 \
                       --retries-sleep 10s \
                       --progress
	            ;;
            "-k"|"--knowhub")
	            rclone sync "$HOME/knowhub" "nutstore:KnowledgeHub" \
                       --create-empty-src-dirs \
                       --transfers 2 \
                       --checkers 4 \
                       --low-level-retries 10 \
                       --retries 10 \
                       --retries-sleep 10s \
                       --progress
	            ;;
            *)
                show_help
	            exit 0
	            ;;
        esac
	    ;;
    "-c"|"--clone")
        case "$2" in
            "-h"|"--help")
	            show_help
	            exit 0
	            ;;
            "-o"|"--org")
	            rclone sync "nutstore:WSL/org" "$HOME/org"\
                       --create-empty-src-dirs \
                       --exclude ".git/**" \
                       --exclude ".git" \
                       --transfers 2 \
                       --checkers 4 \
                       --low-level-retries 10 \
                       --retries 10 \
                       --retries-sleep 10s \
                       --progress
	            ;;
            "-k"|"--knowhub")
	            rclone sync "nutstore:KnowledgeHub" "$HOME/knowhub"\
                       --create-empty-src-dirs \
                       --transfers 2 \
                       --checkers 4 \
                       --low-level-retries 10 \
                       --retries 10 \
                       --retries-sleep 10s \
                       --progress
	            ;;
            *)
                show_help
	            exit 0
	            ;;
        esac
	    ;;
    # "-b"|"--bisync")
    #     case "$2" in
    #         "-h"|"--help")
	#             show_help
	#             exit 0
	#             ;;
    #         "-o"|"--org")
	#             rclone bisync "$HOME/org" "nutstore:WSL/org" \
    #                    --create-empty-src-dirs \
    #                    --exclude ".git/**" \
    #                    --exclude ".git" \
    #                    --transfers 2 \
    #                    --checkers 4 \
    #                    --low-level-retries 10 \
    #                    --retries 10 \
    #                    --retries-sleep 10s \
    #                    --progress
	#             ;;
    #         "-k"|"--knowhub")
	#             rclone bisync "$HOME/knowhub" "nutstore:KnowledgeHub" \
    #                    --create-empty-src-dirs \
    #                    --transfers 2 \
    #                    --checkers 4 \
    #                    --low-level-retries 10 \
    #                    --retries 10 \
    #                    --retries-sleep 10s \
    #                    --progress
	#             ;;
    #         *)
    #             show_help
	#             exit 0
	#             ;;
    #     esac
	#     ;;
    *)
        show_help
	    exit 0
	    ;;
esac
