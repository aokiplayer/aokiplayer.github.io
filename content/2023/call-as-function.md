+++
title = "SwiftUI の dismiss() って「関数()」じゃなくて「オブジェクト()」だよね？"
date = "2023-12-04T06:00:00+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftUI" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
SwiftUI で多用されている Property Wrappers ですが、基本的に「なんか難しいことをやってくれてる」感じになってます。頻繁に利用される `@Environment` も、「こう書けばこう動く」という感じで何となく使っている人が多いと思います。

ところで、Property Wrapper そのものの機能とは関係ないですが、以下のコードの `@Environment` の `dismiss()` の部分はよく考えると不思議な構文ではないでしょうか。

```swift
// ビューを閉じるための DismissAction を取得
@Environment(\.dismiss) private var dismiss: DismissAction

...

// ビューを閉じる
dismiss() // <--- オブジェクト() という構文？？？
```

`dismiss` は `DismissAction` 型のオブジェクトなので、本来なら以下の形式でないと辻褄が合いませんよね。

```swift
dismiss.何かメソッド名() // <--- オブジェクト.メソッド名() という構文ならわかる
```

## 検証環境
- Xcode 15.0
- Swift 5.9

## callAsFunction メソッド
実は、これは `dismiss.何かメソッド名()` の省略形です。
具体的には `dismiss.callAsFunction()` です。

### callAsFunction の例
例として、単に「足し算をするためだけの構造体」を用意し、`callAsFunction` メソッドを実装して利用してみます。

```swift: callAsFunction の例
import Foundation

// 足し算をするためだけの構造体
struct AddAction {
    public func callAsFunction(_ number1: Int, with number2: Int) -> Int {
        return number1 + number2
    }
}

let add = AddAction()

// 以下は add.callAsFunction(10, with: 20) の省略形
let result1 = add(10, with: 20)
print(result1)

// もちろん、メソッド名を書いても動作する
let result2 = add.callAsFunction(50, with: 100)
print(result2)
```

上記のコードでは、`add` は `AddAction` 型のオブジェクトですが、`add(10, with: 20)` の形で実行できていることがわかります。

冒頭で紹介した `DismissAction` にも `callAsFunction` メソッドが定義されているため、`dismiss()` と記述できます。

### callAsFunction 関数の仕様
- クラス、構造体、列挙型に宣言する
- メソッド名は `callAsFunction`
- 引数の型と数、戻り値の型は自由
- `オブジェクト.callAsFunction(引数)`の形式で利用

### 注意点
`callAsFunction` というメソッド名は何らかのプロトコルで規定されているわけではないため、定義時にスペルミスをしてもエラーにはならない点に注意が必要です。
呼び出し側のコードを書いている時に、`オブジェクト(引数)` で呼べないので気づくこととなるでしょう。

## まとめ
`callAsFunction` を積極的に定義する機会は多くないと思います。
しかし、Swift（特に SwiftUI）では意外と使われていたりするので、仕組みは知っておくと良いでしょう。

以前に書いた記事 [SwiftUI でサイズクラスに対応する](https://qiita.com/aokiplayer/items/a91213b953c2a805626a) でも、軽く触れています。

作成したサンプルは、[GitHub: aokiplayer/swift-sandboxCallAsFunction.playground](https://github.com/aokiplayer/swift-sandbox/tree/master/CallAsFunction) に置きました。

## 参考
- [Methods with Special Names (The Swift Programming Language)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations/#Methods-with-Special-Names)
- [callAsFunction() | DismissAction (Apple Developer Documentation)](https://developer.apple.com/documentation/swiftui/dismissaction/callasfunction())
