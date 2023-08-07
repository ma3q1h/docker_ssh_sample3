## 誰でも簡単にDocker3 README1 (設定編)
この章では仮想環境の設定について書いていきます

### 事前設定, 前提条件
1. ホストPCにsudoユーザ作成. クライアントPCからSSH接続, 公開鍵接続. 
2. ホストPCに公開鍵があることを確認 (~/.ssh/authorized_key)
3. ホストPCにdockerインストール dockerグループ作成
4. dockerグループにユーザを追加 (リブートしないと反映されないことがあります)
5. docker composeのインストールと確認
```shell
# dockerグループの確認
$ getent group docker
# dockerグループにユーザを追加
$ sudo usermod -aG docker $USER
```

dockerとcomposeの説明は他に任せますが, 今回のdockerの流れです
![Test Image 1](/pic/2023-08-05 005852.png)

また、ポートの概略です
![Test Image 2](/pic/2023-08-05 005930.png)

今回は一般的な方法に, compose_up.shとmake_env.shが加わっています.   
* compose_upは仮想環境の構築から起動までの一連の流れ①～④をまとめて実行します  
* .envはBuild時に指定する環境定数なのですが, `whoami`, `id -g`などの展開が必要となるので, make_env.shで.envを生成するようにします

### 個人設定が必要なものについて以下1~4を解説をします. "ベースを決めて, 変数を定義して, 設計図を書く"という番号の流れですが, 適宜相互に行ってください

# 1. Based Docker image
実は全てDockerfileだけで仮想環境を構築することも可能です. しかし, ベースとなる仮想環境イメージを使うことでフレームワークのバージョン切り替えなどを更に容易にすることが出来ます.   
フレームワークの規模は様々です. 普通に仮想環境OSの構築や, Anacondaのようにpython仮想環境の作成, 機械学習だとTensorfrowやCUDAなど.  
使いたいフレームワークが決まったら, Docker hubなどから入手してください. 
```shell
# dockerイメージのダウンロード
$ docker pull {hogehoge:hogehoge}
# dockerイメージの存在確認
$ docker images
```  
私の例ではtransformersの利用を想定したフレームワークを選んでいます （OS: Ubuntu 20.04 CUDA: 11.8 cuDNN: 8）  
この場合, nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04というimage(リポジトリ)になりました.
CUDAのバージョン切り替えは面倒なので, 仮想環境の作成に最適です.  
任意のimageを入手したら, Dockerfileの先頭を編集してください. 今回の例だと以下のようになっています.  
```dockerfile
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
```

# 2. make_env.sh
.envを生成する実行ファイルです. make_env.shの`cat`部分を編集・追記してください
```sh
COMPOSE_PROJECT_NAME="projectname-`whoami`"    # 'projectname'部分のみを編集してください("-"は残すのがオススメ)
USER=`whoami`                                  # ホストPCのユーザー名が展開されます
UID=`id -u`                                    # ホストPCのUIDが展開されます
GID=`id -g`                                    # ホストPCのGIDが展開されます
USER_PASSWD="user"                             # コンテナ内ユーザーのパスワードの指定
ROOT_PASSWD="root"                             # コンテナ内rootのパスワード指定
PYTHON_VERSION="3.9.17"                        # pythonのバージョンの指定(別途記載)
MEM="4g"                                       # コンテナとホストPCとの共有メモリ容量
SSH_PORT="22"                                  # 以下各ポート設定(README1)
Jupyter_PORT="8888"
HOST_PORT="23"
CONTAINER_PORT="22"
```
サーバを複数人で共有すると仮定すると, ここのprojectnameでは被らない名前を付けることが重要です (whoamiの参照でデフォルトでも被らないようになっています)  
#出来上がるdocker コンテナとイメージの名前: \${projectname}-\${USERNAME}-\${SERVICENAME}-\${1, 2, ...}

# 3. compose.yml
composeコマンドでのBuild/Runの設定ファイルです. 詳しい説明はしませんが, 軽くポイントだけまとめました. 
* 複数のコンテナを想定したservice名が要求されます. 今回の例では`main`にしています(ymlファイル2行目)
* build で環境変数をDockerfileに渡します
* deploy でGPUを有効にしています
* volume でボリュームのマウントを行っています. Bindマウントとvolumeマウントの違いには注意が必要です
* port でポートの指定をしています. README2をご覧ください. 

# 4. Dockerfile
仮想環境の設計図です. RUNやCOPYなどに続けてシェルスクリプトの記法で書くことができます.   
この設計図は人によって様々ですが, 今回の例を以下に示します. Dockerfileのコメントアウトを参考に辿ってみてください. 
```python
#cuda11.8-cudnn8-ubuntu20.04
イメージの指定(FROM)と環境変数指定(ARG)

#tz
タイムゾーン指定

#aptget install
apt-get でのインストール群 sudo, vim, gitなど基本的なものを入れました

#add sudo user/root
パスワード'root'を持つrootを作成
パスワード'user'を持つホストPCと同名のuserを作成
userにUID, GID, sudoを付与
など

#locales
ロケールと時刻設定(日本語化)

#set src & work dir
共有ディレクトリ'work'とソースコードディレクトリ'src'の設定

#install python_builders
pythonのインストールの為の道具をインストール

#set cdls(cd + ls -a)
個人的に'cd'と'ls -a'は一緒に行いたいので（キモかったら外してください）

#install pyenv
#install python & run
pyenvインストール, 指定したバージョンのpythonをインストール, アクティベート(なので仮想環境入ったらアクティベート無しでそのまま使える)

#install pip library & torch
個人的なpythonライブラリをインストールします
src/requirementsでまとめてインストールしています

'RUN ipython kernel install --user --name=docker --display-name=docker'
'docker'という名前でipythonカーネルを生成しています. これにて直ぐにjupyterが使えます

#ssh
コンテナをsshサーバ化しています
'COPY --chown=${USER}:{USER} id_rsa.pub /home/${USER}/.ssh/authorized_keys'でクライアントPCの公開鍵をコンテナ内に格納しています

# make bash_profile for ssh
ssh接続時にbashrcなどが機能するように組んでます

```
## Build & Run
設定を終えたら仮想環境を構築し, 起動しましょう  
compose_up.shでは, 共有ディレクトリworkの作成, 公開鍵のコピー, make_env.shの実行, compose upコマンドを実行しています
```shell
$ ./compose_up.sh
```

ここまでお疲れ様でした.   
README3はもう少し簡単なので是非とも読んでみてください. 
