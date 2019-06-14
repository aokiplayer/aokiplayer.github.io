---
title: "画面遷移（セグエ）のキャンセル"
date: 2019-05-26T09:35:28+09:00
draft: false
toc: true
tags: [ "iOS", "Swift" ]
---

# はじめに
- 画面遷移のタイミングで条件を判断し、場合によってはキャンセルするような動作が必要な場面があります
- ボタンなどからAction接続したメソッド内で`performSegue(withIdentifier:sender:)`を利用する場合や、`addTarget(_:action:for:)`でアクションを登録した場合であれば、その際に条件判断を行うこともできます
    - しかし、ボタンからセグエを直接引いて画面遷移する場合であれば、無条件に画面遷移してしまいます
- ここでは、後者の場合に画面遷移の判断とキャンセルの方法について紹介します

# 検証環境
- Xcode 10.2
- iOS 12.2
- Swift 5

# 利用するメソッド
- `UIViewController`の`shouldPerformSegue(withIdentifier:sender:)`を利用します
    - このメソッドをオーバーライドします
    - 動きとしては、trueを返した場合は画面遷移を実行、falseの場合はキャンセルとなります

# サンプルプログラム
## 動作
-  NEXTボタンからセグエを引いてあり、スイッチがONの場合のみ画面遷移を行うプログラムです

    ![segue_cancel](/images/seguecancel/segue_cancel.png)

## サンプルコード
```swift:ViewController.swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var moveSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        super.shouldPerformSegue(withIdentifier: identifier, sender: sender)

        // When the switch is off, it cancels the segue.
        return moveSwitch.isOn
    }

    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
    }
}
```

# まとめ
- これを利用することで、「特定の状況下では画面遷移させない」が実現できます
- このサンプルでは利用していませんが、`shouldPerformSegue(withIdentifier:sender:)`の第1引数にはセグエのIdentifierが渡ってきます
    - この情報を利用することで、複数のセグエが引かれていた際、セグエごとに条件を個別に判断できますね
- 今回作成したサンプルは、GitHubに置きました
    - [aokiplayer/SegueCancelSample](https://github.com/aokiplayer/SegueCancelSample)

# 参考
- [shouldPerformSegue(withIdentifier:sender:) - UIViewController | Apple Developer Documentation](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621502-shouldperformsegue)
