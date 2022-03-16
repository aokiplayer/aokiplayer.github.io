+++
title = "map と compactMap と flatMap"
date = "2020-11-10T16:08:03+09:00"
draft = false
toc = true
tags = [ "iOS", "Swift" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
コレクションとかいわゆる「何かの中に値が入ってるやつ」に対する代表的な操作として、 `map` があります。
が、 `map` にも亜種があって混乱しがちなので、整理しておきたいと思います。

なお、この記事では配列を例としています。
実際には、配列でもディクショナリでも Optional でも「入れ物」にあたるものは似たような操作が提供されています（全く同じではないですが）。

## map の種類
### map
配列内の各要素を変換します。全要素を変換するので、変換前後で要素数は変わりません。

![map.png?width=25pc](/images/maps/map.png?width=25pc)

### compactMap
`map` と同じですが、要素のうち `nil` は除外し、 Optional は unwrap します。 `nil` を除外するため、 `map` と異なり変換前後で要素数が変わる（減る）場合もあります。

![compactMap.png?width=25pc](/images/maps/compactMap.png?width=25pc)

### flatMap
配列がネストされている場合、内側の配列から要素を取り出して平坦な配列にします（二次元配列 -> 一次元配列）。

![flatMap1.png?width=25pc](/images/maps/flatMap1.png?width=25pc)


内側の「配列という **入れ物** 」を「Optional という **入れ物** 」に見立てれば「Optional の内容を取り出した配列」を作成することになり、 `compactMap` と同じ動作となります。

- `Array<Array<要素>` -（変換）-> `Array<要素>`
- `Array<Optional<要素>` -（変換）-> `Array<要素>`

![flatMap2.png?width=25pc](/images/maps/flatMap2.png?width=25pc)

`compactMap` が実装されていなかった Swift の初期のバージョンではこのような用途でも利用されていましたが、現在では deprecated です。素直に `compactMap` を使いましょう。

## サンプル
`map`, `compactMap`, `flatMap` を利用したサンプルです。
上記 4 つの図と比較しながら読んでみてください。

### コード例
```swift
import Foundation

enum Category: String, CustomStringConvertible {
    var description: String {
        self.rawValue
    }

    case personal
    case business
}

struct Item: CustomStringConvertible {
    var description: String {
        """
        name: "\(self.name)", price: \(self.price), categories: \(self.categories ?? [])

        """
    }

    let name: String
    let price: Int
    let categories: [Category]?
}

let items: [Item] = [
    Item(name: "Suit", price: 15000, categories: [.business]),
    Item(name: "Pen", price: 400, categories: [.personal, .business]),
    Item(name: "Sea", price: 99999, categories: nil),
    Item(name: "Drink", price: 120, categories: [.personal]),
    Item(name: "Sky", price: 99999, categories:nil),
    Item(name: "Comic", price: 600, categories: [.personal])
]

print("""
      == Items ==========
      \(items)

      """
)

// map transforms each element in an Array.
let map = items.map { item in
    item.categories ?? []
}
print("""
      == map "item.categories ?? []" ==========
      \(map)

      """
)

// compactMap is a map that only collect non-nil values.
let compact = items.compactMap { item in
    item.categories
}
print("""
      == compactMap "item.categories" ==========
      \(compact)

      """
)

// flatMap flattens the inner Array.
let flat1 = items.flatMap { item in
    item.categories ?? []
}
print("""
      == flatMap "item.categories ?? []" ==========
      \(flat1)

      """
)

// This type of flatMap is deprecated. You should use compactMap.
let flat2 = items.flatMap { item in
    item.categories
}
print("""
      == flatMap "item.categories" ==========
      \(flat2)

      """
)
```

### 実行結果
```zsh
== Items ==========
[name: "Suit", price: 15000, categories: [business]
, name: "Pen", price: 400, categories: [personal, business]
, name: "Sea", price: 99999, categories: []
, name: "Drink", price: 120, categories: [personal]
, name: "Sky", price: 99999, categories: []
, name: "Comic", price: 600, categories: [personal]
]

== map "item.categories ?? []" ==========
[[business], [personal, business], [], [personal], [], [personal]]

== compactMap "item.categories" ==========
[[business], [personal, business], [personal], [personal]]

== flatMap "item.categories ?? []" ==========
[business, personal, business, personal, personal]

== flatMap "item.categories" ==========
[[business], [personal, business], [personal], [personal]]
```

## まとめ
`map` については、図で表すとわかりやすいですね。この辺りの操作は Combine フレームワークでもよく使われるので、使いこなせると開発がとても楽になると思います。
