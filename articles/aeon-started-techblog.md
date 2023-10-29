---
title: "AEONテックブログはじめるってよ"
emoji: "🐥"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: [ "techblog" ]
published: false
publication_name: "aeonpeople"
---

どうもはじめまして！
イオンスマートテクノロジー株式会社のCTO室でSREやってる[@Tocyuki](https://twitter.com/Tocyuki)です！

というわけで(?)すでに何本か記事が上がってきておりますが、この度テックブログを開設したのでご挨拶と共にイオングループについてテックブログ開設の背景や目的、今後の展望などについてご紹介していければと思います！

# イオンについて

https://www.aeon.info/

多分、イオンという名前を聞いて「なにそれおいしいの？」となる方はあまりいないぐらいには日本国内で認知されている会社だと思います。
しかしながらその実態は巨大なグループ企業であり自分自身もグループ内にどのような会社があって、どのような事業展開されていているのかは正確に把握していませんし、この会社もイオングループだったのか!? と驚くことも少なくありません（しっかりしろ）

https://www.aeon.info/company/group/

ITやWeb技術が当たり前になった現在、御多分に洩れずイオンもその恩恵にあずかりながら様々なグループ会社で様々な事業を展開しており、もちろんエンジニアリング組織も存在しております。

# イオンスマートテクノロジーについて

自分が所属しているイオンスマートテクノロジー株式会社（通称AST）はイオンのデジタルシフト戦略を担う位置付けで2020年10月に設立された設立して4年目を迎えるグループ内では比較的（圧倒的か？）若い会社です。

https://www.aeon-st.co.jp/

しかしながら、社長はイオン（株）の副社長であり、全社のデジタル担当も担っている羽生有希さんだったり

https://www.aeon-st.co.jp/message/01/

CTOはイオン（株）のCTOでもあるヤマケンこと山﨑賢さんが兼任しています。

:::message
最近X（旧Twitter）を再開したらしく、今後のイオンのテクニカルな動向が気になる方は是非フォローをよろしくお頼み申す。
:::

https://twitter.com/yamaken_66

前述の説明からイオンスマートテクノロジーがグループ内においてどのような立ち位置で存在している会社なのか、というのがなんとなく伝わったかと思います。
要するにイオンスマートテクノロジー株式会社（通称AST）はイオンのデジタルシフト戦略を担う位置付けで2020年10月に設立された設立して4年目を迎えるグループ内では比較的（圧倒的か？）若い会社です。
大事なことなの2回言いました。

設立時はイオングループ内からの転籍や出向した方達を中心に出来た会社だったのですが、現在は中途入社者の比率もだいぶ上がってきており、運用や開発の内製化を推進し始めたり、アジャイル開発にも取り組んでいっているフェーズです。

こういった取り組みを行っていたり、内製化を進めているという会社はイオングループ内では珍しく（本当にあまり聞かない）エンジニアリンングへの取り組みやエンジニア組織の在り方なども色々チャレンジできる環境となっています。

もちろんエンタープライズな感じも随所にありありですが、スタートアップやベンチャー感もあるハイブリットエンタープライズJTCというやつですなガハハ。知らんけど。

## 提供しているサービス

イオンスマートテクノロジーではtoC向けとしては主に以下のサービスを提供しております。

https://www.aeon.com/aeonapp/

まだまだUI/UX、機能面、信頼性など様々な改善ポイントがありますが、日々機能追加、修正、改善に取り組んでおりますのでよろしくお願いします！

その他にも店舗向けや他グループ向け、データ基盤、共通基盤、現在サービスローンチに向けて開発を進めているものなど様々なサービスを日々開発、運用しています。

## 技術スタック

イオンスマートテクノロジーでは主に以下の技術スタックを扱っております。

:::message
解像度バラバラで過不足かなりありますが悪しからず
:::

| 領域       | 採用技術                                         |
|----------|----------------------------------------------|
| サーバーサイド  | Java(SpringBoot), Go, PHP(Laravel), .NET, C# |
| モバイル     | Ionic(Angular), Cordova                      |
| フロントエンド  | ﾁｮｯﾄﾖｸﾜｶﾗﾅｲ                                  |
| DB       | MySQL, SQLServer                             |
| クラウドインフラ | Azure, Google Cloud                          |
| インフラ基盤   | Azure Kubernetes Service, Azure App Service  |
| シークレット管理 | HashiCorp Vault                              |
| IaC      | Terraform, Bicep, Ansible                    |
| Git      | AzureRepos, GitHub EMU(移行中)                  |
| CI/CD    | AzurePipeline, GitHub Actions(移行中)           |
| 監視       | Azure Monitor, New Relic, Prometheus         |

ほとんどのサービスがコンテナ化されており、コンテナ基盤としては上記の通りAzure Kubernetes Serviceを採用していますが、一部Azure App Serviceで動かしているサービスもあります。

また、AzureをはじめとしたIaaS/PaaS/SaaSへの投資が積極的に行われており、今後、新しい技術の導入や別の技術へのリプレースなども積極的に進めていこう的な流れもあります。
そんな部分もこのテックブログでお伝えしていけると良いなぁと考えております！

# テックブログ開設の背景と目的

そして満を持して(?)開設されたこのテックブログなのですが、どういった背景と目的で開設したのかをつらつら連ねたいと思います。

まず、前述のヤマケンCTOが2023年４月からイオングループへJoinし、７月にはイオンスマートテクノロジー社にCTO室が発足しました。
自分はヤマケンCTOのリファラルで８月に入社し、入社前から色々と話は聞いたりSREチームのメンバーともコミュニケーションを取ったりしていたのですが、実際のところについてはもちろん入社後に知るところとなりました。
入社後、良い意味でのギャップがたくさんあることを知り、それは自分にとってとてもポジティブなことでした。

SREの領域でいえば、IaCのカバレッジもかなり高く、Terraformのコード設計やモジュールの作り方などかなり洗練されていて、Terraform Cloudなどを導入して活用されていました。

そしてTerraformへのコントリビュートはSREチームだけではなく開発チームがPRを上げる場面も多く、うまくセルフサービス化されている部分が多くありました。
正直、入社前はここまで整備されている部分があるとは思っていなかったのですが採用などを考えた時に候補者が入社前にこれらの良い部分などについて触れる機会がないことをとてももったいなく思いました。
（もちろん課題もそれなりにたくさんありますが...😇）

個人的にもアウトプット文化のある開発組織が好きだし、イオンにもアウトプット文化を根付かせてグループ間交流やコミュニティ活動などを促進できると良いなぁとも思っていました。

そんな話をCTOに相談したところ「やっちゃいなYO」的なお言葉を頂き開設に至る訳ですが、先日投下したイオンテックブログ開設ポストが地味にバズり投稿のハードルが上がってしまいました😇

@[tweet](https://twitter.com/Tocyuki/status/1712260479450853794)

ハードルは上がってしまいましたが(?)ゆるく運営を継続していければなと思いますので生暖かい目で応援などして頂けるとこれ幸いにございます🙇‍♂️

しかし、このポストがきっかけで同じグループ会社であるAEON NEXTの樽石CTOからお声がけいただき、グループ会社間交流が生まれるという胸熱展開へ発展してとりあえず飲みに行くこととなりました🍻

@[tweet](https://twitter.com/taruishima/status/1712352147919286321)

今回、個人的には以下のような目的を持ってテックブログを開設したのですが、早速目的の1つであるグループ間交流に繋がったのはとても良かったです。

- イオンに情報発信の文化を根付かせ、個人のキャリアや採用にポジティブな影響を与える
- この取り組みをきっかけにグループ会社間の交流を促す（グループ会社間の交流がほとんどないので）

また、弊社ではHashiConfのようなグローバルカンファレンスへ参加していたり、外部登壇などなど直近でも様々な対外的活動をしているので、今後こういった活動についてもこのテックブログでご紹介していければなと思います！

## これまでに上がっている登壇関連の記事

https://zenn.dev/aeonpeople/articles/ce113003a878ae
https://zenn.dev/aeonpeople/articles/f126fa84e5aa80
https://zenn.dev/aeonpeople/articles/ce847c17ef3c4b
https://zenn.dev/aeonpeople/articles/3de631bafd1631

# 今後の展望

現在、より良いエンジニア組織を組成するべく様々な取り組みをCTO中心に行っております。
このテックブログの取り組みもそのうちの1つではあるのですが、様々な施策を企画中なので是非楽しみにしててください！

@[tweet](https://twitter.com/yamaken_66/status/1714245029198516595)
@[tweet](https://twitter.com/Tocyuki/status/1716803231005999388)

自社はもちろんグループ会社を巻き込んでいきながら、前述の通りゆるく運営して継続してアウトプット文化を醸成していければなと思います！
また、イオンのようなエンプラ、JTCと揶揄されるような企業でもこれらのようなムーブの輪を広げ、継続していくことでテックカンパニーとしてのブランディングに寄与できていけるよに頑張りたいと思います！

# 絶賛採用中です！

イオンスマートテクノロジーではエンジニアをはじめとした様々な職種を積極的に採用中です！
これからとてもおもしろいフェーズへ突入していくので興味のある方は是非カジュアル面談などで話を聞いてみてください！

https://hrmos.co/pages/ast