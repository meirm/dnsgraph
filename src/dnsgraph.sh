#!/bin/bash

# dnsgraph -- a bind statistics rrdtool frontend
#
# based on mailgraph by David Schweikert <dws@ee.ethz.ch>
# modified by Jicheng Qu
# modified by Przemyslaw Sztoch <navy@navy.wox.org>
#
# copyright (c) 2003
# released under the GNU General Public License
##################################################
if [ -f "/etc/default/dnsgraph" ]; then
    . /etc/default/dnsgraph
fi
#config
TARGET=${TARGET:-"/site/htdocs/dns"}
DNSANALISE=${DNSANALISE:-"/usr/local/bin/dnsanalise.pl"}
DNSREPORT=${DNSREPORT:-"/usr/local/bin/dnsreport.pl"}

$DNSANALISE $DNSANALISE_PARAMS -c
mkdir -p $TARGET
mkdir -p $TARGET/imgs
cd $TARGET
$DNSREPORT $DNSREPORT_PARAMS > index.html
chmod o+rx $TARGET
chmod o+rx $TARGET/imgs
chmod o+r -R $TARGET
