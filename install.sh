#!/bin/bash

(cd src/; chmod +x dnsanalise.pl dnsgraph.sh dnsreport.pl;
if [ $UID -eq 0 ] ; then
	BIN_DIR=/usr/local/bin
	CONF_DIR=/etc/default
else
	BIN_DIR=$HOME/bin
	CONF_DIR=$HOME/.config
	mkdir -p $BIN_DIR $CONF_DIR
fi
	
(cd src/ && cp dnsanalise.pl dnsgraph.sh dnsreport.pl $BIN_DIR/)
(cp etc/default/dnsgraph $CONF_DIR/dnsgraph)
