#!/bin/sh

# 新規ページの作成スクリプト
# 引数には content ディレクトリ配下のパスを拡張子抜きで指定する

if [ -z "$1" ]; then
  echo "Usage: $0 <作成年>/<new-file-name>"
  echo "Example: $0 2025/my-new-post"
  exit 1
fi

./hugo-base.sh new "content/$1.md"
