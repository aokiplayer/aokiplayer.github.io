+++
title = "Apple の iOS/Swift 認定資格を受験してみた"
date = "2019-12-20T16:56:23+09:00"
draft = false
toc = true
tags = [ "iOS", "Swift", "Apple", "Certification" ]
ogimage = "images/open_graph_logo.png"
+++

2018 年 11 月 26 日の Apple の Newsroom 記事 [Apple、Hour of Codeにより、さらに多くの学生にプログラミング教育を提供 - Apple (日本)](https://www.apple.com/jp/newsroom/2018/11/apple-brings-coding-education-to-more-students-for-computer-science-education-week/) で述べられているように、 Apple は主に学生をターゲットとした iOS および Swift の認定資格をリリースしました。

> このカリキュラムを履修した学生は、Swiftについての知識、アプリケーション開発ツール、アプリケーションのコアコンポーネントの知識について認定を受けることもできます。App Development with Swift Level 1認定試験は、世界中のCertiport認定試験センターを通じて実施されます。

日本ではこれまで試験が配信されていませんでしたが、約 1 年後の 2019 年 12 月 10 日から、 Certiport の代理店である [オデッセイ コミュニケーションズ](https://www.odyssey-com.co.jp/) から配信が開始されました。

配信開始日の一番早い時間に受験し、日本での認定第一号として合格してきました。
興味のある方もいらっしゃると思うので、 NDA に抵触しない程度に感想などをまとめてみます。

なお、この記事は日本でのリリース当初（2019 年 12 月 10 日）の情報です。
今後のアップデートで、変わる可能性がありますのでご注意ください。

## 試験の概要
詳しくは、[公式サイト](https://www.odyssey-com.co.jp/app-dev-with-swift/)をご覧ください。

### 名称
App Development with Swfit Level 1

### 試験の範囲
[App Development with Swift](https://books.apple.com/jp/book/id1219117996)  の内容

### 出題数/時間
45 問/50 分

### 受験料
一般 ¥9,800, 学生 ¥7,800
## 想定されるターゲット層
試験は、主に学生向けのプログラミング学習コンテンツ Everyone Can Code の 1 つとして Apple がリリースしている電子書籍 [App Development with Swift](https://books.apple.com/jp/book/id1219117996) に沿った内容です。
ですので、主なターゲットは学生のようです。
受験料も、学生向けには低く設定されています。

## 試験の形式
### 試験の言語
試験は、全て英語で出題されます。
日本語での提供は、現時点では考えていないとのことでした。

### 出題形式
基本的に、一般的なオンライン形式の IT 系試験と同じです。
以下のパターンがあります。

- 多岐選択式
- 選択肢を回答欄にドラッグ
- 画像の対象部分をクリックしてマーク
- キーワードを入力

### 出題の傾向
#### 基本を押さえていれば解ける文法
利用頻度がそれほど高くないものや、フレームワークを作るような人であれば使うが一般の開発者が使う頻度は低いようなもの、などは出題されません。
よく使うもので、かつ最低限の文法を押さえていれば迷わず解けるものばかりです。

#### Xcode の画面構成の把握
iOS アプリの開発では、 Xcode を利用することが必須です。
そのためなのか、 Xcode のどこからどんな機能が利用できるのか？ということを問われます。

ただし、受験時の最新であった Xcode 11 ではなかったです。
おそらく、 電子書籍（現時点では Xcode 10  対応）のバージョンに合わせているのだと思われます。

## 感想
### 英語での出題に関して
Twitter で見ていると「試験が英語だから心配」との声が聞こえてきます。
が、私が受験した感じでは「全く問題ない」です。

英語とはいえ、「正しい選択肢を選べ」「画面の正しい位置をクリックしてマークしろ」「ドラッグして選択肢を空欄に入れろ」程度です。
あとは Swift や iOS に関する技術用語なので、それはわかるはずです（わからないなら、日本語でも合格できないです）。

> 参考までに、私が以前に一度だけ受けた TOEIC のスコアは 280 点です（Writing: 140, Speaking:140）😑

### 難易度
難易度は決して高くないです。
意地悪な問題は出ないので、 iOS アプリの開発をすでに行っている方であれば、問題なく合格できると思います。
そうでなくても、入門書を 1 冊こなしていれば十分でしょう。

ロジックをじっくり追うような問題はほとんど出ないので、時間も余裕があります。
私は大体 20 分ちょっとで解き終わり、 10 分くらいで見直して終了しました。
「英語を読むのがちょっと遅い」という方でも、時間は十分だと思います。

### 出題範囲
[App Development with Swift](https://books.apple.com/jp/book/id1219117996)  の範囲なので、広くはないです。
携わっているアプリによっては、この本の中で使ってない機能などもあるかと思います。
そこだけキャッチアップしておくと良いかな、と思います。

例えば、以下の API や機能などは上記の電子書籍で扱っています。

- UITableViewController
- UIAlertController
- UIImagePickerController
- UIActivityViewController
- SFSafariViewController
- MFMailComposeViewController
- MFMessageComposeViewController
- JSONSerialization
- Codable
- JSONDecoder, JSONEncoder
- PropertyListEncoder, PropertyListDecoder
- FileManager
- URLSession
- NotificationCenter

また、ビューコントローラの各ライフサイクルメソッドで何をするべきか、だったり Auto Layout の基本なども確認しておくと良いでしょう。

## まとめ
この試験は難易度的に「エンジニアの能力の証明」よりも「学び始めの人が基本を確認」するような用途に向いていると思います。
[App Development with Swift](https://books.apple.com/jp/book/id1219117996) のコンテンツは、思った以上に役に立つ内容が詰まっています。

「開発には入っているけど、基本の抜けがないか心配」という方は、一度目を通してみると良いでしょう。
その上で、せっかくなので試験も受けてみてはいかがでしょうか？
