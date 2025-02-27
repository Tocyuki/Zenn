---
title: "Azure Kubernetes Service で kubenet を使っている場合、RouteTable は切り替えることができない"
emoji: "🐳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Azure", "Kubernetes", "AKS"]
published: false
publication_name: "aeonpeople"
---

# はじめに

イオンスマートテクノロジー（AST）でSREチーム所属の[Tocyuki](https://x.com/Tocyuki)です。

本記事では最近遭遇したAzure Kubernetes Service（以下AKS）+ kubenet 環境下でRouteTable切り替えをしようとして発生した不可解な挙動について理解出来たので備忘録がてら記事にしたいと思います。


# ことの発端
そもそもなんでAKSでRouteTableを付け替えるというよくわからんことをしようとしたのかという背景について説明します。

御存知の通り(?)、弊社ではAzureリソースにスルメ系命名規則を採用しています。

https://zenn.dev/aeonpeople/articles/0b4a4be83d0dfd

最近別の作業をする中で命名規則に沿わない & Terraformでコード化されていないRouteTableリソースを発見しました。

Staging環境でもあったため、命名規則に沿った新しいRouteTableリソースをTerraformで作成して付け替えてしまおうと思ったのがことの発端でした。


# やったことと起きた事象
行った対応は以下です。

1. 旧RouteTableのAKSサブネットとの関連付けを外し、削除する
2. 新RouteTableをAKSサブネットへ関連付けする

上記作業をしたタイミングで、新RouteTableにはAKSへのルート情報（`aks-default-**`から始まるもの）が存在しない状態だったため、通信がまったく出来ない状況になってしまいました。



また、1. の作業で削除したはずの旧RouteTableリソースが復活するという不可解な事象も発生していました。

この作業を実施する前にもう少しドキュメントを読み込むべきだったのですが、Azureの公式ドキュメント[^1]には以下の記載がありました。

> カスタム サブネットにルート テーブルが含まれていない場合は、AKS によって作成され、クラスターのライフサイクル全体にわたってルールが追加されます。 クラスターを作成するときにカスタム サブネットにルートテーブルが含まれている場合、クラスターの操作中に既存のルート テーブルが AKS で認識され、クラウド プロバイダーの操作に応じてルールが追加または更新されます。
> 
> カスタム ルート テーブルにカスタム ルールを追加または更新できます。 ただし、Kubernetes クラウド プロバイダーによって追加されたルールは、更新または削除できません。

つまり以下の状況であったということがわかりました。

- **AKS作成時に指定した独自RouteTableを削除し、別途新しいRouteTableをサブネットに割り当てるという操作はAKSではサポートされていない**
- **「削除したはずの旧RouteTableリソースが復活する」という挙動も「Kubernetes クラウド プロバイダーによって追加されたルールは、更新または削除できません」
という仕様に基づいた挙動である**


# おわりに
今回、Staging環境だったのでサクッとやってしまおうという油断もあり、以下の反省点がありました。

- ドキュメントを読み込まなかった
- 新RouteTableのルート情報の確認をしていなかった

しかしながらこういった細かい仕様、挙動を理解出来る良い機会となり、チーム内でもポストモーテムを行い、知見を共有出来たので同じ轍を踏むことはないだろうということで終わり良ければ全て良し（？）


# イオングループで、一緒に働きませんか？
イオングループでは、エンジニアを積極採用中です。少しでもご興味をもった方は、キャリア登録やカジュアル面談登録などもしていただけると嬉しいです。
皆さまとお話できるのを楽しみにしています！
[![](https://storage.googleapis.com/techhire-prd-assets/AEON/ATH_engineer_Zenn%E3%83%8F%E3%82%99%E3%83%8A%E3%83%BC.png)](https://engineer-recuruiting.aeon.info/)


[^1]: [kubenet で独自のサブネットとルート テーブルを使用する](https://learn.microsoft.com/ja-jp/azure/aks/configure-kubenet#bring-your-own-subnet-and-route-table-with-kubenet)
