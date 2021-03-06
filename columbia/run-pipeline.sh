 #!/bin/bash

source constants.sh

trap "kill 0" EXIT

# TODO: find out why, need to prefix capture in /tmp directory
#       - have to use chmod 1777 on directory for it to work

if [ -z $1 ]
then
    echo "Usage: ./run_pipeline <experiment_name>"
else
    # Get the experiment name
    BASENAME=$1

    # Get the current Date/Time
    current_time=$(date "+%Y-%m-%d-%H%M")

    # Create a unique label for this experiment
    DIRNAME=$BASENAME-$current_time

    # TODO: create a random prefix every X hours and restart the scripts for new anonymization
    #       keep the same time started for the script, even though the script is changing
    PREFIX=""

    # Create Directories for files/logs
    mkdir -p /tmp/pcaps/$DIRNAME/ssl
    mkdir -p /tmp/pcaps/$DIRNAME/dns
    mkdir -p logs

    # Set the permissions to be readable/writeable by 'tcpdump'
    chmod 1777 /tmp/pcaps/$DIRNAME
    chmod 1777 /tmp/pcaps/$DIRNAME/ssl
    chmod 1777 /tmp/pcaps/$DIRNAME/dns

    # Start the capture scripts
    ./scripts/capture/capture.sh /tmp/pcaps/$DIRNAME/$DIRNAME.pcapng &> logs/$DIRNAME-default-capturelog.txt &
    ./scripts/capture/capture-ssl.sh /tmp/pcaps/$DIRNAME/ssl/$DIRNAME-ssl.pcapng &> logs/$DIRNAME-ssl-capturelog.txt &
    #    ./scripts/capture/capture-dns.sh /tmp/pcaps/$DIRNAME/dns/$DIRNAME-dns.pcapng &> logs/$DIRNAME-dns-capturelog.txt &

    # Start the export scripts
    ./scripts/export/export.sh /tmp/pcaps/$DIRNAME/$DIRNAME.pcapng &> logs/$DIRNAME-default-exportlog.txt &
    ./scripts/export/export-ssl.sh /tmp/pcaps/$DIRNAME/ssl/$DIRNAME-ssl.pcapng &> logs/$DIRNAME-ssl-exportlog.txt &
    #    ./scripts/export/export-dns.sh /tmp/pcaps/$DIRNAME/dns/$DIRNAME-dns.pcapng &> logs/$DIRNAME-dns-exportlog.txt &

    # Start the upload scripts
    ./scripts/upload/upload.sh /tmp/pcaps/$DIRNAME &> logs/$DIRNAME-default-uploadlog.txt &
    ./scripts/upload/upload-ssl.sh /tmp/pcaps/$DIRNAME/ssl &> logs/$DIRNAME-ssl-uploadlog.txt &
    #    ./scripts/upload/upload-dns.sh /tmp/pcaps/$DIRNAME/dns &> logs/$DIRNAME-dns-uploadlog.txt &
fi

wait

## AFTER SCRIPT EXITS RUN:
# ./cleanup.sh /tmp/pcaps/$DIRNAME
# ./cleanup.sh /tmp/pcaps/$DIRNAME/ssl
# ./cleanup.sh /tmp/pcaps/$DIRNAME/dns
