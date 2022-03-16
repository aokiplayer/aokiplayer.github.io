+++
title = "Xcode 11 で作成したプロジェクトを iOS 13 未満に対応させる"
date = "2019-12-02T16:38:56+09:00"
draft = false
toc = true
tags = [ "iOS", "Swift" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- Xcode 11 から、新規作成したプロジェクトの構成が変わりました
    - User Interface を Swift UI と Storyboard から選択可能
    - SceneDelegate.swift が追加
    - Info.plist に、 SceneDelegate を利用するエントリが追加
- iOS 13 以降のみ対応させる場合にはそのままでよいのですが、多くの場合、 2 つ前くらいまでの iOS をサポートすると思います
- このままで Target のバージョンに iOS 13 未満を設定すると、エラーが発生して実行できません
- ここでは、その解決法を紹介します
    - 方法は他にもあるようですが、これが Xcode のサポートを一番受けやすい方法だと思います
    - なお、 Swift UI は iOS 13 以降対応なので、ここでは Storyboard を選択した前提とします

## 検証環境
- Xcode 11.2.1
- iOS 13.2.3, 12.3.1
- Swift 5

## デフォルトの状態と実行確認
- プロジェクトを作成すると、以下のような状態となっています
    ![xcode11_project](/images/adopt-under-xcode11/xcode11_project.png)
    ![scene_manifest](/images/adopt-under-xcode11/scene_manifest.png)

## 手順
### Build Target を iOS 13 未満に設定
![target_under_13](/images/adopt-under-xcode11/target_under_13.png)

### アプリを実行
- ビルドに失敗する

### ビルドエラーメッセージを確認
![build_error_with_scene](/images/adopt-under-xcode11/build_error_with_scene.png)

### エラーのアイコンをクリックし、修正内容を選択
![fix-it_correction](/images/adopt-under-xcode11/fix-it_correction.png)

- `SceneDelegate`
    - クラス全体に `@available` を付加する修正候補を採用
- `AppDelegate`
    - 対象のインスタンスメソッドに `@available` を付加する修正候補を採用
    
- 修正結果（SceneDelegate.swift）

```swift
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    〜省略〜

}
```

- 修正結果（AppDelegate.swift）

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    〜省略〜

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

```

### 再度、アプリを実行
- 実行できるが、画面は真っ黒

### Xcode のコンソールを確認
- 以下のようなメッセージが表示されている

```
2019-12-03 10:29:13.671826+0900 SampleProject[309:24561] [Application] The app delegate must implement the window property if it wants to use a main storyboard file.
```

- ストーリーボードを利用するためには `AppDelegate` に `window` プロパティが必要とのメッセージ
- 以前のバージョンの Xcode で作成したプロジェクトでは、宣言されていた

### `AppDelegate` に `window` プロパティを追加
- `SceneDelegate` に記載されている内容を、そのまま移植すれば OK
- 修正結果（AppDelegate.swift）

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    〜省略〜
}
```

### 実行して、動作することを確認
- Main.storyboard の最初のシーンが表示される

## まとめ
- 基本的には、 Xcode の修正候補に従って修正すれば問題ないです
- 今回のサンプルは、 GitHub に置きました
    - [aokiplayer/Under13Xcode11Sample](https://github.com/aokiplayer/Under13Xcode11Sample)
- これ以外に、今後は Swift UI とストーリーボードを混在させる必要が出てくると考えられます
    - Swift UI を使いたいが、 iOS 13 未満もサポートしたいパターン
- 複数バージョンに対応させる方法は、調べておきましょう
