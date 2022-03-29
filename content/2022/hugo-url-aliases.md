+++
title = "Hugo で記事の URL にエイリアスを設定する"
date = "2022-03-29T10:19:02+09:00"
draft = false
tags = [ "Hugo" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- 静的サイトジェネレータ [Hugo](https://gohugo.io/) の設定のお話です
- 記事が増えると、 Web サイトを整理したくなりますよね。また、 URL を後から変えたくなることもあります。
- ただ、そうするとどこかからリンクされているページであればリンク切れを起こしてしまい、全部修正して回る羽目になります
- 自分のサイト内のリンクであればそれでもいいかも知れませんが、サイト外からリンクされている場合にはそういう訳にもいかないでしょう
- そのような場合は、記事にエイリアスを設定すれば解決します

## 検証環境
- hugo v0.93.3

## エイリアスの設定
- ページヘッダの Front Matter に ``aliases`` を記載することで、通常の URL に加えて、エイリアスによるアクセスが可能となります
- 実際には、エイリアスにアクセスすると本来の URL にリダイレクトされます

```toml:iosdc2019day1.md（抜粋）
+++
title = "iOSDC 2019 に Mac の環境構築に関する内容で登壇してきました"
date = "2019-09-07T07:33:45+09:00"
draft = false
toc = true
tags = [ "iOSDC", "iOS", "Swift", "macOS" ]
aliases = [ "/posts/iosdc2019day1/" ]
ogimage = "images/open_graph_logo.png"
+++

[iOSDC 2019 に Mac の環境構築の内容で LT 登壇します]({{< ref "/2019/iosdc2019pre.md">}}) で書いていましたが…
```

- 上記の記事に設定される本来のパスは [/2019/09/07/iosdc2019day1/](/2019/09/07/iosdc2019day1/) ですが、 [/posts/iosdc2019day1/](/posts/iosdc2019day1/) でもアクセスできます
- 実際にアクセスして、動作を確認してみてください

## まとめ
- 一度公開した Web ページの URL を変えるのは、いろいろと面倒です
    - でもやりたくなっちゃう
- そんな時は、この記事のようにエイリアスで対応しましょう

## 参考
- [URL Management | Hugo](https://gohugo.io/content-management/urls/)