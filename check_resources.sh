#!/bin/sh

#
# a simple script to check Linux resources
# 

usage()
{
    echo "Script to validate whether resource requirements are met"
    echo ""
    echo "$0"
    echo "\t-h --help"
    echo "\t--memory=xxx (in MB)"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --memory)
            FREE_MEM_MB=`free --mega | awk '/Mem/ { print $4 }'`
            if [[ $VALUE > $FREE_MEM_MB ]]; then
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
