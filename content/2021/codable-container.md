+++
title = "ネストした JSON をフラットな構造体にマッピングする"
date = "2021-03-08T10:17:14+09:00"
draft = false
toc = true
tags = [ "iOS", "Swift", "JSON" ]
ogimage = "images/open_graph_logo.png"
+++

## はじめに
- Swift では `Encodable`, `Decodable`プロトコルと `JSONEncoder`, `JSONDecoder` を利用すれば、 HTTP 通信で取得した JSON と Swift オブジェクトを一発変換できます🙂
- が、ネストした JSON を扱う場合には Swift 側の対応する型（構造体を使うことが多い）も同じ構造にネストする必要があります😔
- 公開されている Web API では、何階層にもネストしてる JSON も多いので、ネストした階層分だけ構造体を定義するのは面倒ですし、扱いづらくなります
- そのような場合には、以下の 2 つを実装すると解決できます
    - `Encodable` のメソッド `encode(to:)`
    - `Decodable` のイニシャライザ `init(from:)`
- 定義は少し面倒ですが、一度作成してしまえばとても使いやすくなります

## 検証環境
- macOS Big Sur 11.2.1
- Xcode 12.4

## サンプル
```json:解析対象のJSON
{
    "user_name": "山田二郎",
    "scores": [
        { "score": 65 },
        { "score": 24 }
    ]
}
```

上記の JSON は、構造として全体を表す `{}` の中に、 `"scores"` 部分が配列となっており、その要素が `{}` となっています。
つまり、「オブジェクト」->「配列」->「オブジェクト」の 3 階層です。
配列は Swift で `Array` 型が定義されているので、自分で用意する必要があるのは 2 つの構造体であることがわかります。

## JSON に対応させた構造体（基本）
この JSON の階層に単純に対応させるなら、以下のような 2 つの構造体が必要となります。

```swift:JSONの階層に素直に対応させた構造体
// JSONと対応させるPerson型（Codableに準拠）
struct Person: Codable {
    let name: String
    let scores: [Score]

    /// SwiftのプロパティとJSONのキーをマッピング
    enum CodingKeys: String, CodingKey {
        // case Swift側の名前 = "JSON側のキー"
        case name = "user_name"
        case scores
    }
}

// Personのプロパティとして利用する型（Codableに準拠）
struct Score: Codable {
    let score: Int
}
```

しかし、 `"scores"` 部分は属性が `"score"` しかないため、整数の配列にしておいた方が扱いやすそうです。

## JSONに対応させた構造体（階層構造を変更）
### クラス定義
こんな感じで、 1 階層浅くしたら使いやすそうですね。
`"scores"` は `Int` の配列であるため、定義する型は `Person` のみです。
上のサンプルにある、 `Score` 型は定義する必要はありません。

階層ごとの `CodingKeys` だけは用意しておきましょう。名前は任意です。

```swift:JSONと異なる階層構造の構造体
// JSONに対応する構造体
struct Person: Codable {
    let name: String
    let scores: [Int]

    // トップレベルの属性に対応するCodingKeys
    enum CodingKeys: String, CodingKey {
        case name = "user_name"
        case scores
    }
    
    // ネストしたJSONの属性に対応するCodingKeys
    enum ScoresCodingKeys: String, CodingKey {
        case score
    }
}
```

このままでは、 JSON と形が異なるため相互変換ができません。
エクステンションで、カスタムデコード用のイニシャライザとカスタムエンコード用のメソッドを追加してみましょう。

### カスタムデコード用の追加実装
```swift:カスタムデコード用のイニシャライザ
extension Person {
    init(from decoder: Decoder) throws {
        // CodingKeysを指定し、JSON直下の属性（"user_name"と"scores"にあたる部分）に対するコンテナを取得
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        // JSONのキー"user_name"にあたる部分の値を取得
        let name = try rootContainer.decode(String.self, forKey: .name)
        
        // ネストしたオブジェクト（キー"scores"）の配列部分（配列なので中身の各要素にはキーがない）のコンテナを取得
        var arrayContainer = try rootContainer.nestedUnkeyedContainer(forKey: .scores)

        var scores: [Int] = []

        // 配列の要素の最後になるまで繰り返し
        while !arrayContainer.isAtEnd {
            // ネストした部分のCodingKeys（ここではScoresCodingKeys）を指定し配列内のオブジェクト部分のコンテナを取得
            let scoreContainer = try arrayContainer.nestedContainer(keyedBy: ScoresCodingKeys.self)
            
            // JSONのキー"score"にあたる部分の値を取得
            let score = try scoreContainer.decode(Int.self, forKey: .score)

            // 取得した値を配列に追加
            scores.append(score)
        }

        // 取得した値をメンバワイズイニシャライザに渡して初期化
        self.init(name: name, scores: scores)
    }
}
```

#### 実装のポイント（JSON -> 構造体）
- イニシャライザの引数である `Decoder` を利用する
    - 解析は、この `Decoder` を通して行います
- `Decoder` の `container(keyedBy:)` に `CodingKeys` を渡して、該当部分のコンテナを取得
    - `CodingKeys` が JSON のキー（と、それに対応する構造体のプロパティ名）を保持しているため、そのコンテナを通して値を取得できるようになります
- コンテナからは `decode(_:forKey:)` で `CodingKeys` に定義したキーを渡して、該当部分の値を取得
    - コンテナには `container(keyedBy:)` で `CodingKeys` が渡っているため、そこに定義したキーで値を取得できます
- ネストした部分のコンテナは、上位階層のコンテナから `nestedContainer(keyedBy:)` や `nestedUnkeyedContainer(forKey:)` で取得
    - 通常の属性の場合は `nestedContainer(keyedBy:)` を利用しますが、値が配列の場合には中の各要素にキーがないため、 `nestedUnkeyedContainer(forKey:)` を利用します
- `nestedContainer(keyedBy:)` を呼び出すごとに、内部的なカーソルが次へ移動する
    - コンテナの `isAtEnd` を条件としてループを回せば、要素の回数だけループを回せます
    - そのためループ内で、`nestedContainer(keyedBy:)` を呼び忘れると無限ループに陥るので注意が必要です

### カスタムエンコード用の実装
```swift:カスタムエンコード用のメソッド
extension Person {
    // カスタムでエンコードするためのメソッド
    func encode(to encoder: Encoder) throws {
        // CodingKeysを指定し、JSON直下の属性（"user_name"と"scores"にあたる部分）に対するコンテナを取得
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // JSONのキー"name"にあたる部分をエンコード
        try container.encode(self.name, forKey: .name)

        // ネストしたオブジェクト（キー"scores"）の配列部分（配列なので中身の各要素にはキーがない）のコンテナを取得
        var scoresContainer = container.nestedUnkeyedContainer(forKey: .scores)

        // scores配列をループし、各要素をエンコード
        for score in scores {
            // ネストした部分のCodingKeys（ここではScoresCodingKeys）を指定し配列内のオブジェクト部分のコンテナを取得
            var arrayContainer = scoresContainer.nestedContainer(keyedBy: ScoresCodingKeys.self)

            // JSONのキー"score"にあたる部分をエンコード
            try arrayContainer.encode(score, forKey: .score)
        }
    }
}
```

#### 実装のポイント（構造体 -> JSON）
- 基本的な考え方は、デコードの際と同じです
- JSON と構造体の構造を注意深く比較し、上の階層から順に処理していけばできると思います

## まとめ
- 階層に合わせて構造体を複数定義しても問題ないですが、フラットな構造の方が扱いやすいですよね
- 記述量は増えますが、利用する場面のことを考えると、最初に手間をかけておくメリットは十分にあると思います
- サンプルは [GitHub](https://github.com/aokiplayer/swift-sandbox/tree/master/CodableContainer) に置きました

## 参考サイト
- [Using JSON with Custom Types | Apple Developer Documentation](https://developer.apple.com/documentation/foundation/archives_and_serialization/using_json_with_custom_types)
    - Playground が用意されているので、動かしながら理解できます
