+++
title = "SwiftUI でサイズクラスに対応する"
date = "2022-12-12T06:00:00+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftUI" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
Storyboard を利用していると、サイズクラスを利用して以下のように柔軟にビューのレイアウトを変更することが、比較的簡単に実現できていました。

- iPad で画面を分割していないので、幅が十分にあるからビューを横に並べよう
- iPad をマルチタスキングで画面分割して幅が狭くなったので、ビューを縦に並べよう

`UIStackView` で、幅と高さが Regular のデバイス（iPad で画面非分割時など）の場合のみサブビューを横に並べるのであれば、以下のような設定を行いました。

![sizeclass_in_storyboard.png?width=25pc](/images/sizeclass-swiftui/sizeclass_in_storyboard.png?width=25pc)

サイズクラスは SwiftUI でも利用できるので、その使い方を記載します。

## 今回のゴール
以下のように、画面幅の広い状態ではビューを横に、狭い状態では縦に並べるように設定します。

| w:Regular | w:Compact |
| --- | --- |
| ![w_regular.png?width=25pc](/images/sizeclass-swiftui/w_regular.png?width=25pc) | ![w_compact.png?width=25pc](/images/sizeclass-swiftui/w_compact.png?width=25pc) |

## 検証環境
- macOS Ventura 13.0.1
- Xcode 14.1
- iOS/iPadOS 16.1

## サイズクラスとは
サイズクラスは、その名のとおり「デバイスのサイズを分類する」概念です。サイズクラスでは、ざっくりとデバイスの縦横を「普通（Regular）」「小さい（Compact）」の組み合わせで表します。
それにより、最大で 4 通りの画面サイズ（w: Regular x h: Regular, ..., w: Compact x h: Compact）にデバイスを分類してビューのレイアウトを行います。
サイズクラスを使うことで、全部のデバイスに個々に対応せず、大まかな分類ごとにレイアウトを行えば済むので労力が削減できます。

4 パターン全部に対応せずとも、iPad の画面分割のことを考えるのであれば、幅のみに着目して 2 パターンでレイアウトすることが多いのではないでしょうか。

## サイズクラス情報の取得
現在表示中のビューがどのサイズクラスなのかは、`Environment` から列挙型 `UserInterfaceSizeClass` 型の値として取得できます。

```swift:サイズクラス情報の取得
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass
```

この `UserInterfaceSizeClass` は定数として `compact` と `regular` の 2 つのケースを取るため、これを利用して条件分岐すれば、サイズクラスごとにレイアウトを変更できます。

## 実装例（第 1 段階）
では、サイズクラスごとにレイアウトを変えてみます。

```swift:第1段階
struct Example1: View {
    // 水平方向のサイズクラス（compact, regular のいずれか）
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass     // 今回は使ってない

    var body: some View {
        // compact なら VStack, regular なら HStack でレイアウト
        if horizontalSizeClass == .compact {
            VStack {
                Text("A")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.green)
                    .foregroundColor(.white)

                Text("B")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.orange)
                    .foregroundColor(.white)
            }
            .font(.largeTitle)
            .frame(maxWidth: .infinity)
            .padding()
        } else {
            HStack {
                Text("A")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.green)
                    .foregroundColor(.white)

                Text("B")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.orange)
                    .foregroundColor(.white)
            }
            .font(.largeTitle)
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
```

この実装で、w: Compact であれば `VStack` を利用してビューが縦に、w: Regular であれば `HStack` を利用して横に配置されます。

ただし、外側のビューが `VStack` か `HStack` かの違いだけですので、このままでは冗長です。
共通部分をビューとして切り出しても良いですが、大袈裟な気がします。

## 実装例（第 2 段階）
`VStackLayout` や `HStackLayout` などを利用することで、上記のコードをシンプルに記述できるようになります。

```swift:第2段階
struct Example2: View {
    // 水平方向のサイズクラス（compact, regular のいずれか）
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass     // 今回は使ってない

    var body: some View {
        // compact なら VStackLayout, regular なら HStackLayout を生成
        // VStackLayout, HStackLayout は Layout プロトコルに準拠しているので、AnyLayout に包める
        let layout = horizontalSizeClass == .compact
        ? AnyLayout(VStackLayout())     // <---- ①
        : AnyLayout(HStackLayout())     // <---- ①

        // 上で選択したレイアウトを利用してビューを配置
        // この形で記述できているのは、callAsFunction(_:) が呼ばれているため
        layout {    // <---- ②
            Text("A")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.green)
                .foregroundColor(.white)

            Text("B")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.orange)
                .foregroundColor(.white)
        }
        .font(.largeTitle)
        .frame(maxWidth: .infinity)
        .padding()
    }
}
```

ここでのポイントは以下です。

- ①: サイズクラスの値によって `VStackLayout` と `HStackLayout` を選択（`AnyLayout` に包む）
- ②: ① の `AnyLayout` を使ってレイアウト

### ポイント①
#### VStackLayout, HStackLayout, AnyLayout
```swift
// compact なら VStackLayout, regular なら HStackLayout を生成
// VStackLayout, HStackLayout は Layout プロトコルに準拠しているので、AnyLayout に包める
let layout = horizontalSizeClass == .compact
? AnyLayout(VStackLayout())     // <---- ①
: AnyLayout(HStackLayout())     // <---- ①
```

`VStack` や `HStack` は、内包するビューをイニシャライザに渡す必要があるため、引数なしではインスタンス化できません。

そのような場合には `VStackLayout` や `HStackLayout` などが利用できます。
今回は定数  `layout` には `VStackLayout` と `HStackLayout` のどちらの値も取りうるので、両方を表現できるように `AnyLayout` に包んでいます。

`AnyLayout` のイニシャライザに渡せるのは `Layout` プロトコル型ですが、`VStackLayout` や `HStackLayout` はこのプロトコルに準拠しています。

これで、どちらの場合であっても `AnyLayout` 型として扱うことができます。

### ポイント②
#### callAsFunction(_:)
```swift
// 上で選択したレイアウトを利用してビューを配置
// この形で記述できているのは、callAsFunction(_:) が呼ばれているため
layout {    // <---- ②
    Text("A")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.green)
        .foregroundColor(.white)

    Text("B")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.orange)
        .foregroundColor(.white)
}
```

`layout { ... }` という記述には、少し違和感があるかもしれません。
これは ` layout.callAsFunction( {  ... } )` の省略形です。

この記述は `callAsFunction(_:)` という名前のメソッドを定義しておくと、メソッド名を省略して `インスタンス()` の形で呼び出すことができるようになっている言語仕様によるものです。`AnyLayout` や `VStackLayout`, `HStackLayout` が準拠している `Layout` プロトコルには、`callAsFunction(_:)` が宣言されています。

もちろん、末尾クロージャなので引数リストの `()` も省略しています。

## まとめ
サイズクラスに対応するだけなら、`Environment` から値を取得して条件分岐できるので単純です。
さらに、`AnyLayout`, `VStackLayout`, `HStackLayout` や `callAsFunction(_:)` などを利用することで簡潔なコードとすることができることがわかりましたね。

## 参考
- [VStackLayout | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/vstacklayout)
- [HStackLayout | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/hstacklayout)
- [AnyLayout | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/anylayout)
- [callAsFunction(_:) | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/anylayout/callasfunction(_:))
- [Methods with Special Names | Declarations — The Swift Programming Language (Swift 5.7)](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622)
    - [上記の日本語版](https://www.swiftlangjp.com/language-reference/declarations.html#methods-with-special-names)
