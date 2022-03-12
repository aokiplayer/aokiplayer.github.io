---
title: "iOSにおけるPush通知の基本2（受信した通知の内容取得）"
date: 2019-05-24T10:52:57+09:00
draft: false
toc: true
tags: [ "iOS", "Swift" ]
---

## はじめに
- 前の記事 [[iOSにおけるPush通知の基本1（通知の受信まで）]]({{< ref "/2019/remotenotification01.md">}}) では、以下のところまで紹介しました
    - Push通知に必要な事前設定
    - Push通知のユーザへの利用許可依頼
    - Push通知の送信テスト
- これだけでも、受け取った通知をタップしてアプリを起動することができます
- 今回は、通知に含まれる内容（ペイロード）を取得する方法を説明します

## 検証環境
- Xcode 10.2
- iOS 12.2
- Swift 5
- iPod touch 6th generation

## 通知に対するコールバックメソッド
- 通知を受け取ると、`UIApplicationDelegate`の以下のコールバックメソッドが呼ばれます
- 呼ばれるコールバックメソッドとそのタイミングは、アプリの実行状態により決定されます

    | 事前状態 | タイミング | メソッド |
    |:--|:--|:--|
    | 未起動 | 通知のタップにより起動 | ```application(_:didFinishLaunchingWithOptions:)``` |
    | Foreground | 通知を受信 | `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` |
    | Background | 通知のタップによりForeground | `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` |

- これらのコールバック内で、通知のペイロード（通知に含まれるデータ）を取得して処理を行います

## Push通知のペイロード
- Push通知のペイロードは、以下のような形式のJSONです

    ```json
    {
        "aps" : {
            "alert" : {
                "title" : "New Message",
                "subtitle" : "You got a new message.",
                "body" : "New message has arrived. Open your inbox."
            },
            "badge" : 3,
            "sound" : "default"
        }
    }
    ```

## ペイロードの取得
- 受信したPush通知から、ペイロードを取り出す処理を実装します

### そもそもどこから取り出すのか？
- ペイロードは、`UIApplicationDelegate`のコールバックの引数に格納された状態で渡されます

| コールバックメソッド | 格納場所 |
|:--|:--|
| `application(_:didFinishLaunchingWithOptions:)` | 第2引数`launchOptions`ディクショナリ内 |
| `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`  | 第2引数の`userInfo`ディクショナリ内 |

### 送信するPush通知の内容
- 今回は、以下の内容のPush通知を送ってみます

    ```json:通知のペイロード
    {
      "aps": {
        "alert": "Wake up!",
        "sound": "default"
      }
    }
    ```

### 実装例
####  アプリ未起動の場合
- アプリが起動していない場合は通知をタップした時点でアプリが起動するので、ライフサイクルメソッドである`application(_:didFinishLaunchingWithOptions:)`が呼ばれます
- このサンプルコードでは、ペイロードの内容を文字列として整形してビューコントローラのプロパティに渡しています
    - 起動済みの場合と区別するために、背景色を黄色に設定しています

##### ペイロードの取得手順
1. 第2引数の`launchOptions`ディクショナリからキー`UIApplication.LaunchOptionsKey.remoteNotification`を指定
    - Push通知のペイロードを格納したディクショナリが得られる
1. Push通知のペイロードを格納したディクショナリから、キー"aps"でペイロードの内容部分のディクショナリを取得

```swift:AppDelegate.swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    〜省略〜

    // MARK: 01. get notification payload
    if let notificationOptions = launchOptions?[.remoteNotification] as? [String: AnyObject] {
        guard let apsPart = notificationOptions["aps"] as? [String: AnyObject] else { return true }

        guard let vc = window?.rootViewController as? ViewController else { return true }
        let text = apsPart.map { (key, value) in "\(key): \(value)" }.joined(separator: "\n")
        vc.payloadText = text
        vc.backgroundColor = .yellow
    }

    return true
}
```

##### 実行結果
![launching](/images/remotenotification02/launching.png)

#### アプリが起動中の場合
- アプリが起動中の場合は、以下のタイミングで`UIApplicationDelegate`プロトコルの`application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`が呼ばれます
    - アプリがForegroundの場合: 通知を受け取ったタイミング
    - アプリがBackgroundの場合: 受け取った通知をタップしてForegroundになったタイミング
- このサンプルコードでは、ペイロードの内容を文字列として整形してビューコントローラのプロパティに渡しています
    - 未起動の場合と区別するために、背景色を緑に設定しています

##### ペイロードの取得手順
1. 第2引数の`userInfo`ディクショナリからキー"aps"でペイロードの内容部分のディクショナリを取得
1. 取得したディクショナリの扱いは、未起動の場合と同様

- このコールバックを実装した場合、Backgorund ModesをONにすることを求められるので有効にしておきます
    - エラーにはなりませんが、コンソールにメッセージが表示されます

    ![background_modes](/images/remotenotification02/background_modes.png)

```swift:AppDelegate.swift
func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    // MARK: 04. get notification payload
    guard let apsPart = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
    }

    guard let vc = window?.rootViewController as? ViewController else { return }
    let text = apsPart.map { (key, value) in "\(key): \(value)" }.joined(separator: "\n")
    vc.payloadText = text
    vc.backgroundColor = .green

}
```

##### 実行結果
![active](/images/remotenotification02/active.png)

## まとめ
- アプリの実行状態によって、呼ばれるコールバックが異なる点に注意
- ペイロードはディクショナリから取り出す
    - 受け取った時点で、すでにJSONからディクショナリに変換されている
- 今回作成したサンプルコードは、GitHubに置きました
    - [aokiplayer/TreatPushNotificationPayloadSample](https://github.com/aokiplayer/TreatPushNotificationPayloadSample)

## 参考
- [UserNotifications | Apple Developer Documentation](https://developer.apple.com/documentation/usernotifications)
- [Push Notifications Tutorial: Getting Started | raywenderlich.com](https://www.raywenderlich.com/8164-push-notifications-tutorial-getting-started)
