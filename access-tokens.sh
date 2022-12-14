#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $(basename $0) <command> <token-path>"
    echo
    echo "Commands:"
    echo "    add: Add a new token at <token-path> (will auto-create parent directories)"
    echo "    view: View token at <token-path>"
    exit 1
fi

if [ "$1" = "add" ]; then
    if [ -e "$2" ]; then
        echo Token path already exists: $2
        exit 1
    fi
    
    # make sure token parent dir exists
    token_dir=$(dirname "$2")
    if [ ! -d "$token_dir" ]; then 
        mkdir -p $token_dir
        echo Created empty directory: $token_dir
    fi
    
    read -s -p "Enter access token value:" token_value
    echo
    if [ "$token_value" = "" ]; then
        echo Token value must not be empty
        exit 1
    fi

    # encrypt token value using openssl, will prompt user for password
    encrypted_token=$(echo $token_value | openssl aes-256-cbc -a -salt)
    
    if [ "$encrypted_token" != "" ]; then
        echo "$encrypted_token" > $2
    else
        echo Got empty encrypted token value, something probably went wrong
        exit 1
    fi
 
elif [ "$1" = "view" ]; then
    # decrypt token value using openssl, will prompt user for password
    cat $2 | openssl aes-256-cbc -a -salt -d

else
    echo Bad command: $1
    echo Commands: add/view
    exit 1
fi
