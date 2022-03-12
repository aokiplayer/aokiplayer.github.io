---
title: "SwiftUIで一覧表示画面を作成する"
date: 2019-06-14T13:16:59+09:00
draft: false
toc: true
tags: [ "iOS", "Swift", "SwiftUI" ]
---

## はじめに
- WWDC 2019で発表された目玉として、SwiftUIがあります
- 今回は、少しだけSwiftUIを触ってみたのでメモしてみます

## 検証環境
- macOS 10.15 Catalina beta
- Xcode 11 beta
- iOS 13 beta
- Swift 5.1
- iPad Pro 10.5 inch

## ストーリーボードは？
- これまで、レイアウトは基本的にストーリーボードで行ってきました
- ストーリーボードは決して悪いものではなく、まず画面の作成を始める際にはとても扱いやすいです
- ただし、ビューの数が増えたり、複雑なレイアウトをしようとすると非常に管理が難しいのも事実です

## コードでレイアウトを行うSwiftUI
- Flutterなどでは、画面をコード上で宣言的に記述できます
- 最近は、この形式をとるものが増えています
- SwiftUIも、コードから宣言的なレイアウトを行います
- これまでもコードのみで画面を作成できましたが、以下のような問題を抱えていました
  - プレビューの方法がないため、ビルドして実行しないと確認できない
  - 手続的に記述するため、実際のレイアウトがイメージしにくい

## SwiftUIで作成した一覧画面のサンプル
### 画面イメージ

![background_modes](/images/swiftuilist_beta/list_preview.png)

### 実装ファイル
- 実装したのは、以下のファイルです

| ファイル | 説明 |
|:--|:--|
| FoodModel.swift | 表の1行分を表すデータモデル |
| FoodDataSource.swift | 表示するデータを提供する |
| FoodRow.swift | 表の各行を表すビュー。FoodListから利用される |
| FoodList.swift | 表の全体を表すビュー。FoodDataSourceからデータを取得し、各行のFoodRowを生成する |
| ContentView.swift | 最初に表示されるビュー。この中でFoodListを読み込む |

#### FoodModel.swift
```swift:FoodModel.swift
import Foundation

struct FoodModel: Codable {
    var id: Int
    var title: String
    var userName: String
    var imageName: String
    var liked: Bool = false
}
```

#### FoodDataSource.swift
```swift:FoodDataSource.swift
import Combine
import SwiftUI

class FoodDataSource: BindableObject {
    typealias PublisherType = PassthroughSubject
    
    let didChange: FoodDataSource.PublisherType = PassthroughSubject<Void, Never>()
    var foodData: [FoodModel]

    init() {
        foodData = [
            FoodModel(id: 10, title: "スープカレー", userName: "山田二郎", imageName: "1", liked: true),
            FoodModel(id: 20, title: "そば屋のカレー", userName: "川田吾郎", imageName: "2"),
            FoodModel(id: 30, title: "タイ風カレー", userName: "里田舞", imageName: "3", liked: true),
            FoodModel(id: 40, title: "スタミナジャンボカレー", userName: "海田泳七郎", imageName: "4"),
            FoodModel(id: 50, title: "レッドカレー", userName: "岡田八郎", imageName: "5")
        ]

        didChange.send(())
    }
}
```

#### FoodRow.swift
```swift:FoodRow.swift
import SwiftUI

struct FoodRow : View {
    var foodModel: FoodModel

    var body: some View {
        VStack(alignment: .leading) {
            Image(foodModel.imageName)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .shadow(radius: 10)
                .border(Color.white, width: 2)

            Text(foodModel.title).font(.headline)

            HStack {
                Text(foodModel.userName).font(.subheadline)
                Spacer()
                Image(foodModel.liked ? "liked" : "unliked")
            }
        }.padding()
    }
}

#if DEBUG
struct FoodRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            FoodRow(foodModel: FoodModel(id: 10, title: "Ramen", userName: "Jiro Yamada", imageName: "5"))
        }.previewLayout(.fixed(width: 300, height: 400))
    }
}
#endif
```

#### FoodList.swift
```swift:FoodList.swift
import SwiftUI

struct FoodList : View {
    @ObjectBinding var foodDataSource = FoodDataSource()

    var body: some View {
        NavigationView {
            List(foodDataSource.foodData.identified(by: \.id)) { foodModel in
                    FoodRow(foodModel: foodModel)
                }
            .navigationBarTitle(Text("Food list"))
        }
    }
}

#if DEBUG
struct FoodList_Previews : PreviewProvider {
    static var previews: some View {
        FoodList()
    }
}
#endif
```

#### ContentView.swift
```swift:ContentView.swift
import SwiftUI

struct ContentView : View {
    var body: some View {
        FoodList()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
```

## まとめ
### よかった点
- ちょっとした画面の作成であれば、SwiftUIはとても簡単に思えました
- macOS 10.15 Catalina上であれば、ライブビューでレイアウトだけでなく動作がすぐ確認できるのが良いです

### 難しく感じた点
- ストーリーボードを利用していた際と、ビュー階層のイメージが異なるのでまだ戸惑っています
- また、思った通りにレイアウトができず苦労しています

## サンプルプロジェクト
- 今回作成したサンプルコードは、GitHubに置きました
    - [aokiplayer/SwiftUITableSample](https://github.com/aokiplayer/SwiftUITableSample)

## 参考
- [SwiftUI Tutorials | Apple Developer Documentation](https://developer.apple.com/tutorials/swiftui)
