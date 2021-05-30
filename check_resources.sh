#!/bin/sh

#
# a simple script to check Linux resources
# 

usage()
{
    echo "Script to validate whether resource requirements are met"
    echo ""
    echo "$0"
    echo "-h --help"
    echo "--memory=xxx (in MB)"
    echo ""
    echo "For example: curl -s https://raw.githubusercontent.com/exergy-connect/TOOL/main/check_resources.sh | \\
                       bash -s -- --memory=10000"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit 0
            ;;
        --memory)
            FREE_MEM_MB=`free --mega | awk '/Mem/ { print $4 }'`
            if [ "$VALUE" -gt "$FREE_MEM_MB" ]; then
              echo "Insufficient free memory: Need $VALUE MB, got $FREE_MEM_MB MB"
              exit 2
            else
              echo "Free memory OK (need $VALUE MB, got $FREE_MEM_MB MB)"
            fi
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

echo "All requirements satisfied!"
exit 0
