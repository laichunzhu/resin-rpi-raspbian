#!/bin/bash

set -o errexit
set -o pipefail

QEMU_VERSION='2.7.0-resin-rc2-arm'
QEMU_SHA256='2e65faa775b752b050516773338d61a29fe62c4c5fcd1186f972ffce3e205426'
MIRROR='http://archive.raspbian.org/raspbian'

# Download QEMU
curl -SLO https://github.com/resin-io/qemu/releases/download/qemu-$QEMU_VERSION/qemu-$QEMU_VERSION.tar.gz \
	&& echo "$QEMU_SHA256  qemu-$QEMU_VERSION.tar.gz" > qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& sha256sum -c qemu-$QEMU_VERSION.tar.gz.sha256sum \
	&& tar -xz --strip-components=1 -f qemu-$QEMU_VERSION.tar.gz

docker build -t raspbian-mkimage .

for suite in $SUITES; do

	rm -rf output
	mkdir -p output
	docker run --rm --privileged	-e REPO=$REPO \
									-e SUITE=$suite \
									-e MIRROR=$MIRROR \
									-e RESIN_QEMU_VERSION=$QEMU_VERSION \
									-v `pwd`/output:/output raspbian-mkimage

	docker build -t $REPO:$suite output/
done

rm -rf qemu*
