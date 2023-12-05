---
title: "New Relic Alert 閾値チューニング入門"
emoji: "🆕"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["NewRelic","監視","運用"]
published: true
publication_name: "aeonpeople"
---

この記事は、[AEON Advent Calendar 2023](https://qiita.com/advent-calendar/2023/aeon)と[New Relic Advent Calendar 2023](https://qiita.com/advent-calendar/2023/newrelic)の6日目です🎉

# New Relic Alert 閾値設定難しすぎﾜﾛﾀｧ

以下の図にあるような設定項目を全部理解して設定できているという方はさっさと帰っていただいて結構ですが（うそですごめんなさい）、それぞれのパラメーターの意味がよく理解できず`Static Threshold Type`のみでなんとなく閾値設定頑張っている、という方も多いのではないでしょうか？（知らんけど）

特に`Window duration`や`Streaming method`、`Gap filling Strategy`あたりは仕組みが少々複雑でなかなか理解するのが難しくNewRelic初心者の方々には取っ付き難い部分かと思います（ワイもよくわかってない説ある）

![](/images/introduction-to-newrelic-alert-threshold-settings/1.png)
*ここをすべて理解して設定していると言えるのかい？*

New RelicではAlertの閾値を以下のさまざまなパラメーターにより、きめ細かく柔軟に設定できます。
本記事ではそれぞれのパラメーターで最低限抑えておくと良い部分を中心に説明していこうと思います！

- Threshold Type
  - Static
  - Anomaly
- Data Aggregation
  - Window duration
  - Sliding window aggregation
- Streaming method
  - Event flow
  - Event timer
- Gap filling Strategy

# Threshold Type

New Relic Alert 閾値設定の基本のキであるThreshold Typeは間違いなく抑えておきましょう！
これは閾値をどのように検知するかを決める設定で、Static(静的検知)かAnomaly(異常検知)を選択できます。

Static/Anomalyがそれぞれどのようなパラメーター、ユースケースで選択するかについては以下の通りです。

| パラメーター    | 説明                             | ユースケース                                 |
|-----------|--------------------------------|----------------------------------------|
| `Static`  | あらかじめ設定した静的な閾値の超過有無で判定         | 良し悪しを判断できる明確な基準が設けられる場合                |
| `Anomaly` | 過去のデータに基づいて予測された正常範囲からの逸脱有無で判定 | 周期性の異常を判定したい場合や良し悪しを判断できる明確な基準や材料がない場合 |

もう少し深掘りしていきます。

## Static

前述の通り**あらかじめ設定した静的な閾値の超過有無で判定**する設定ですが、グラフで見るとわかりやすいかと思います。
画像の赤色の線を越える or 下回るとインシデントがオープンされます。

![](/images/introduction-to-newrelic-alert-threshold-settings/2.png)

![](/images/introduction-to-newrelic-alert-threshold-settings/3.png)
*設定画面はこんな感じで設定項目もシンプル*

### 閾値超過の評価方法

Threshold Type Staticの評価方法は以下の2通りです。

| 評価方法                          | 説明                               |
|-------------------------------|----------------------------------|
| `for at least XX minutes`     | XX分間閾値を超過する状態が続いたらインシデントがオープンされる |
| `at least once in XX minutes` | XX分間の間に1回でも超過したらインシデントがオープンされる   |

画像の例だと`When a query returns a value above 1 for at least 5 minutes`となっているので`クエリ結果の値が1以下でその状態が5分間継続`した場合にインシデントをオープンする設定になっています。

前述の通り、**良し悪しを判断できる明確な基準が設けられる場合**のユースケース、たとえば「CPU使用率が90％を超えた場合」などのアラートを設定したい場合などに有用です。

## Anomaly

前述の通り**過去のデータに基づいて予測された正常範囲からの逸脱有無で判定**する設定ですが、こちらもグラフで見るとわかりやすいかと思います。
画像の灰色の範囲を逸脱すると異常と見做されインシデントがオープンされます。

![](/images/introduction-to-newrelic-alert-threshold-settings/4.png)

Anomalyの場合、Staticに比べ`Threshold direction`という設定項目が増えています。

![](/images/introduction-to-newrelic-alert-threshold-settings/5.png)

### Threshold direction

`Upper and lower`, `Upper only`, `Lower only`が選択でき、値に対してどの方向へのびた場合に検知するかを設定できます。

例えば`Upper only`だとこんな感じで値がいくら低くなっても検知しません。

![](/images/introduction-to-newrelic-alert-threshold-settings/6.png)

### Standard Deviation

Staticでは静的な値を閾値で設定しましたがAnomalyの場合、標準偏差を指定します。
標準偏差の値の増減で正常といえる範囲を設定します。

:::message
標準偏差とは簡単に言うと、平均からのズレを表す数値のことです
:::

標準偏差を`3`にした場合と`6`にした場合のグラフを見比べてみてみましょう。

![](/images/introduction-to-newrelic-alert-threshold-settings/7.png)
*標準偏差を`3`にした場合*

![](/images/introduction-to-newrelic-alert-threshold-settings/8.png)
*標準偏差を`6`にした場合*

こんな感じでSeverity levelのWarning/Criticalで標準偏差の値を変えて設定し、運用の中で必要に応じて値をチューニングしていくと良いでしょう。

# Window duration

Window durtionについての説明に関しては以下の記事を見ていただくのをオススメします。

https://newrelic.com/jp/blog/how-to-relic/alert-configuration-guidance#toc-window-duration

記事から引用しますがWindow durationとは

> 評価対象のデータを集約する期間を定義するものです。
> 1minであれば1min範囲内のデータが集約対象、2minであれば2min範囲内のデータを集約します。

とのことなのですが、もしかしたらちょっとわかりづらいかもしれないので図も引用します。

![](/images/introduction-to-newrelic-alert-threshold-settings/9.png)

### どんな時に使うと良いのか

基本的にはデータの山谷が激しいく、短期間の集約では適切に評価できないようなデータでのアラート設定時に利用するのが良いと思います。

以下はスループットのアラート設定時にWindow durationを1分に設定した時のグラフですが、データの山谷が激しいことを確認できます(激しいか?)

```sql:NRQL
SELECT rate(count(apm.service.transaction.duration), 1 minute) AS 'Throughput' FROM Metric WHERE entity.guid IN ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') FACET appName TIMESERIES 1 minute SINCE 6 hours ago
```

![](/images/introduction-to-newrelic-alert-threshold-settings/10.png)
*Window durationを1分に設定した時のグラフ*

もっと平滑化したデータで評価をしたい、となった場合にWindow durationを例えば5分などにしてみると以下のようなグラフになります。

:::message
平滑化とは連続するデータの集まりにおいて特異点やノイズをなくすため、ある点のデータをその近傍の点のデータを用いて、平均化処理を行い、スムーズにつながるデータの集まり(曲線)とすることです
:::

```sql:NRQL
SELECT rate(count(apm.service.transaction.duration), 1 minute) AS 'Throughput' FROM Metric WHERE entity.guid IN ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') FACET appName TIMESERIES 5 minute SINCE 6 hours ago
```

![](/images/introduction-to-newrelic-alert-threshold-settings/11.png)
*Window durationを5分に設定した時のグラフ*

Window durationを大きくした場合の注意点もあるので以下に引用します。

> なお、Window durationを大きくした場合、集約する期間が広がるため、アラート通知のタイミングもそれに従います。つまり、Window
> durationが2minであれば、最短2min間隔となります。Window durationを広げつつ、アラート通知タイミングを細かくしたい場合は、Sliding
> windowを利用して評価範囲をオーバーラップさせます。

というわけでWindow durationを広げるが、アラート通知タイミングを細かくしたい場合にはSliding window aggregationを利用してあげる必要があります。

## Sliding window aggregation

Sliding window aggregationについての説明に関しても以下の記事を見ていただくのをオススメします。

https://newrelic.com/jp/blog/how-to-relic/alert-configuration-guidance#toc-sliding-window

https://docs.newrelic.com/jp/docs/query-your-data/nrql-new-relic-query-language/nrql-query-tutorials/create-smoother-charts-sliding-windows/

そしてこちらも図の方が理解しやすいので、図を引用します。
図の通り、評価範囲をオーバーラップすることで`for at least XX minutes`や`at least once in XX minutes`などで設定する評価期間を短く設定できるようになります。

:::message alert
`Sliding window`で設定した値が評価期間の下限となります
:::

![](/images/introduction-to-newrelic-alert-threshold-settings/12.png)

# Streaming method

Streaming methodは特定の集計ウィンドウのデータが揃ったことを判定するロジックとなり、現在、`Event flow`, `Event timer`, `Cadence`の3種類のロジックが用意されています。

:::message alert
`Cadence`はレガシーな設定パラメーターで非推奨のため言及しません
:::

こちら中々説明が難しいので簡単にまとめると以下のような使い分けをすると良いのかなと思います。

| Streaming method | ユースケース            | 具体例                                           |
|------------------|-------------------|-----------------------------------------------|
| Event flow       | コンスタント且つ高確率で届くデータ | APM/Infrastructure/Browserエージェントなど            |
| Event timer      | 発生や到着にムラのあるデータ    | API PolingによるCloud IntegrationやMobileエージェントなど |

:::message
Mobileエージェントはデフォルト10分間隔でデータを送信するため、デフォルト設定の場合はEvent timerのtimerも10分以上にするのが望ましいです
:::

より詳細については以下も参照してみてください。

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/get-started/choose-your-aggregation-method/

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/advanced-alerts/understand-technical-concepts/streaming-alerts-key-terms-concepts/

https://newrelic.com/jp/blog/nerdlog/new-aggregation-methods-for-nrql-alert-conditions

# Gap filling Strategy

Gap filling Strategyは欠損データの取り扱い定義に関するパラメーターです。
よくわからず`none`を選択する場面も多いと思いますが、データの欠損がクリティカルな影響を与える場面では`Custom static vlaue`でアラートを上げるような値を入れたり、妥当な値を入れるなどの調整をすると良いでしょう。
また、値が予測可能で短時間で大きく変化しない場合などは`Last known value`を設定すると良いでしょう。

| パラメーター                | 説明       |
|-----------------------|----------|
| `none`                | 欠損のまま扱う  |
| `Custom static value` | 固定値で埋める  |
| `Last known value`    | 前出の値で埋める |

詳細については以下を参照してみてください。

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/alert-conditions/create-nrql-alert-conditions/#data-gaps

# まとめ

- `Threshold Type`は基本なのでしっかり理解して設定する
- データを平滑化して評価したい場合`Window duration`を大きくし、`Window duration`の値よりも通知のタイミングを細かく設定したい場合には`Sliding window`を利用する
- Streaming methodは特定の集計ウィンドウのデータが揃ったことを判定するロジックのこと
  - `Cadence`は非推奨のため利用しない
  - 継続的に送られるようなデータ（APM/Infrastructure/Browserエージェントなど）を取り扱う場合`Event flow`を利用する
  - 発生や到着にムラがあるようなデータ（API PolingによるCloud IntegrationやMobileエージェントなど）を取り扱う場合は`Event timer`を利用する
- `Gap filling Strategy`は欠損データの取り扱い定義に関するパラメーターのこと
  - `none`は欠損のまま扱う
  - データの欠損がクリティカルな影響を与える場面では`Custom static vlaue`でアラートを上げるような値を入れたり、妥当な値を設定する
  - 値が予測可能で短時間で大きく変化しない場合などは`Last known value`を設定する

# 参考

以下、New Relic Alert設定関連で参考になるリンクなので興味があれば是非見てみてください！

https://docs.newrelic.com/jp/docs/tutorial-create-alerts/create-an-alert/

https://docs.newrelic.com/jp/docs/new-relic-solutions/best-practices-guides/alerts-applied-intelligence/alerts-best-practices/

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/advanced-alerts/understand-technical-concepts/streaming-alerts-key-terms-concepts/

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/alert-conditions/create-nrql-alert-conditions/#data-gaps

https://docs.newrelic.com/jp/docs/alerts-applied-intelligence/new-relic-alerts/advanced-alerts/understand-technical-concepts/streaming-alerts-key-terms-concepts/

https://newrelic.com/jp/blog/how-to-relic/understand-nrql-alert-condition

# 絶賛採用中です！

イオンスマートテクノロジーではエンジニアをはじめとした様々な職種を積極的に採用中です！
これからとてもおもしろいフェーズへ突入していくと思いますので興味のある方は是非カジュアル面談などで話を聞いてください！

https://hrmos.co/pages/ast
