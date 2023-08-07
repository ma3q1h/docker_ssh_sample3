## 誰でも簡単にDocker3 README2 (運用編)
本書ではdocker仮想環境の運用について解説します  
今後も追記していく予定です

## docker/compose コマンド
仮想環境の操作はdockerまたはdocker compose コマンドを使います. これらは互いに同じものを含んでいます  
docker / docker compose {option} のようにオプションを付けて実行します  
大まかなイメージの為に一覧を掲載します. 記法や用法は各サイトを確認してください (composeはversion2が推奨です)
* build コンテナを作成する
* up コンテナを作成し, 起動する
* down 作成したコンテナ・ネットワーク・(ボリューム・イメージ)を削除
* stop 稼働中のコンテナを停止するが, 削除はしない
* start/restart コンテナを（再）起動
* exec 起動中のコンテナに入る

## コンテナへのアクセス
vscodeでのアクセスを想定しています. 
## 1. vscode(ホストPC)からのアクセス (Remote container)
1. クライアントPCのvscodeからSSHでホストPCに接続します
2. ターミナルでコンテナを起動します(compose_up.sh / 各種コマンド)
3. vscodeの左下 ">< SSH" を選択し, "Attach to Running Container ..." を選択します
4. 別ウィンドウでコンテナのvscodeが開きます
## 2. vscode(クライアントPC)からの直接アクセス
一度設定すればこちらの方が早いです
1. クライアントPCのvscodeからSSHでホストPCに接続します
2. コンテナを起動します(compose_up.sh / 各種コマンド)
3. ホストPCの ~/.ssh/config を以下のように追記します
4. ホストPCのvscodeのリモートSSHから直接コンテナにアクセスできます
```
Host GPU1                                        # SSH識別名(ホストPC)
	HostName xxx.xxx.xxx.xxx                     # ホストPCアドレス
	User hostuser                                # ホストPCユーザー名
	IdentityFile C:\Users\hogehoge\.ssh\id_rsa   # クライアントPCの公開鍵パス
	LocalForward 8888 localhost:8888             # ローカルフォワード設定：Jupyter(8888)の場合
	Port 22                                      # ホストとのSSHポート
	Port 23                                      # コンテナのポート番号

Host GPU1_CONTAINER                              # SSH識別名(コンテナ)
	HostName localhost                           
	Port 23                                      # コンテナのポート番号
	User user                                    # コンテナのユーザー名(=ホストPCのユーザー名)
	IdentityFile ~/.ssh/id_rsa
	ProxyCommand ssh -W %h:%p GPU1               # ホストPCのSSH識別名が入っているので注意
```
繋がらない場合はunkonwn hostなどの消去をお試しください

## Python
この仮想環境はubuntuにデフォルトで入っているpython(system)を汚さないように設計されています (汚して苦労した経験があるので)  
ツールは様々にありますが, バージョン自体の管理の場合はpyenvがおすすめです. この仮想環境もpyenvで管理されています.   
また今回は起動時に指定のpythonバージョンのアクティベート(global)が行われている為, 特別操作は必要ありません.  
```shell
# pythonのバージョン確認(起動時等に把握しておきましょう)
$ python -V
>> 3.9.1
# 現在のpythonバージョン(python -V と一致してなければ参照パスを確認)
$ pyenv versions
>>   system
   * 3.9.1 
# pyenvでインストール出来るバージョン一覧(conda pythonもあります)
$ pyenv install -l

# バージョン切り替え・アクティベート (localはディレクトリ内のみ, globalは全体)
$ pyenv local/global {system, 3.9.1}
```

venvなどの仮想環境を追加で用いる場合は, pyenvでバージョンを指定してから利用すると良いでしょう.  
pyenv + venv のpython環境が個人的には分かりやすくてオススメです
* pyenv: python自体のバージョン管理
* venvなど: バージョン内で環境を分ける

## メモ
一通りの仮想環境整備と機械学習を実行してみての気付きをメモしていきます  
vscodeの色を変更する https://qiita.com/m-tmatma/items/d7ca33496a2ea0743b3a

## 注意
### 1. 仮想環境運用の心得とリソース問題
作成した仮想環境コンテナは内容によって容量を持つことがあります. 特に共有リソースの場合は注意が必要かもしれません. そもそも仮想環境は特定のプログラム/プロジェクトの実行の為だけに存在しているものであり, 保存の為にあるわけではありません.   次のような感覚を持ちましょう. 
1. 重要な実行結果さえ持ち帰れば良いのです. 仮想環境に依存しない形で保存しましょう(ホストPCローカルやクラウドなど)
2. 環境自体はプロジェクト終わったら畳んでしまいましょう
3. Dockerfileさえあれば, 環境は復元できます
4. （機械学習など）利用したい大規模な外部データはマウントやクラウドアクセスなどの方法を取るようにし, ローカルに依存しないようにしましょう  

OS, 機械学習ライブラリなどをフルに含む今回の仮想環境はビルド時点で約15GBになりました. そこに機械学習の生成データやキャッシュなどが加わると30GBを超えます. 個人でも共有でもリソースを把握しておくことは重要です

## 2. 

## 3. 
追記予定