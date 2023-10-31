---
title: "TiDBのスキルアップワークショップを受けてきた"
emoji: "⛳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["TiDB", "NewSQL", "database", "PingCap", "AEON"]
published: true
publication_name: "aeonpeople"
---

:::message alert
本記事はワークショップ参加の報告記事であり、PingCap社の宣伝を意図したものではありません。また、PingCap社から商品や金品、その他経済的利益を授受しておりません。ただしTシャツはもらいました。
:::

イオンスマートテクノロジー株式会社のCTO室でSREやってる[@Tocyuki](https://twitter.com/Tocyuki)です！

先日、PingCap社主催の**TiDBエキスパートへの道：実践的な知識とPingCAP認定のスキルアップワークショップ**に参加して**入社前から気になっていた**TiDBに関する知見を深めて来たのでその感想を書き殴っていきたいと思います！

@[tweet](https://twitter.com/Tocyuki/status/1681298518965899264)

# TiDBとは

最近いろいろなところでTiDBの名前を聞く機会が増えたような気はしないでしょうか？（知らんがな）

TiDBとは以下の特徴を持つ所謂NewSQLと区分されるDBです。

- 簡単な水平スケーリング
- 金融グレードの高可用性
- リアルタイムHTAP
- クラウドネイティブな分散データベース
- MySQL 5.7プロトコルおよび MySQL エコシステムとの互換性

https://docs.pingcap.com/ja/tidb/stable/overview

NewSQLといえばGoogle CloudのCloudSpannerやCockroach Labs社が開発するCockroachDBなどが有名かなと思いますが、いずれもPostgreSQL互換のNewSQLなんですよね。

https://cloud.google.com/spanner?hl=ja

https://www.cockroachlabs.com/

そういえば最近CockroachDBに関するこのポストが話題になりましたね...

@[tweet](https://twitter.com/CockroachDB/status/1702735112419319993)

TiDBは自分のようにMySQLなサービスを多く扱ってきてシャーディングやデータ分析基盤の運用で辛い思いをしているエンジニア、そして絶賛シャーディングなどに苦しめられている弊社の救世主となり得るのか、というわけで(?)ワークショップへ参加することになったという訳でございます。

# ワークショップの内容

ワークショップの内容としては以下のアジェンダの通りとなります。

:::details アジェンダ
## [1日目]

### 講義 (座学)

- TiDB アーキテクチャ概要
- TiDB コンポーネント詳細：TiDB server
- TiDB コンポーネント詳細：TiKV server とTiKVの内部について
- TiDBコンポーネント: PD server
- TiDBでのSQL実行プロセス

### ワークショップ

- TiDB Dedicatedクラスタのセットアップ
- データのインポートとバックアップ設定
- [デモ] Private Linkによるセキュアな接続

## [2日目]

### 講義 (座学)

- 1日目の振り返り
- HTAP機能とTiFlash
- v6.5 LTS v7.1 LTSの新機能

### ワークショップ

- TiDB 固有機能ハンズオン (Auto increment、Clustered PK、Partition)
- TiFlashハンズオン
- [デモ] Online DDL、無停止FailoverとUpgrade
:::

:::message
次回は2024年1月18日(木)〜19日(金)での開催となるようなので興味のある方は是非参加してみてください！
:::

https://pingcap.co.jp/202401-workshop/

# TiDB認定プログラム

2023年11月現在、TiDB認定プログラムとして下記4つの認定試験が用意されています。

- PingCAP Certified TiDB Practitioner
- PingCAP Certified TiDB Associate
- PingCAP Certified TiDB Professional(英語のみ)
- PingCAP Certified TiDB SQL Developer(英語のみ)

https://pingcap.co.jp/certification/

今回受けたワークショップはPingCAP Certified TiDB Administratorの資格に対応しているので、後日受験して無事下記2つの認定試験に合格できました。

- PingCAP Certified TiDB Practitioner
- PingCAP Certified TiDB Associate

@[tweet](https://twitter.com/Tocyuki/status/1718100198403211762)

ちなみにPingCAP Certified TiDB Practitionerの認定試験については無料で何度も受けられるので興味がある方は受験をおすすめします！

# PingCap Education

今回のワークショップでもこのPingCap Educationを利用したのですが、無料で受けられるコンテンツも多くPingCAP Certified TiDB Practitionerであれば、該当コンテンツを一度見るだけで合格できると思います🎉

https://pingcap.co.jp/education/


これから色々なコンテンツが拡充されていくらしいので気になる方は登録して利用してみてください。

# おわりに

TiDBは分散システムなので分散システム特有(?)の複雑なアーキテクチャーを完全に理解できたわけではないですが(当たり前だ)、その深淵の入り口には立てた気がするので受講してみてとても良かったです。

また、ワークショップ講師の関口さんの説明がとてもわかりやすく（理解できない部分ももちろんありましたが）TiDBのこの機能、パラメーターにはどのようなトレードオフがあるり、どのような場面で利用すべきなのかという部分まで言及してくれる場面も多く、そのおかげでより深く理解できました。

先日開催されたServerlessDays Tokyo 2023へもTiDBのセッションを目当てに参加したのですが、登壇予定だったPingCap社CEOのMaxが体調不良で欠席となり急遽打席へ立つことになったのがワークショップの講師を努めていた関口さんでした。

関口さんのセッション内容についてはlogmiに詳しくまとまっており、最近X(旧Twitter)でもバズっていたし、内容もとても面白かったので是非見てみてください。

https://logmi.jp/tech/articles/329530

そんなわけで(?)今回**TiDBエキスパートへの道：実践的な知識とPingCAP認定のスキルアップワークショップ**を受けてみて、今までよくわかっていなかったTiDBの基本的なアーキテクチャーについて学べました。

TiDBについて気になっている方にはおすすめできるワークショップでしたので興味がある方は是非受講してみてください！

# 絶賛採用中です！

イオンスマートテクノロジーではエンジニアをはじめとした様々な職種を積極的に採用中です！
これからとてもおもしろいフェーズへ突入していくと思いますので興味のある方は是非カジュアル面談などで話を聞いてください！

https://hrmos.co/pages/ast
