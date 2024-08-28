+++
title = "JavaScript の && 演算子は true/false を返すとは限らない"
date = "2024-01-24T9:00:00+09:00"
draft = false
tags = [ "JavaScript" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
React Hook Form のサンプルを見ていたら、こんなコードがありました。

> というか、React 本家のチュートリアルにもありますね。
> https://ja.react.dev/learn/conditional-rendering#logical-and-operator-

```react:エラーがあれば&&の右を出力
{errors.exampleRequired && <span>This field is required</span>}
```

普段 JavaScript を書かない立場としては、すぐには理解できませんでした。
入力チェックの結果、エラーがある場合ならこういう挙動のはず。
1. `errors.exampleRequired` に何らかのオブジェクトが入っている
1. `true` と評価される
1. 右オペランドが評価される
    1. 右オペランドが `true` と評価されれば、`true` が返される
    1. 右オペランドが `false` と評価されれば、`false` が返される

入力チェックの結果、エラーがない場合ならこうなるよね？
1. `errors.exampleRequired` が `undefined`
1. `false` と評価される
1. 右オペランドを評価せず、`false` が返される

どちらにせよ、`true`/`false` のいずれかが返されるので `<span>This field is required</span>` は出力されないように思えます。
正しく動作させるなら、普通に考えればこうなるかなと。

```react:条件演算子を使うよね
{errors.exampleRequired ? <span>This field is required</span> : ''}
```

JavaScript の `&&` 演算子が Java などと比べて特殊なので、確認してみます。

## && 演算子の基本
JavaScript も C 言語の流れを汲んでいる（基本的な文法の面では）ので、基本的には同じです。

- AND（論理積）を求める
- ショートカット演算子なので、左オペランドを評価して式全体の結果が確定すれば、右オペランドは評価しない

```javascript:論理積を求める
const t1 = true;
const t2 = true;
const f1 = false;
const f2 = false;
t1 && t2    // true
t1 && f2    // false
f1 && t1    // false, f1 を評価した時点で全体の結果が確定するので t1 は評価されない
```

## ちょっと変わった使い方
MDN を見ると、以下のような説明があります。

> 一般的には、この演算子は左から右に向けて評価した際に最初の偽値のオペランドに遭遇したときにはその値を、またはすべてが真値であった場合は最後のオペランドの値を返します。

つまり、論理演算子なので常に `true`/`false` の真偽値を返すと思いがちですが、実際には以下のような挙動となっています。
- 左オペランドが `false` として扱われる値の場合: 左オペランドを返す
- 左オペランドが `true` として扱われる値の場合: 右オペランドを返す

上記の挙動に当てはめた結果、真偽値型の場合は我々のよく知る挙動となっているわけですね。

ということで、真偽値型以外に適用するとこんなことが起こってしまうわけです。
直感に反しますよね。

```javascript:田中さん AND 里田さん -> 里田さん
const tanaka = '田中まさひろ';
const satoda = '里田まい';

tanaka && satoda  // '里田まい'
```

### では最初の例は？
```react:エラーがあれば&&の右を出力
{errors.exampleRequired && <span>This field is required</span>}
```

以下の挙動となります。

#### 入力チェックの結果、エラーがある場合
1. `errors.exampleRequired` に何らかのオブジェクトが入っている
1. `true` と評価される
1. 右オペランドが返されて、メッセージを出力

#### 入力チェックの結果、エラーがない場合
1. `errors.exampleRequired` は `undefined`
1.  `false` と評価される
1.  左オペランドが返されて、`undefined` なので React は何も出力しない

## まとめ
Java などの、型を厳密に扱う言語に慣れていると JavaScript の `&&` の挙動は不思議に思えますね。
ですが、ドキュメントをしっかり読めば説明はあるので、注意して少しずつ慣れていきましょう。

## 参考
- [論理 AND 演算子 (&&): 条件付きレンダー – React](https://ja.react.dev/learn/conditional-rendering#logical-and-operator-)
- [論理積 (&&) - JavaScript | MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Operators/Logical_AND)
