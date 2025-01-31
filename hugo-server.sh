#!/bin/sh

# Hugo Server の起動スクリプト
# Hugo Server は、執筆中にローカルでプレビューするための Web サーバー
# 起動後、 http://localhost:1313/ にアクセスすると、コンテンツが表示される

./hugo-base.sh server -D --bind 0.0.0.0
