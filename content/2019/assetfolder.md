---
title: "Asset Catalogで同じ名前の別画像を利用する"
date: 2019-06-21T09:09:14+09:00
draft: false
toc: true
tags: [ "iOS", "Swift" ]
---

## はじめに
- Xcodeのアセットカタログ（デフォルトではAssets.xcassets）は、画像などのリソースを管理します
- アセットカタログ内で、フォルダ分けも可能です
- その際、別のフォルダに同じ名前の画像を置きたくなることもあります
- その場合の扱い方です

## 検証環境
- Xcode 10.2.1
- iOS 12.2
- Swift 5

## フォルダにNamespaceを付与する
### デフォルトの状態（Namespaceなし）
![no_namespace](/images/assetfolder/no_namespace.png)

- この画像の例では、`bird`という画像が`forest`フォルダと`sea`フォルダの両方に配置されています
- ですが、デフォルトの状態ではフォルダ名は無視されるので、これらの画像には`bird`という名前でアクセスすることになり、区別ができません

### フォルダ名付きでのアクセス（Namespaceあり）
![with_namespace](/images/assetfolder/with_namespace.png)

- アセットカタログ内でフォルダを選択し、Attributes Inspectorから`Provides Namespace`にチェックを入れると、そのフォルダ名がNamespaceとして利用されます
    - フォルダの色も黄色から水色に変わっていますね
- この画像の例では、それぞれ`forest/bird`と`sea/bird`という名前で区別されます
- こんな感じで、コード内でもInterface Builderでも参照できます

    ```swift
    imageView.image = index == 0 ? UIImage(named: "forest/bird") : UIImage(named: "sea/bird")
    ```

    ![image_ib](/images/assetfolder/image_ib.png)

## まとめ
- Namespaceがあると、格段に管理がしやすくなりますね
- 今回作成したサンプルコードは、GitHubに置きました
    - [aokiplayer/AssetFolderSample](https://github.com/aokiplayer/AssetFolderSample)

## 参考
- [Asset Catalog Format Reference: Folders](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/FolderStructure.html#//apple_ref/doc/uid/TP40015170-CH33-SW1)
- [ios - Asset Catalog: Access images with same name in different folders - Stack Overflow](https://stackoverflow.com/questions/33284412/asset-catalog-access-images-with-same-name-in-different-folders)

