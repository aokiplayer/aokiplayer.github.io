---
title: "asr restore による Mac の起動ボリュームのリストア"
date: 2019-10-15T13:22:13+09:00
draft: false
toc: true
tags: [ "macOS" ]
---

## はじめに
- Apple 標準の asr コマンドを利用して、 Mac の起動ボリューム（デフォルトでは Macintosh HD）をリストアする方法です
- とはいえ、起動ボリュームか否かは関係なく、どのボリュームでも扱い方は同じです
    - むしろ、起動可能なボリュームのイメージ作成の方にコツがある
    - 今回は、イメージ作成についての詳細には触れません

## 検証環境
- MacBook Pro without T2 Security Chip (-2017)
- MacBook Pro with T2 Security Chip (2018-)
- macOS Mojave 10.14.6

## asr コマンド
- asr は、 Apple Software Restore の略であり、その名の通りリストアを目的としたコマンドです
- Apple がどこまで公式にサポートしているのかはわかりませんが、起動ボリューム自体もリストア可能です
    - ソースとなるディスクイメージの作成方法にコツがあったり、いろいろ苦労はありますが…
- 主に利用するのは、 `asr restore` の形式です

### asr restore
- `asr restore` は、以下のような形式で記述します

```
asr restore --source リカバリ元のディスクイメージやボリューム --target リカバリ先のディスクやボリューム --erase
```

#### オプションの説明
- `--source or -s`
    - リカバリ元のソースを指定
    - ディスクイメージ でもいいし、それをマウントしたボリュームでも OK
        - DMG 形式はそのまま指定できるが、 Sparse Bundle などではマウントしなければ指定不可能
- `--target or -t`
    - リカバリ先のターゲットを指定
    - `/Volume/...` のようにボリュームを指定しても、 `/disk/disk1s2` のようにディスクを指定する形式でも OK
- `--erase` リストア先のデータを削除する

## 利用例
### トレーニング用に複数 Mac をリストアする
- [iOSDC 2019 に Mac の環境構築に関する内容で登壇してきました]({{< ref "/2019/iosdc2019day1.md">}}) でご紹介したように、トレーニング環境のセットアップに利用しています
    - 全受講者の環境を、完全に揃えることができるメリットは大きいです
    - iOSDC での発表時から、利用する方法は若干変わってます（T2 Security Chip 搭載の Mac への対応のため）

#### 手順
1. あらかじめ、全 Mac にパーティションを切っておく（ここでは Setup というパーティションとする）
2. [Carbon Copy Cloner](https://bombich.com/) （以下、 CCC）を使って、リストアイメージを格納したディスクイメージを作成する（ここでは Setup.sparsebundle とする）
    - CCC を利用するのは、 Disk Utility で作成したイメージから戻すと bless に失敗して起動できず、その対処方法がわからなかったためです
    - T2 Security Chip あり/なしの Mac 間では、同じイメージを使い回すことはできません
3. イメージを全リストア対象の Mac の Setup パーティションにコピーする（残念ながらここは手作業）
4. `asr restore` でリストア（2,3 分で完了）

## 最後に
- Apple としてはモノリシックイメージからのリストアは推奨していないものの、 asr コマンドについては WWDC 2019 のセッションで紹介しています
    - [What's New in Apple File Systems](https://developer.apple.com/videos/play/wwdc2019/710/)
- APFS や T2 Security Chip との付き合い方は考える必要がありますが、学校やトレーニング企業ではイメージからのリストアは必須なので、今後も引き続き使い方を探っていきます
