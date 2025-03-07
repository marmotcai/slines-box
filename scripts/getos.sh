#!/bin/sh
OS=Unknown
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/redhat-release ]; then
        echo "Redhat Linux detected."
        OS=redhat
    elif [ -f /etc/SuSE-release ]; then
        echo "Suse Linux detected."
        OS=suse
    elif [ -f /etc/arch-release ]; then
        echo "Arch Linux detected."
        OS=arch
    elif [ -f /etc/mandrake-release ]; then
        echo "Mandrake Linux detected."
        OS=mandrake
    elif [ -f /etc/debian_version ]; then
        echo "Ubuntu/Debian Linux detected."
        OS=ubuntu/debian
    else
        OS=unknown
        echo "Unknown Linux distribution."
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac OS (Darwin) detected."
    OS=macos
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo "FreeBSD detected."
    OS=FreeBSD
else
    echo "Unknown operating system."
    OS=unknown
fi
