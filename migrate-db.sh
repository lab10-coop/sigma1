#!/bin/bash

# OpenEthereum 3.1 requires a manual migration of the DB

set -e
set -u

BIN=oe-upgrage-db-3-1
DBDIR=data/chains/sigma1.artis/db/2fe13bcc0f05fba8/overlayrecent

if [[ ! -d $DBDIR ]]; then
	echo "database dir to be migrated does not exist at $DBDIR"
	exit 1
fi

echo "downloading binary..."
curl -s -f https://dev.lab10.io/artis/$BIN > $BIN
chmod +x $BIN

echo "running migration..."
./$BIN $DBDIR
echo "done!"
rm $BIN
