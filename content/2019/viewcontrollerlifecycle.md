---
title: "UIViewControllerのライフサイクルメソッド"
date: 2019-05-21T12:19:51+09:00
draft: false
toc: true
categories: [ "Technical" ]
tags: [ "iOS", "Swift" ]
---

## はじめに

- iOSアプリを作成していて、どのタイミングでどのメソッドが呼ばれるんだっけ？となることは多いです
- 特に、画面遷移の際に困ることがあります
- なので、非常に単純なサンプルを作成しておきました
    - 各メソッド内で、コンソール出力をしているのみです

## 検証環境

- Xcode 10.2
- iOS 12.2
- Swift 5

## サンプルプロジェクト

- [aokiplayer/ViewControllerLifeCycleSample](https://github.com/aokiplayer/ViewControllerLifeCycleSample)

## サンプルの画面構成

- 画面はストーリーボードで作成しています
- A, Bの2画面があり、以下のように遷移します（Aが初期画面）
    - A -> Bは、単純にPresent Modallyなセグエで遷移
    - B -> Aは、unwindセグエで遷移

    ![segue_image](/images/viewcontrollerlifecycle/vc_lifecycle_segue.png)

## コンソール出力例
### アプリ起動（Aを表示）
- レイアウト系が2度呼ばれています
    - レイアウトは、様々なタイミングで呼ばれるのでこのように複数回呼ばれる可能性があるためです
        - boundsが変更されたり、サブビューが追加されたりしても呼ばれます
    - Auto Layoutの制約を明示的に設定せず、Autoresizing maskをAuto Layoutに変換した場合などは1度しか呼ばれなかったりします

```console
A: init(coder:)
A: loadView()
A: viewDidLoad()
A: viewWillAppear(_:)
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
A: viewDidAppear(_:)
```

### 画面を回転（A画面表示中）
- レイアウトを組み直す必要が発生するので、こんな感じですね

```console
A: viewWillTransition(to:with:)
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
```

### HOMEボタンを押す（A画面表示中）
- 画面は表示されなくなりますが、実際にはいずれのコールバックも呼ばれていません
    - このあたりの挙動は、Androidとは異なりますね（Androidではこのタイミングでもコールバック呼ばれる）

```console
```

### HOME画面でアイコンをタップ（上記の操作後）
- 非表示状態からの復帰ですが、いずれのコールバックも呼ばれていません
    - これも、Androidの場合はコールバックが呼ばれますね

```console
```

### Bへ遷移（Present Modallyセグエ）
- ポイントはAの`prepare(for:sender:)`のタイミングです
    - ここで必要なデータの受け渡しを行いますが、Bの`viewDidLoad()`よりも前です
    - そのため、この時点ではBの持っているビューはnilであり、データを渡そうとすると実行時エラーとなります

```console
    B: init(coder:)
A: prepare(for:sender:)
    B: loadView()
    B: viewDidLoad()
A: viewWillDisappear(_:)
    B: viewWillAppear(_:)
    B: viewWillLayoutSubviews()
    B: viewDidLayoutSubviews()
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
    B: viewWillLayoutSubviews()
    B: viewDidLayoutSubviews()
    B: viewDidAppear(_:)
A: viewDidDisappear(_:)
```

### Aへ戻る（unwindセグエ）
- unwindセグエで戻る際も、`prepare(for:sender:)`は呼ばれています

```console
    B: prepare(for:sender:)
A: unwindToFirst(_:)
    B: viewWillDisappear(_:)
A: viewWillAppear(_:)
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
A: viewDidAppear(_:)
    B: viewDidDisappear(_:)
    B: deinit
A: viewWillLayoutSubviews()
A: viewDidLayoutSubviews()
```

## まとめ

- 初心者の陥りやすい点としては、`prepare(for:sender:)`内でのデータの受け渡しです
- 「遷移先画面のビューはまだnil」という点は、しっかり認識しておきましょう
