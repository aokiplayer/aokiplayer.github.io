+++
title = "SwiftUI のモディファイアの順序による結果の相違"
date = "2022-10-14T10:17:36+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftUI" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
SwiftUI は、ビューに対してモディファイアをメソッドチェーン形式で追加していくという統一的な操作ができるので、とてもわかりやすいですよね。
時にはモディファイアが多すぎて、見通しが悪くなることはありますが…。

簡単に扱えるモディファイアですが、順序には注意する必要があります。

## 検証環境
- macOS Monterey 12.6
- Xcode 14.0.0

## 実験
``Text`` に、``frame()``, ``padding()``, ``border()`` の 3 つのモディファイアを設定してみます。
設定順序の組み合わせは 3! 通りあります。

### サンプルコード
それぞれ、枠線を付けた同じサイズの ``VStack`` 内に上記 3 つのモディファイアの順序を変えた ``Text`` を配置しています。

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("モディファイアの順序")
                .font(.title)
            
            VStack {
                Text("frame -> border -> padding")
                    .frame(width: 300, height: 60)
                    .border(.red, width: 3)
                    .padding()
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)
            
            VStack {
                Text("frame -> padding -> border")
                    .frame(width: 300, height: 60)
                    .padding()
                    .border(.red, width: 3)
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)

            VStack {
                Text("border -> frame -> padding")
                    .border(.red, width: 3)
                    .frame(width: 300, height: 60)
                    .padding()
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)

            VStack {
                Text("border -> padding -> frame")
                    .border(.red, width: 3)
                    .padding()
                    .frame(width: 300, height: 60)
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)

            VStack {
                Text("padding -> frame -> border")
                    .padding()
                    .frame(width: 300, height: 60)
                    .border(.red, width: 3)
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)

            VStack {
                Text("padding -> border -> frame")
                    .padding()
                    .border(.red, width: 3)
                    .frame(width: 300, height: 60)
            }
            .frame(width: 350, height: 100)
            .border(.indigo, width: 3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### 結果
![modifier-order.png?width=25pc](/images/swiftui-modifier-order/modifier-order.png?width=25pc)

### 考察
``border()`` を最初に設定しているものは、後から設定される ``frame()`` や ``padding()`` の設定値を知らないので、テキストがちょうど収まるサイズに枠線が引かれていることがわかります。

これは、モディファイアが「そのモディファイアの適用結果のビューを返す」メソッドであるためです。
つまり、以下のコードでは

1. まずはサイズが設定されていない ``Text``（固有サイズとして文字列がちょうど収まるサイズ）に、枠線を設定
2. ビューのサイズを幅 300, 高さ 60 に設定
3. ビューの外側に、標準サイズの余白を設定

という流れとなっています。
そのため、ビューのサイズを設定しているにもかからわず、枠線がそれよりも狭い範囲に引かれているように見えてしまいます。
ですが、「その時点のビューのサイズ」に対しては正しく枠線が設定されていたということになります。

```swift
Text("border -> frame -> padding")
    .border(.red, width: 3)
    .frame(width: 300, height: 60)
    .padding()
```

![border-first.png?width=25pc](/images/swiftui-modifier-order/border-first.png?width=25pc)


## まとめ
モディファイアは「単にビューに設定を追加するもの」と考えてしまうと順序は関係ないように思えてしまいます。

ですが、あくまでも「モディファイアで設定した結果のビューを返す」という意識があれば、ひとつのモディファイアを実行した結果のビューがその時点で返っているので、最初に ``border()`` を持ってくると期待した結果にならないことがわかりますね。

作成したサンプルは、[GitHub: aokiplayer/swift-sandbox/ModifierOrder](https://github.com/aokiplayer/swift-sandbox/tree/master/ModifierOrder) に置きました。

## 参考
[Why modifier order matters - a free Hacking with iOS: SwiftUI Edition tutorial](https://www.hackingwithswift.com/books/ios-swiftui/why-modifier-order-matters)

上記のサイトは、この記事を書いた後に気付きました。
最後に掲載されている、``padding()`` と ``background()`` を何度も呼び出すことでサイズの異なる塗りつぶしを重ねるサンプルを実行してみると、この「モディファイアで設定した結果のビューを返す」のイメージがわかりやすいと思います。
