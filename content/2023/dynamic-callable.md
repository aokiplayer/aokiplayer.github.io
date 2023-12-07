+++
title = "Swift の dynamicCallable を利用して「オブジェクト(引数)」の形でメソッドを呼び出す"
date = "2023-12-05T06:00:00+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftUI" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
以前の記事 [SwiftUI の dismiss() って「関数()」じゃなくて「オブジェクト()」だよね？]({{< ref "/2023/call-as-function.md">}}) で、`callAsFunction` メソッドについて説明しました。
簡単に説明すると、型に `callAsFunction` という名前のメソッドを定義すると、`オブジェクト(引数)`のような形でメソッドを呼び出せるようになる仕組みです。

SwiftUI の DismissAction が、そのような形をとっていました。

```swift
// ビューを閉じるための DismissAction を取得
@Environment(\.dismiss) private var dismiss: DismissAction

...

// ビューを閉じる
dismiss() // <--- dismiss.callAsFunction() の省略形
```

似たような仕組みがもうひとつあるので、今回はそちらについて紹介します。

## 検証環境
- Xcode 15.0
- Swift 5.9

## dynamicCallable
`@dynamicCallable` で修飾した型には、以下のいずれかのメソッドの実装が必須となります。
メソッドの定義漏れやスペルミスをコンパイル時に気づける点が、`callAsFunction` とは異なりますね。

| メソッド | 説明 |
|:-|:-|
| `dynamicallyCall(withArguments:)` | 引数は `ExpressibleByArrayLiteral` プロトコルに準拠した型（配列など） |
| `dynamicallyCall(withKeywordArguments:)` | 引数に `ExpressibleByDictionaryLiteral` プロトコルに準拠した型（ディクショナリなど） |

### dynamicallyCall(withArguments:) メソッド
`dynamicallyCall(withArguments:)` は、可変長の引数を受け取れます。
メソッドの定義時には引数に配列などを指定しますが、メソッド名を省略した呼び出しの際には個別の値（本来、配列の要素とすべき値）をカンマ区切りで複数指定できます。

#### dynamicallyCall(withArguments:) の例
```swift:dynamicallyCall(withArguments:) の例
import Foundation

// 足し算をするためだけの構造体
@dynamicCallable
struct AddAction {
    // 引数はExpressibleByArrayLiteralに準拠した型とする
    public func dynamicallyCall(withArguments args: [Int]) -> Int {
        return args.reduce(0, +)
    }
}

let add = AddAction()

// 以下は add.dynamicallyCall(withArguments: [10, 20, 30]) の省略形
// この際、引数の配列は展開した状態で渡せる
let result1 = add(10, 20, 30)
print(result1)

// メソッド名を記載した際には、引数は配列として渡す必要がある
let result2 = add.dynamicallyCall(withArguments: [10, 20, 30, 40])
print(result2)
```

実行結果
```zsh:実行結果
60
100
```

### dynamicallyCall(withKeywordArguments:) メソッド
`dynamicallyCall(withKeywordArguments:)` は、ラベル付き引数を複数指定できます。
Swift では関数やメソッドの引数ラベルはその宣言時に決めておく必要がありますが、`dynamicallyCall(withKeywordArguments:)` では呼び出し時に任意のラベルを指定できます。

#### dynamicallyCall(withKeywordArguments:) の例
```swift:dynamicallyCall(withKeywordArguments:) の例
import Foundation

// 足し算をするためだけの構造体
@dynamicCallable
struct AddAction {
    // 引数はExpressibleByDictionaryLiteralに準拠した型とする
    public func dynamicallyCall(withKeywordArguments args: [String: Int]) -> Int {
        var sum = 0
        
        print("[引数リスト]")
        
        for (name, value) in args {
            print("  \(name), \(value)")
            sum += value
        }
        
        return sum
    }
}

let add = AddAction()

// メソッド名は省略でき、引数のラベルと個数は自由に設定できる
let result1 = add(a: 10, b: 20, c: 30)
print("合計: \(result1)", terminator: "\n\n")

// メソッド名は省略でき、引数のラベルと個数は自由に設定できる
let result2 = add(x: 5, y: 10)
print("合計: \(result2)", terminator: "\n\n")

// メソッド名を記載した際には、引数はディクショナリとして渡す必要がある
// キーはStringなので、ダブルクォートで囲む
let result3 = add.dynamicallyCall(withKeywordArguments: ["num1": 20, "num2": 40])
print("合計: \(result3)", terminator: "\n\n")
```

実行結果
```zsh:実行結果
[引数リスト]
  c, 30
  a, 10
  b, 20
合計: 60

[引数リスト]
  y, 10
  x, 5
合計: 15

[引数リスト]
  num2, 40
  num1, 20
合計: 60
```

### dynamicallyCall(withKeywordArguments:) の例 2
通常、Swift では同じ引数ラベルを複数指定できません。
しかし、`dynamicallyCall(withKeywordArguments:)` の引数を `KeyValuePairs`（ディクショナリ同様、`ExpressibleByDictionaryLiteral` プロトコルに準拠）とすることにより、同じ引数ラベルを複数指定することも可能となります。

例として、同じ引数ラベルを複数指定し、ラベルごとの数値の合計を求める機能を作成してみます。

```swift:dynamicallyCall(withKeywordArguments:) の例 2
import Foundation

// 足し算をするためだけの構造体
@dynamicCallable
struct AddAction {
    // 引数はExpressibleByDictionaryLiteralに準拠した型とする
    // KeyValuePairs型なら、同じラベルの引数を複数指定できる（ディクショナリではキーを重複できない）
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> [String: Int] {
        var sum = 0
        
        let groupedSum = Dictionary(grouping: args, by: { $0.key })
            .mapValues { values in
                values.compactMap { key, value in
                    value
                }
                .reduce(0, +)
            }

        return groupedSum
    }
}

let add = AddAction()

// メソッド名は省略でき、引数のラベルと個数は自由に設定できる
// 今回は引数をKeyValuePairs型にしているので、キーの重複もOK
let result1 = add(john: 3, mary: 5, mary: 2, john: 4, ben: 10, john: 8, ben: 9)
print("個人別の合計点数")
print(result1, terminator: "\n\n")

// メソッド名を記載した際には、引数はディクショナリとして渡す必要がある
// キーはStringなので、ダブルクォートで囲む
let result2 = add.dynamicallyCall(withKeywordArguments: [
    "john": 3, "mary": 5, "mary": 2, "john": 4, "ben": 10, "john": 8, "ben": 9
])
print("個人別の合計点数")
print(result2, terminator: "\n\n")
```

実行結果
```zsh:実行結果
個人別の合計点数
["ben": 19, "john": 15, "mary": 7]

個人別の合計点数
["mary": 7, "ben": 19, "john": 15]
```

## まとめ
`dynamicCallable` を利用すると、引数が`callAsFunction` メソッドよりも柔軟に指定できますね。
また、定義時にメソッド名にミスがあればコンパイルエラーとして気づける点もありがたいです。

ただし、受け入れる引数のラベルと個数を宣言時に固定できない点には注意が必要です。

作成したサンプルは、[GitHub: aokiplayer/swift-sandboxCallAsFunction.playground](https://github.com/aokiplayer/swift-sandbox/tree/master/CallAsFunction) に置きました。

## 参考
- [Methods with Special Names (The Swift Programming Language)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations/#Methods-with-Special-Names)
