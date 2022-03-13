---
title: "プロパティが nil の場合もエンコード先の JSON に属性を出力する"
date: 2022-03-12T22:38:43+09:00
draft: false
toc: true
tags: [ "iOS", "Swift", "JSON" ]
---

## はじめに
- JSON の解析をカスタマイズする方法については [[ネストした JSON をフラットな構造体にマッピングする]]({{< ref "/2021/codable-container.md">}}) で書きました
- 「`Codable` なオブジェクトに nil 値があると、 JSON ではその属性自体が省略されてしまう挙動を変えられないのか？」という質問を受講者から頂いたので、ここに記載しておきます

## 検証環境
- macOS Big Sur 11.6
- Xcode 13.2.1

## サンプルコード
### 通常の挙動（nil を含む属性が出力されない）
```swift:nil を含む属性が出力されない
// JSON と対応させる Person 型（Codable に準拠）
struct Person: Codable {
    let name: String
    let age: Int?   // nil を許容
}

let encoder = JSONEncoder()

let yamada = Person(name: "山田二郎", age: 53)
let kawada = Person(name: "川田吾郎", age: nil)

let yamadaData = try! encoder.encode(yamada)
let kawadaData = try! encoder.encode(kawada)

print("==== 値が nil の属性は出力されない ====")
print(String(data: yamadaData, encoding: .utf8)!)
print(String(data: kawadaData, encoding: .utf8)!)
```

#### 実行結果
```
==== 値が nil の属性は出力されない ====
{"name":"山田二郎","age":53}
{"name":"川田吾郎"}
```

### nil を含む属性を出力するように変更したもの
```swift:nil を含む属性を出力するように変更したもの
// JSON と対応させる CustomPerson 型（Codable に準拠）
struct CustomPerson: Codable {
    let name: String
    let age: Int?   // nil を許容
}

// Encodable プロトコルの encode(to:) メソッドをオーバーライド
// Codable は Encodable & Decodable 型
extension CustomPerson {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)

        // 通常は nil なら無視されるが、明示的にこのフィールドを encode 処理する
        try container.encode(self.age, forKey: .age)
    }
}

let sunagawa = CustomPerson(name: "砂川黄太郎", age: 87)
let umino = CustomPerson(name: "海野泳太郎", age: nil)

let sunagawaData = try! encoder.encode(sunagawa)
let uminoData = try! encoder.encode(umino)

print("==== 値が nil の属性も出力される ====")
print(String(data: sunagawaData, encoding: .utf8)!)
print(String(data: uminoData, encoding: .utf8)!)
```

#### 実行結果
```
==== 値が nil の属性も出力される ====
{"name":"砂川黄太郎","age":87}
{"name":"海野泳太郎","age":null}
```

## まとめ
- `encode(to:)` をオーバーライドして、全項目を明示的にエンコードするだけなので、それほど難しくはないです
    - ただ、若干の手間なので、単にエンコード時にプロパティ指定をするなどの方法があると良いですね
- サンプルは [GitHub](https://github.com/aokiplayer/swift-sandbox/tree/master/JsonWithNullValue) に置きました
