---
title: "簡単なdelegateのサンプル"
date: 2019-07-02T11:34:30+09:00
draft: false
toc: true
tags: [ "iOS", "Swift" ]
---

# はじめに
- iOSアプリでは、delegateが非常によく利用されます
- トレーニングで紹介していると、初めての人には「delegateオブジェクトに用意したコールバックメソッドが自動的に呼ばれる」ことの理解が難しいように感じました
- そこで、ごく簡単なサンプルを利用してdelegateの仕組みを紹介してみます

# 検証環境
- Xcode 10.2
- Swift 5

# サンプルコード
## delegateを利用するクラスとdelegateプロトコル
- まずは、delegateを利用するMyClassクラスの定義とdelegateであるMyDelegateプロトコルの定義です
- MyClassの`show(text:)`を呼ぶと、自身のプロパティとして保持するdelegateの`onShowCalled(withText:)`を呼ぶ実装となっています

```swift
class MyClass {
    var delegate: MyDelegate?
    
    func show(text: String) {
        self.delegate?.onShowCalled(withText: text)
    }
}

protocol MyDelegate {
    func onShowCalled(withText text: String)
}
```

## delegateに準拠したクラス
- delegateはプロトコルなので、利用する際にはそのプロトコルに準拠して内容を実装したクラスが必要です
- MyAdopted1とMyAdopted2の2つを用意し、それぞれ実装の異なる`onShowCalled(withText:)`を用意しています

```swift
class MyAdopted1: MyDelegate {
    func onShowCalled(withText text: String) {
        print("MyAdopted1: \(text)")
    }
}

class MyAdopted2: MyDelegate {
    func onShowCalled(withText text: String) {
        print("\(text) from MyAdopted2!")
    }
}
```

## delegateを指定
- MyClassのインスタンスに、上記のMyAdopted1およびMyAdopted2をdelegateとして指定します
- MyClassの`show(text:)`を呼ぶと、delegateとして指定したオブジェクトの`onShowCalled(withText:)`が実行されているのがわかります

```swift
let anObject1 = MyClass()
anObject1.delegate = MyAdopted1()
anObject1.show(text: "Hello")

let anObject2 = MyClass()
anObject2.delegate = MyAdopted2()
anObject2.show(text: "Hello")
```

```terminal
MyAdopted1: Hello
Hello from MyAdopted2!
```

# まとめ
- 普段、プログラマは上記の「delegateに準拠したクラスの作成」と、「delegateを指定」部分を書くことが多いと思います
- delegateを利用するクラスを一度実装してみることで、delegateの仕組みについての理解が深まるのでおすすめです
- 今回作成したサンプルコードは、GitHubに置きました
- [aokiplayer/DelegateSample](https://github.com/aokiplayer/DelegateSample)
