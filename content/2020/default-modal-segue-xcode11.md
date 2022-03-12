---
title: "iOS/iPadOS 13 のモーダル画面から戻った際に、ライフサイクルメソッドが呼ばれないパターンがある"
date: 2020-03-02T18:03:25+09:00
draft: false
toc: true
categories: [ "Technical" ]
tags: [ "iOS", "Swift" ]
---
## はじめに
- iOS/iPadOS 13 から、モーダルで画面遷移した際はデフォルトでは全画面ではなく少し小さい表示になります
- その画面から戻る際、これまでは unwind セグエを呼ぶか dismiss する必要がありましたが、モーダルの画面をスワイプダウンすることで遷移が可能となりました
- その場合、本来呼ばれるはずのライフサイクルメソッドが呼ばれません
    - もちろん、 unwind セグエメソッドも呼ばれません
    - unwind セグエから戻っても、ライフサイクルメソッドは呼ばれません（unwind セグエメソッドは呼ばれる）

## サンプル
### 画面レイアウト
![storyboard](/images/default-modal-segue-xcode11/storyboard.png?width=25pc)

### New Default シーンへのセグエ
![segue_for_new_default](/images/default-modal-segue-xcode11/segue_for_new_default.png?width=25pc)

- Xcode 11 でのデフォルト設定
- Presentation  が Same as Destination

### Full Screen シーンへのセグエ
![segue_for_full_screen](/images/default-modal-segue-xcode11/segue_for_full_screen.png?width=25pc)

- Presentation を Full Screen に変更
- デフォルトと異なり、画面全体を覆う（iOS 12 までの Modal）

### ソースコード
#### ViewController（最初の画面）
```swift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }

    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
        print("Returned through unwind segue.")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let style: String

        switch segue.destination.modalPresentationStyle {
        case .automatic:
            style = "automatic"
        case .currentContext:
            style = "currentContext"
        case .custom:
            style = "custom"
        case .formSheet:
            style = "formSheet"
        case .fullScreen:
            style = "fullScreen"
        case .none:
            style = "none"
        case .overCurrentContext:
            style = "overCurrentContext"
        case .overFullScreen:
            style = "overFullScreen"
        case .pageSheet:
            style = "pageSheet"
        case .popover:
            style = "popOver"
        @unknown default:
            fatalError("Maybe there will be new case.")
        }
        print(style)
    }
}
```

#### NewDefaultVC（NewDefault ボタンから遷移する画面）
```swift
import UIKit

class NewDefaultVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#file.components(separatedBy: "/").last!)
    }
}
```

#### FullScreenVC（FullScreen ボタンから遷移する画面）
```swift
import UIKit

class FullScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#file.components(separatedBy: "/").last!)
    }
}
```

## 実行結果
### New Default ボタンで遷移 -> Unwind ボタンで戻る
```
pageSheet
NewDefaultVC.swift
Returned through unwind segue.
```

- unwind セグエメソッドは呼ばれていますが、戻ったシーンのライフサイクルメソッドが呼ばれていません

### New Default ボタンで遷移 -> 画面上部からスワイプダウンで戻る
```
pageSheet
```

- やはり、戻ったシーンのライフサイクルメソッドは呼ばれていません
- また、 unwind セグエを利用していないので、当然ですが unwind セグエメソッドも呼ばれていませんね
    - 同様に、 New Default シーンの `prepare(for:sender:)` も呼ばれていません

### Full Screen ボタンで遷移 -> Unwind ボタンで戻る
```
fullScreen
viewWillDisappear(_:)
viewDidDisappear(_:)
FullScreenVC.swift
Returned through unwind segue.
viewWillAppear(_:)
viewDidAppear(_:)
```

- こちらは、 iOS 12 までと同じですね
- 戻ったシーンのライフサイクルメソッドおよび unwind セグエメソッドの、どちらも呼ばれています

## まとめ
- iOS 13 から新しくなったデフォルトのモーダルの挙動は、ユーザにとっては「メインとは別の流れにいる」のを認識しやすいと思います
- また、スワイプダウンで戻れるので、操作としても直感的です
- ただ、「戻った際に何か処理をさせる」必要がある場合は要注意ですね
- 今回のサンプルは、[aokiplayer/ModalXcode11](https://github.com/aokiplayer/ModalXcode11) に置きました

