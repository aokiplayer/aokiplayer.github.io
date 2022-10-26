+++
title = "Swift の型消去（Type Erasure）"
date = "2022-10-26T14:03:56+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftUI" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
SwiftUI をしっかり理解しようとすると、これまで意識しなくて良かった多くの言語機能を知る必要があり、なかなか苦労します。
その 1 つとして、型消去（Type Erasure）があります。
ずっとわかったようなわからないような感じだったので、腰を据えて調べてみました。
まだこれについては自信がないので、ご指摘などあれば GitHub から頂けるとうれしいです。

サンプルは [GitHub](https://github.com/aokiplayer/swift-sandbox/tree/master/TypeErasure.playground) に置きました。

## 前提: プロトコルに関する制約事項
Swift では、`associatedtype` を持つプロトコルは、型宣言に利用できません。
以下のコードでは、最下部で `Store` 型の変数を宣言しようとしていますが、コンパイルが通りません。
これは、`Store` の持つ `associatedtype` の型が確定しないためです。

```swift
// お店で扱う商品の種類
struct Drug {
    var item: String
}

/**
 何らかのお店を表すプロトコル.
 商品の種類は associatedtype により柔軟に指定できるようにしている.
 */
protocol Store {
    associatedtype T
    
    var kind: T { get }
    func kindsOfStore() -> T
}

/**
 具体的なお店（マツモトキヨシ）.
 associatedtype は Drug として確定.
 */
class MatsumotoKiyoshi: Store {
    var kind: Drug
    
    init(kind: Drug) {
        self.kind = kind
    }
    
    func kindsOfStore() -> Drug {
        return kind
    }
}

/**
 具体的なお店（赤ひげ）
 associatedtype は Drug として確定.
 */
class AkaHige: Store {
    var kind: Drug
    
    init(kind: Drug) {
        self.kind = kind
    }
    
    func kindsOfStore() -> Drug {
        return kind
    }
}

/**
 MatsumotoKiyoshi は Store プロトコルに準拠しているので問題なさそうだが、
 associatedtype を持つのでこの宣言はできない.
 */
var myStore1: Store = MatsumotoKiyoshi(kind: Drug(item: "絆創膏"))
```

## 型消去による解決
`associatedtype` を持ったオブジェクトを別の型にラップして、`associatedtype` をジェネリクスで表現できるようにしてみます。こうすることで、`Store` プロトコル型ではないものの、型宣言からは `MatsumotoKiyoshi` という具体的な型の情報を消去し、抽象的な `AnyStore` 型として表現できるようになります。

```swift
/**
 AnyStore は、Store に準拠したクラスの associatedtype をジェネリクスとして持つ.
 */
class AnyStore<T>: Store {
    // kind の型は、イニシャライザで決まる.
    var kind: T
    
    /**
     引数として、Store に準拠したオブジェクトを受け取る.
     where 句で、AnyStore の associatedtype T を引数で受け取ったオブジェクトの
     T と同じ型としている.
     */
    init<S: Store>(store: S) where T == S.T {
        self.kind = store.kind
    }

    func kindsOfStore() -> T {
        return kind
    }
}

/**
 具体型である MatsumotoKiyoshi ではなく、抽象型である AnyStore 型として宣言できている.
 このように、型消去により具体型情報を消去できていることがわかる.
 */
var myStore2: AnyStore<Drug>

myStore2 = AnyStore(store: MatsumotoKiyoshi(kind: Drug(item: "絆創膏")))
print(myStore2.kindsOfStore())
```

以下のように、配列の宣言としてももちろん利用可能です。

```swift
/**
 Store に準拠し、associatedtype として Drug を持つオブジェクトを格納できる配列.
 型消去により、`MatsumotoKiyoshi` だけでなく `AkaHige` も格納可能.
 */
var stores: [AnyStore<Drug>]

stores = [
    AnyStore(store: MatsumotoKiyoshi(kind: Drug(item: "歯ブラシ"))),
    AnyStore(store: AkaHige(kind: Drug(item: "毒マムシドリンク"))),
]

for store in stores {
    print(store.kindsOfStore())
}
```

## まとめ
実際には、Swift 5.1 で導入された Opaque Types により変数の宣言時に `some Store` のように表現できるようになりました。
しかし、Opaque Types のままでは抽象型なので利用できない場面（たとえば、配列の宣言に `[some Store]` とは書けない）があります。この場合には、`[AnyStore<Drug>]` と記述する必要があります。

SwiftUI における `View` 型は、`associatedtype` を持っているため Opaque Types により `some View` のように記述します。この `View` の型消去を行うためのラッパーとして、SwiftUI には `AnyView` 型が定義されています。

型消去の仕組み自体は気にしなくても SwiftUI で画面は記述できますが、仕組みを知っておく必要はあるでしょう。
それにより、Opaque Types が何のために存在しているのかも、理解が深まると思います。

### 補足
Swift 5.6 では、`some` に続いて `any` キーワードが導入されました。
`some Store` は「 **何らかの**  `Store` 準拠型」ですが、`any Store` は「 **任意の**  `Store` 準拠型」を表します。

そのため、以下のような宣言も可能です。

```swift
//var someStores: [some Store]    // NG
var anyStores: [any Store]      // OK
```

## 参考
- [「型として」・「制約として」のプロトコルの使い分け | Heart of Swift](https://heart-of-swift.github.io/protocol-oriented-programming/protocols-as-types-or-constraints.html)
- [型消去の話で出てきたポケモンの例題を理解する #tryswiftconf - Qiita](https://qiita.com/S_Shimotori/items/458a50d8f8e54e39de59)
- [tana000のブログ : 一周遅れのSwift型消去、解説：付属型消去、代替型生成 - livedoor Blog（ブログ）](http://blog.livedoor.jp/tana000/archives/1949478.html)
- [Opaque 型(Opaque Types) · The Swift Programming Language日本語版](https://www.swiftlangjp.com/language-guide/opaque-types.html)
- [swift-evolution/0335-existential-any.md at main · apple/swift-evolution](https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md)
- [Swift 5.6 の any について & some との違い](https://zenn.dev/fsh/articles/0fffd249fd54ca)
