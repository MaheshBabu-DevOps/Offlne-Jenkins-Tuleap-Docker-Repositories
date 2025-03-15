#!/bin/bash
pushd /home/cair/Downloads/tuleap

echo "Tuleap repo sync start"

wget --force-html --recursive --mirror --continue https://ci.tuleap.net/yum/tuleap/rhel/9/dev/	x86_64/

echo "Tuleap repo sync done"

popd
