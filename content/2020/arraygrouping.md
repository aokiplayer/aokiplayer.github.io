+++
title = "配列要素をグループ化したディクショナリの作成"
date = "2020-07-16T08:39:32+09:00"
draft = false
toc = true
tags = [ "iOS", "Swift" ]
aliases = [ "/posts/arraygrouping/" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- テーブルビューやコレクションビューで、グループ化した表示はよく使います
- その場合、データソースとして二次元配列などを利用すると思います
- が、データソースが一次元配列だった場合は、少しデータの加工が必要ですよね

## 検証環境
- Xcode 11.5
- Swift 5.2

## 利用する機能
### Dictionary(grouping: by:)
- ディクショナリのイニシャライザ
- `grouping`
    - 元データとなる配列
    - `by` で指定した key ごとに、部分配列として分割される
- `by`
    - グループ化したディクショナリの key となる値を返す関数
    - 引数は、配列の各要素

## コード例
- 配列 `[Product]` を、 `Product` の要素である `category`（`Product.Category` 型）ごとにグループ化するサンプル
- 変換後のディクショナリは `[Product.Category: [Product]]` 型

### サンプルコード
```swift:ArrayGrouping.playground
import Foundation

struct Product: CustomStringConvertible {
    var description: String {
        "(\(self.name), $\(self.price), \(self.category))"
    }

    var name: String
    var price: Int
    var category: Category

    enum Category: String {
        case food
        case drink
        case other
    }
}

// Array of Product
var products: [Product] = [
    Product(name: "Fried Potato", price: 24, category: .food),
    Product(name: "Water", price: 12, category: .drink),
    Product(name: "Dish", price: 40, category: .other),
    Product(name: "Chai", price: 5, category: .drink),
    Product(name: "Fork", price: 56, category: .other),
    Product(name: "Bread", price: 35, category: .food),
    Product(name: "Noodle", price: 80, category: .food),
    Product(name: "Coffee", price: 98, category: .drink),
]

print(
    """

    Elements of Array
    ===========================================
    """
)
products.forEach { print($0) }

// Grouping by Category
var groupedProducts: [Product.Category: [Product]] = Dictionary(
    grouping: products,
    by: { $0.category }
)

print(
    """

    Grouping by Category
    ===========================================
    """
)
groupedProducts.forEach {
    print(
        """
        \($0.key.rawValue)
            \($0.value)
        """
    )
}
```

### 出力結果
```zsh:出力結果

Elements of Array
===========================================
(Fried Potato, $24, food)
(Water, $12, drink)
(Dish, $40, other)
(Chai, $5, drink)
(Fork, $56, other)
(Bread, $35, food)
(Noodle, $80, food)
(Coffee, $98, drink)

Grouping by Category
===========================================
food
    [(Fried Potato, $24, food), (Bread, $35, food), (Noodle, $80, food)]
other
    [(Dish, $40, other), (Fork, $56, other)]
drink
    [(Water, $12, drink), (Chai, $5, drink), (Coffee, $98, drink)]
```

## まとめ
- 配列要素を任意のグループにまとめられるので、とても便利ですね
- 今回のサンプルは [GitHub: aokiplayer/swift-sandbox/ArrayGrouping](https://github.com/aokiplayer/swift-sandbox/tree/master/ArrayGrouping) に置きました
