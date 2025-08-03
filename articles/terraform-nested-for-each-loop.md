---
title: "Terraformのfor_each内でネストしたloopを書く"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["terraform"]
published: true
---

以下の記事を見かけて、これはもしかするとできるのでは？ と思い、試してみました。

> 以上からわかるようにterraformのfor_eachでは1重のloopしか表現できないことがわかります。

https://zenn.dev/wim/articles/terraform_nest_loop

:::message
引用した記事の内容を批判する意図は一切ありません。
私自身もTerraformのfor_eachでネストしたloopを書く方法が知りたかったので、試してみました。
:::

# 環境
```aiignore
$ terraform -v
Terraform v1.10.4
on darwin_amd64
```

# 引用元の記事にあるコード

```hcl
locals {
  groups = {
    "GROUP_A" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c",
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"
      ]
    }
    "GROUP_B" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"
      ]
    }
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = local.groups
  instance_arn       = "instance_arn"
  # ここは文字列を期待しているのでpermission_set_arnsを渡せない
  # かといってforやfor_eachを使えない...
  permission_set_arn = each.value.permission_sets
  principal_id       = each.key
  principal_type     = "GROUP"
  target_id          = "123456789012"
  target_type        = "AWS_ACCOUNT"
}
```

# 修正後のコード

```hcl

locals {
  groups = {
    "GROUP_A" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c",
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"
      ]
    }
    "GROUP_B" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"
      ]
    }
  }
}

resource "aws_ssoadmin_account_assignment" "main" {
  for_each = merge([
    for group, v in local.groups : {
      for permission_set_arn in v.permission_set_arns :
      "${group}_${permission_set_arn}" => {
        group              = group,
        permission_set_arn = permission_set_arn
      }
    }
  ]...)

  instance_arn       = var.aws_ssoadmin_instances_arn
  permission_set_arn = each.value.permission_set_arn
  principal_id       = aws_identitystore_group.main[each.value.group].group_id
  principal_type     = "GROUP"
  target_id          = "123456789012"
  target_type        = "AWS_ACCOUNT"
}
```

## `terraform_data`で実行してみる
元のコードはAWS Identity Centerのリソースを構築するコードになっていて手元で実行しづらいので `terraform_data` を使ってやりたいことができるかどうか確認していきます。

`terraform_data`についてはこちらの記事を参照してください。

https://zenn.dev/kou_pg_0131/articles/tf-1_4-terraform-data

以下のようなコードに手直しして、`terraform apply`を実行してみます。

```hcl
locals {
  groups = {
    "GROUP_A" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c",
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"
      ]
    }
    "GROUP_B" = {
      permission_set_arns = [
        "arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"
      ]
    }
  }
}

resource "terraform_data" "main" {
  for_each = merge([
    for group, v in local.groups : {
      for permission_set_arn in v.permission_set_arns :
      "${group}_${permission_set_arn}" => {
        group              = group,
        permission_set_arn = permission_set_arn
      }
    }
  ]...)
}
```

以下のような実行結果が得られました。

```txt
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"] will be created
  + resource "terraform_data" "main" {
      + id = (known after apply)
    }

  # terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] will be created
  + resource "terraform_data" "main" {
      + id = (known after apply)
    }

  # terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] will be created
  + resource "terraform_data" "main" {
      + id = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Creating...
terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Creating...
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"]: Creating...
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"]: Provisioning with 'local-exec'...
terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Provisioning with 'local-exec'...
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Provisioning with 'local-exec'...
terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] (local-exec): Executing: ["/bin/sh" "-c" "echo GROUP_B arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] (local-exec): Executing: ["/bin/sh" "-c" "echo GROUP_A arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"] (local-exec): Executing: ["/bin/sh" "-c" "echo GROUP_A arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"]
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] (local-exec): GROUP_A arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"] (local-exec): GROUP_A arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Creation complete after 0s [id=c7edc026-2e7b-433b-020c-89e9894e8d94]
terraform_data.main["GROUP_A_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7b"]: Creation complete after 0s [id=92e9e0e4-23cc-a866-23cc-11477bbae659]
terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"] (local-exec): GROUP_B arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c
terraform_data.main["GROUP_B_arn:aws:sso:::permissionSet/ssoins-12345e7cccc04b03/bs-6bdaf3a33d689a7c"]: Creation complete after 0s [id=cdc644a2-553a-4c05-c1b1-d0ddcf02d7a2]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

本来のコードでやりたかったのは各グループに紐づく`permission_set_arns`を`aws_ssoadmin_account_assignment`に渡すことです。
`terraform_data`で実行した結果を見てみると、各グループに紐づく`permission_set_arns`を取得できていることが確認できたのでやりたいことは出来そうですね。

# コード解説

この部分がまさに本記事の主旨ですが、一見するとなんだかよくわからない感じですよね（最後の`...`が特に）。

```hcl
for_each = merge([
  for group, v in local.groups : {
    for permission_set_arn in v.permission_set_arns :
    "${group}_${permission_set_arn}" => { 
      group              = group, 
      permission_set_arn = permission_set_arn 
    }
  }
]...)
```

ポイントを説明すると以下のような感じです。

- ネストされた`for`ループ を使って、グループごとの`permission_set_arns`を展開
- キーは `${group}_${permission_set_arn}` という一意な形式で作成
- 値は`{ group, permission_set_arn }`というオブジェクト
- `merge([...])`でマップを統合し`for_each`に適した形へ変換

`merge([...])`でマップを統合、については以下のリンクに説明が記載されています。

https://developer.hashicorp.com/terraform/language/functions/merge
https://developer.hashicorp.com/terraform/language/expressions/function-calls#expanding-function-arguments

> If the arguments to pass to a function are available in a list or tuple value, that value can be expanded into separate arguments. Provide the list value as an argument and follow it with the ... symbol:
> (訳：関数に渡す引数がリストまたはタプルの値として利用可能な場合、その値を展開して個別の引数にすることができます。リストの値を引数として指定し、その後に ... 記号を付けてください。)


# おわりに
というわけでやや強引な感じではありますが、Terraformの`for_each`内でネストしたloopを書くことができました。

可読性の低い記述ではあるので賛否の別れそうな書き方ではありますが、 `map object`で各Keyに紐づく特定のリストの値ごとにリソースを作りたい時などにDRYに書けて良さそうではあるのでそこんとこよろしくお願いします。
