#!/bin/bash

set -e
set -u

BIN_LINUX="https://releases.parity.io/ethereum/v2.1.6/x86_64-unknown-linux-gnu/parity"
SHA256_LINUX="542f18da9e4291d98938d3c59cd87c1798bf9b4b7e535cf3321c848934fbdbdb"

BIN_DARWIN="https://releases.parity.io/ethereum/v2.1.6/x86_64-apple-darwin/parity"
SHA256_DARWIN="d3f6ed4261f283a1c774b5595cf492377c659c3a749ec0abb3d370acc9da0cd1"

# param_1: message to be printed before exiting
function giving_up {
	echo $1
	exit 1
}

# calculates the checksum of file "parity" and compares it to the expected_checksum. Exits on mismatch.
# param_1: expected checksum
function check_integrity {
	expected_checksum=$1
	file_checksum=$(sha256sum parity | cut -f 1 -d " ")
	echo "file checksum: $file_checksum"

	if [[ $file_checksum != $expected_checksum ]]; then
		echo "### Checksum verification failed. calculated: $file_checksum | expected: $expected_checksum"
		rm parity
		giving_up ""
	fi
}

if [ -f parity ]; then
    giving_up "A file named parity already exists in this folder. If you want to replace it, please delete it and then run this script again"
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	echo "This looks like a Linux machine..."
	curl -f $BIN_LINUX > parity
	check_integrity $SHA256_LINUX
	chmod +x parity
elif [[ "$OSTYPE" == "darwin"* ]]; then
	echo "This looks like a Mac..."
	curl -f $BIN_DARWIN > parity
	# todo: find pre-installed tool for sha256 calc
#	check_integrity $SHA256_DARWIN
	chmod +x parity
else
	echo "### Sorry, I can't handle this platform: $OSTYPE"
	giving_up "Please manually download or build a parity binary compatible with your platform."
fi

echo
echo "Parity was successfully downloaded and verified!"
