#!/bin/bash

set -e

site=$1

if [ "X$site" != "Xiojs" ] && [ "X$site" != "Xnodejs" ]; then
  echo "Usage: upload_to_cloudflare.sh < iojs | nodejs > <version>"
  exit 1
fi

if [ "X$2" == "X" ]; then
  echo "Usage: upload_to_cloudflare.sh < iojs | nodejs > <version>"
  exit 1
fi

if [ -z ${dstdir+x} ]; then
  echo "\$dstdir is not set"
  exit 1
fi
if [ -z ${dist_rootdir+x} ]; then
  echo "\$dist_rootdir is not set"
  exit 1
fi
if [ -z ${destination_bucket+x} ]; then
  echo "\$destination_bucket is not set"
  exit 1
fi
if [ -z ${cloudflare_endpoint+x} ]; then
  echo "\$cloudflare_endpoint is not set"
  exit 1
fi
if [ -z ${cloudflare_profile+x} ]; then
  echo "\$cloudflare_profile is not set"
  exit 1
fi

relativedir=${dstdir/$dist_rootdir/"$site/"}
tmpversion=$2

aws s3 cp $dstdir/$tmpversion/ $destination_bucket/$relativedir/$tmpversion/ --endpoint-url=$cloudflare_endpoint --profile $cloudflare_profile --recursive --no-follow-symlinks
aws s3 cp $dstdir/index.json $destination_bucket/$relativedir/index.json --endpoint-url=$cloudflare_endpoint --profile $cloudflare_profile
aws s3 cp $dstdir/index.tab $destination_bucket/$relativedir/index.tab --endpoint-url=$cloudflare_endpoint --profile $cloudflare_profile
