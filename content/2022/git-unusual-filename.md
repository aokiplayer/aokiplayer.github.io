+++
title = "いつも忘れる Git の設定（日本語ファイル名を正しく表示）"
date = "2022-03-16T14:59:46+09:00"
draft = false
toc = true
tags = [ "Git" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- この記事は、いつも必要だけどいつも忘れる設定なので、単なるメモとして作成してます

## Git でリポジトリをクローンしてくるといつも日本語ファイル名がエスケープされて正しく表示されないよね
- これを設定しておく（グローバルでやっちゃってもいいとは思うけど）

```zsh
git config --local core.quotepath false
```

## 参考
- Git の man より

```zsh
core.quotePath
           Commands that output paths (e.g.  ls-files, diff), will quote "unusual" characters in the
           pathname by enclosing the pathname in double-quotes and escaping those characters with
           backslashes in the same way C escapes control characters (e.g.  \t for TAB, \n for LF, \\ for
           backslash) or bytes with values larger than 0x80 (e.g. octal \302\265 for "micro" in UTF-8). If
           this variable is set to false, bytes higher than 0x80 are not considered "unusual" any more.
           Double-quotes, backslash and control characters are always escaped regardless of the setting of
           this variable. A simple space character is not considered "unusual". Many commands can output
           pathnames completely verbatim using the -z option. The default value is true.
```
