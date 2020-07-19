---
title: "ディクショナリからタプルの配列を作成する"
date: 2020-07-20T08:22:03+09:00
draft: false
toc: true
tags: [ "iOS", "Swift" ]
---

# はじめに
- Swift には、連想配列的なデータ構造としてディクショナリがあります
- ディクショナリはデータの順序を保証しないので、そのままではテーブルビューやコレクションビューのデータソースとして利用しにくいです
- その場合は、タプルの配列に変換すると上手く行きます

# 検証環境
- Xcode 11.5
- Swift 5.2

# 利用する機能
## sorted(by:)
- ディクショナリのメソッド
- 引数に渡した関数 `by` がソート条件
    - 関数 `by` の引数
        - 2 つのタプル（それぞれディクショナリの n 番目の要素と n + 1 番目の要素に対応）
    - 関数 `by` の戻り値
        - `Bool`（`false` なら並び替え）
- 戻り値は `[(key: ディクショナリの key の型, value: ディクショナリの value の型)]`
    - つまり、ディクショナリとほぼ同じ構造を持った「タプルの配列」

# コード例
- 以下はディクショナリ `[String: Int]` からタプルの配列 `[(key: String, value: Int)]` に変換する例です

```swift:SortedDictionary.playground
import Foundation

var scores: [String: Int] = [
    "Steve Yamada": 34,
    "Jeff Takeshita": 87,
    "Mickey Yoshida": 100,
    "Charly Kinoshita": 53,
    "Anna Saito": 19,
    "Robert Suzuki": 97,
    "Erick Kawakami": 32,
    "John Miyabe": 64,
    "Gregory Goto": 76
]

print("""

    Ascending by key
    ========================
    """)
var sortedByNameAsc: [(key: String, value: Int)] = scores.sorted { $0.key < $1.key }
sortedByNameAsc.forEach { print("\($0.key): \($0.value)") }

print("""

    Descending by key
    ========================
    """)
var sortedByNameDesc: [(key: String, value: Int)] = scores.sorted { $0.key > $1.key }
sortedByNameDesc.forEach { print("\($0.key): \($0.value)") }

print("""

    Ascending by value
    ========================
    """)
var sortedByScoreAsc: [(key: String, value: Int)] = scores.sorted { $0.value < $1.value }
sortedByScoreAsc.forEach { print("\($0.value): \($0.key)") }

print("""

    Descending by value
    ========================
    """)
var sortedByScoreDesc: [(key: String, value: Int)] = scores.sorted { $0.value > $1.value }
sortedByScoreDesc.forEach { print("\($0.value): \($0.key)") }
```

```zsh:出力結果

Ascending by key
========================
Anna Saito: 19
Charly Kinoshita: 53
Erick Kawakami: 32
Gregory Goto: 76
Jeff Takeshita: 87
John Miyabe: 64
Mickey Yoshida: 100
Robert Suzuki: 97
Steve Yamada: 34

Descending by key
========================
Steve Yamada: 34
Robert Suzuki: 97
Mickey Yoshida: 100
John Miyabe: 64
Jeff Takeshita: 87
Gregory Goto: 76
Erick Kawakami: 32
Charly Kinoshita: 53
Anna Saito: 19

Ascending by value
========================
19: Anna Saito
32: Erick Kawakami
34: Steve Yamada
53: Charly Kinoshita
64: John Miyabe
76: Gregory Goto
87: Jeff Takeshita
97: Robert Suzuki
100: Mickey Yoshida

Descending by value
========================
100: Mickey Yoshida
97: Robert Suzuki
87: Jeff Takeshita
76: Gregory Goto
64: John Miyabe
53: Charly Kinoshita
34: Steve Yamada
32: Erick Kawakami
19: Anna Saito
```
# まとめ
- 状況に応じたデータの形式変換をする方法を押さえておくと、いろいろ応用ができそうですね
- 今回のサンプルは [GitHub: aokiplayer/swift-sandbox/SortedDictionary](https://github.com/aokiplayer/swift-sandbox/tree/master/SortedDictionary) に置きました
