#!/bin/sh
# Docker イメージで Hugo を実行するスクリプトのベース
# サブコマンドを利用するので、これ単体で実行する必要はない

docker container run \
--rm \
-p 1313:1313 \
--platform linux/amd64 \
-v $(pwd):/src \
-w /src \
hugomods/hugo:reg-exts-0.154.5 \
hugo "$@"