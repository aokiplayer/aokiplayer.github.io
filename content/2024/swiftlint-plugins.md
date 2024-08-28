+++
title = "Build Tool プラグインとしての SwiftLint 導入時のエラー対処"
date = "2024-08-01T09:00:00+09:00"
draft = false
tags = [ "iOS", "Swift", "SwiftLint", "Swift Package Manager" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
Xcode 15.4 で、Build Tool プラグインとしての SwiftLint の実行に失敗する現象に遭遇しました。
基本的には SwiftLint パッケージをプロジェクトに導入 -> `Build Phases` の `Run Build Tool Plug-ins` に追加するだけで動作するはず（以前は動作していた）なのですが、Xcode のマイナーバージョンアップをしたところエラーが発生するようになりました。

細かくは検証できていませんが、Xcode 15.1 から 15.4 の間のどこかからのようです。
また、SwiftLint 自体も、導入の際に指定する URL が変わっていたりするようです。

執筆時点で最新の、Xcode 15.4 における回避方法を記載します。

今回、iOS プロジェクトは Xcode のウィザードから作成したものを利用しています。
そのため、今回はマニフェストファイルを利用せず、Xcode からパッケージを追加します。

## 検証環境
- macOS Sonoma 14.5 (23F79)
- Xcode 15.4 (15F31d)

## 導入手順
### SwiftPM を利用して SwiftLint への依存性を追加
1. Xcode メニュー -> `Add Package Dependencies...`
1. 検索欄に `https://github.com/SimplyDanny/SwiftLintPlugins` を入力し、`Add Package` ボタンをクリック
    - URL が SwiftLint 公式のものでない点に注意
        - 以前の手順では、公式の `https://github.com/realm/SwiftLint` となっていた
    - `Dependency Rule` は `Up to Next Major Version` のままで OK

    ![swiftlint_add.png](/images/swiftlint-plugins/swiftlint_add.png?width=50pc)

### Build Phases から Run Script を追加
1. アプリターゲットを選択し、`Build Phases` タブを選択
1. `+` アイコンから `New Run Script Phase` を選択して `Run Script` を追加し、ドラッグして `Compile Sources` の後へ移動
1. 以下の内容を `Run Script` で実行するスクリプトとして貼り付け
    ```bash
    SWIFT_PACKAGE_DIR="${BUILD_DIR%Build/*}SourcePackages/artifacts"
    SWIFTLINT_CMD=$(ls "$SWIFT_PACKAGE_DIR"/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/swiftlint-*/bin/swiftlint | head -n 1)
    
    if test -f "$SWIFTLINT_CMD" 2>&1
    then
        "$SWIFTLINT_CMD"
    else
        echo "warning: `swiftlint` command not found - See https://github.com/realm/SwiftLint#installation for installation instructions."
    fi
    ```

    ![run_script.png](/images/swiftlint-plugins/run_script.png?width=50pc)

本来は `Build Phases` の `Run Build Tool Plug-ins` に SwiftLintBuildToolPlugin を追加するだけで OK なはずですが、プロジェクトのディレクトリ構成など様々な理由により上手くいかないことがあるようです。
その回避策として、SwiftLint の公式サイトで上記の方法が示されていました。

## 実行
command + B などでビルドを実行すると、SwiftLint が実行されます。
<img width="80%" alt="swiftlint_warning.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/100115/5fccf168-6a93-62eb-64ce-f3b5eb844a4c.png">

通常通り設定ファイル `.swiftlint.yml` をプロジェクトのルートディレクトリに配置して、チェックするルールをカスタマイズできます。ルールについて詳しくは、公式サイト内の [Rules](https://github.com/realm/SwiftLint?tab=readme-ov-file#rules) の項目をご覧ください。

## まとめ
SwiftPM の Build Tool プラグインや、Xcode の Build Phases などに関してはまだ理解が浅い点が多いのですが、SwiftLint の公式サイトを見ても「Xcode 15 でパーミッションが変わった」とか「Apple Silicon だと Homebrew でインストールされるパスが変わった」とかいろいろ書かれています（後者は今回の件とは無関係ですが）。
まずは、公式の情報を見て環境を構築できるのが大切ですね。その上で、必要な部分を深掘りしていきたいと思います。

## 参考
[realm/SwiftLint: A tool to enforce Swift style and conventions.](https://github.com/realm/SwiftLint)
