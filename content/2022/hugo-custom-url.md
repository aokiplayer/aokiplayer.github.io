+++
title = "Hugo で各記事の URL をカスタマイズ"
date = "2022-03-17T09:50:39+09:00"
draft = false
tags = [ "Hugo" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- 静的サイトジェネレータの [Hugo](https://gohugo.io/) では、記事の URL 階層はデフォルトではディレクトリ階層と一致します
- ですが、場合によっては変更したい場合があります
    - ブログ記事などでは、たとえば ``/diary/2020/04/19`` のような形式にしたい場合もあるでしょう
    - そのためにディレクトリを細かく設定していくのは面倒です
- その際に、必要な設定について記載します

## 検証環境
- hugo v0.93.3

## カスタム URL の指定（Permalinks の設定）
- ``config.toml`` に ``[permalinks]`` 項目を追加することで、記事のパスを自由に設定できます

### サンプル
```toml:config.toml（抜粋）
[permalinks]
  posts = '/:year/:month/:day/:filename/'
```

- 上記の例では、 ``contents/posts`` に配置された各記事の URL は ``2020/04/19/拡張子を除いた記事のファイル名/`` となります
    - 出力イメージは、この記事の URL をご覧ください
- ``:year`` のような設定値は他にも用意されているので、必要に応じて公式サイトで確認すると良いでしょう

## まとめ
- URL を物理的なディレクトリ階層と分けられれば、記事の管理がグッと楽になります
- また、途中でディレクトリ階層を変更しても、記事の URL が変わらないのがありがたいですね

## 参考
- [URL Management | Hugo](https://gohugo.io/content-management/urls/)