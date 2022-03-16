+++
title = "MACアドレスを取得してファイルに書き出すシェルスクリプト"
date = "2019-08-02T21:49:24+09:00"
draft = false
toc = true
tags = ["Mac", "Shell Script"] 
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- トレーニングをお客様先で実施する際、持ち込んだMacを現地のWiFiに接続するためにMACアドレスを求められる場合があります
- 未認証のデバイスを接続させないため、MACアドレスでフィルタリングを掛ける目的です
- 手作業で取得するのは辛いので、シェルスクリプトを用意しました
- あとで集約する際のために、ファイル名にはMacのSerial Numberを付けるようにしました

## 検証環境
- macOS 10.14.6 Mojave

## シェルスクリプトの内容
```shell:getMACaddr.sh
#!/bin/sh

## GET Serial Number of this Mac
SERIAL=`ioreg -l | awk '/IOPlatformSerialNumber/ { if (gsub(/"/, "")) print $4 }'`

## Write MAC address of primary WiFi interfce in "{SERIAL NUMBER}.txt" on this user's Desktop
ifconfig en0 ether | awk '/ether/ { print $2 }' > ~/Desktop/${SERIAL}.txt
```

###  Serial Numberを取得して、変数に代入
```shell
SERIAL=`ioreg -l | awk '/IOPlatformSerialNumber/ { if (gsub(/"/, "")) print $4 }'`
```
 - `ioreg`で、ハードウェアデバイスとドライバの情報を取得
 - `awk`を利用して、以下の処理を実行
    - `IOPlatformSerialNumber`を含む行だけを抽出
        - `　　　　|   "IOPlatformSerialNumber" = "C0XXXXXXXXXX"`
    - `"`を除去する
        - `　　　　|   IOPlatformSerialNumber = C0XXXXXXXXXX`
    - スペースで区切った4つ目のフィールドを出力
        - `C0XXXXXXXXXX`

### WiFiインターフェイスのMACアドレスを取得し、ファイルに書き込み
```shell
ifconfig en0 ether | awk '/ether/ { print $2 }' > ~/Desktop/${SERIAL}.txt
```
- `ifconfig`でインターフェイスを指定して、MACアドレスの情報を取得
- `awk`を利用して、以下の処理を実行
    - `ether`を含む行だけを抽出
        - `　ether XX:XX:XX:XX:XX:XX　`
    - スペースで区切った2つ目のフィールドを出力
        - `XX:XX:XX:XX:XX:XX`
- デスクトップ上の、ファイル名`{Serial Number}.txt`のファイルに書き込み

## 最後に
- awkとか正規表現とか、いまだに苦手です
- 「こう書いたほうがいいよ」などあれば、教えてください！
- 作成したシェルスクリプト は、[aokiplayer/scripts](https://github.com/aokiplayer/scripts)に置きました
