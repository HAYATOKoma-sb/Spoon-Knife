{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\"https://colab.research.google.com/github/HAYATOKoma-sb/Spoon-Knife/blob/main/sp\" target=\"_parent\"><img src=\"https://colab.research.google.com/assets/colab-badge.svg\" alt=\"Open In Colab\"/></a>"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "gSpnWBP5ELSI"
      },
      "source": [
        "# 実践演習 Day 1：streamlitとFastAPIのデモ\n",
        "このノートブックでは以下の内容を学習します。\n",
        "\n",
        "- 必要なライブラリのインストールと環境設定\n",
        "- Hugging Faceからモデルを用いたStreamlitのデモアプリ\n",
        "- FastAPIとngrokを使用したAPIの公開方法\n",
        "\n",
        "演習を始める前に、HuggingFaceとngrokのアカウントを作成し、\n",
        "それぞれのAPIトークンを取得する必要があります。\n",
        "\n",
        "\n",
        "演習の時間では、以下の3つのディレクトリを順に説明します。\n",
        "\n",
        "1. 01_streamlit_UI\n",
        "2. 02_streamlit_app\n",
        "3. 03_FastAPI\n",
        "\n",
        "2つ目や3つ目からでも始められる様にノートブックを作成しています。\n",
        "\n",
        "復習の際にもこのノートブックを役立てていただければと思います。\n",
        "\n",
        "### 注意事項\n",
        "「02_streamlit_app」と「03_FastAPI」では、GPUを使用します。\n",
        "\n",
        "これらを実行する際は、Google Colab画面上のメニューから「編集」→ 「ノートブックの設定」\n",
        "\n",
        "「ハードウェアアクセラレーター」の項目の中から、「T4 GPU」を選択してください。\n",
        "\n",
        "このノートブックのデフォルトは「CPU」になっています。\n",
        "\n",
        "---"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "OhtHkJOgELSL"
      },
      "source": [
        "# 環境変数の設定（1~3共有）\n"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "Y-FjBp4MMQHM"
      },
      "source": [
        "GitHubから演習用のコードをCloneします。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 1,
      "metadata": {
        "id": "AIXMavdDEP8U",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "74025487-ecb9-4c17-d7a0-6a70d2bbad19"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Cloning into 'lecture-ai-engineering'...\n",
            "remote: Enumerating objects: 52, done.\u001b[K\n",
            "remote: Total 52 (delta 0), reused 0 (delta 0), pack-reused 52 (from 1)\u001b[K\n",
            "Receiving objects: 100% (52/52), 83.21 KiB | 796.00 KiB/s, done.\n",
            "Resolving deltas: 100% (9/9), done.\n"
          ]
        }
      ],
      "source": [
        "!git clone https://github.com/matsuolab/lecture-ai-engineering.git"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "XC8n7yZ_vs1K"
      },
      "source": [
        "必要なAPIトークンを.envに設定します。\n",
        "\n",
        "「lecture-ai-engineering/day1」の配下に、「.env_template」ファイルが存在しています。\n",
        "\n",
        "隠しファイルのため表示されていない場合は、画面左側のある、目のアイコンの「隠しファイルの表示」ボタンを押してください。\n",
        "\n",
        "「.env_template」のファイル名を「.env」に変更します。「.env」ファイルを開くと、以下のような中身になっています。\n",
        "\n",
        "\n",
        "```\n",
        "HUGGINGFACE_TOKEN=\"hf-********\"\n",
        "NGROK_TOKEN=\"********\"\n",
        "```\n",
        "ダブルクオーテーションで囲まれた文字列をHuggingfaceのアクセストークンと、ngrokの認証トークンで書き変えてください。\n",
        "\n",
        "それぞれのアカウントが作成済みであれば、以下のURLからそれぞれのトークンを取得できます。\n",
        "\n",
        "- Huggingfaceのアクセストークン\n",
        "https://huggingface.co/docs/hub/security-tokens\n",
        "\n",
        "- ngrokの認証トークン\n",
        "https://dashboard.ngrok.com/get-started/your-authtoken\n",
        "\n",
        "書き換えたら、「.env」ファイルをローカルのPCにダウンロードしてください。\n",
        "\n",
        "「01_streamlit_UI」から「02_streamlit_app」へ進む際に、CPUからGPUの利用に切り替えるため、セッションが一度切れてしまいます。\n",
        "\n",
        "その際に、トークンを設定した「.env」ファイルは再作成することになるので、その手間を減らすために「.env」ファイルをダウンロードしておくと良いです。"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "Py1BFS5RqcSS"
      },
      "source": [
        "「.env」ファイルを読み込み、環境変数として設定します。次のセルを実行し、最終的に「True」が表示されていればうまく読み込めています。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 2,
      "metadata": {
        "id": "bvEowFfg5lrq",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "8aae643f-5f99-47f9-d39d-c693de042847"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Collecting python-dotenv\n",
            "  Downloading python_dotenv-1.1.0-py3-none-any.whl.metadata (24 kB)\n",
            "Downloading python_dotenv-1.1.0-py3-none-any.whl (20 kB)\n",
            "Installing collected packages: python-dotenv\n",
            "Successfully installed python-dotenv-1.1.0\n",
            "/content/lecture-ai-engineering/day1\n"
          ]
        },
        {
          "output_type": "execute_result",
          "data": {
            "text/plain": [
              "False"
            ]
          },
          "metadata": {},
          "execution_count": 2
        }
      ],
      "source": [
        "!pip install python-dotenv\n",
        "from dotenv import load_dotenv, find_dotenv\n",
        "\n",
        "%cd /content/lecture-ai-engineering/day1\n",
        "load_dotenv(find_dotenv())"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 3,
      "metadata": {
        "id": "S28XgOm0ELSM",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "bf039b1b-9d8e-42d4-8a6b-f12b3b18bd3f"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "/content/lecture-ai-engineering/day1/01_streamlit_UI\n"
          ]
        }
      ],
      "source": [
        "%cd /content/lecture-ai-engineering/day1/01_streamlit_UI"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "eVp-aEIkELSM"
      },
      "source": [
        "必要なライブラリをインストールします。"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "os0Yk6gaELSM"
      },
      "source": [
        "# 01_streamlit_UI\n",
        "\n",
        "ディレクトリ「01_streamlit_UI」に移動します。"
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "from google.colab import drive\n",
        "drive.mount('/content/drive')"
      ],
      "metadata": {
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "id": "Cao89_0QKZ5j",
        "outputId": "2132bfb9-7a9b-4453-cf9d-d93846246a44"
      },
      "execution_count": 4,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "Mounted at /content/drive\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "source": [
        "%cd /content/lecture-ai-engineering/day1/01_streamlit_UI"
      ],
      "metadata": {
        "id": "YX-DzfkKKmH7",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "0ffe7e4b-2d6f-415e-b371-936b29fab4b4"
      },
      "execution_count": 5,
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "/content/lecture-ai-engineering/day1/01_streamlit_UI\n"
          ]
        }
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 6,
      "metadata": {
        "id": "nBe41LFiELSN"
      },
      "outputs": [],
      "source": [
        "%%capture\n",
        "!pip install -r requirements.txt"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "Yyw6VHaTELSN"
      },
      "source": [
        "ngrokのトークンを使用して、認証を行います。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 7,
      "metadata": {
        "id": "aYw1q0iXELSN",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "2b86aee0-f534-4ed6-c8e0-d28a8938c9dc"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "ERROR:  accepts 1 arg(s), received 0\n"
          ]
        }
      ],
      "source": [
        "!ngrok authtoken $$NGROK_TOKEN"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "RssTcD_IELSN"
      },
      "source": [
        "アプリを起動します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 27,
      "metadata": {
        "id": "f-E7ucR6ELSN",
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 532
        },
        "outputId": "a3d2c107-e82f-49a1-b7af-f861d6373f10"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "ERROR:pyngrok.process.ngrok:t=2025-05-02T09:47:26+0000 lvl=eror msg=\"failed to reconnect session\" obj=tunnels.session err=\"authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n\"\n",
            "ERROR:pyngrok.process.ngrok:t=2025-05-02T09:47:26+0000 lvl=eror msg=\"session closing\" obj=tunnels.session err=\"authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n\"\n",
            "ERROR:pyngrok.process.ngrok:t=2025-05-02T09:47:26+0000 lvl=eror msg=\"terminating with error\" obj=app err=\"authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n\"\n",
            "CRITICAL:pyngrok.process.ngrok:t=2025-05-02T09:47:26+0000 lvl=crit msg=\"command failed\" err=\"authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n\"\n"
          ]
        },
        {
          "output_type": "error",
          "ename": "PyngrokNgrokError",
          "evalue": "The ngrok process errored on start: authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n.",
          "traceback": [
            "\u001b[0;31m---------------------------------------------------------------------------\u001b[0m",
            "\u001b[0;31mPyngrokNgrokError\u001b[0m                         Traceback (most recent call last)",
            "\u001b[0;32m<ipython-input-27-9e3cd01e641d>\u001b[0m in \u001b[0;36m<cell line: 0>\u001b[0;34m()\u001b[0m\n\u001b[1;32m      1\u001b[0m \u001b[0;32mfrom\u001b[0m \u001b[0mpyngrok\u001b[0m \u001b[0;32mimport\u001b[0m \u001b[0mngrok\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m      2\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m----> 3\u001b[0;31m \u001b[0mpublic_url\u001b[0m \u001b[0;34m=\u001b[0m \u001b[0mngrok\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mconnect\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;36m8501\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mpublic_url\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m      4\u001b[0m \u001b[0mprint\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"公開URL: {public_url}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m      5\u001b[0m \u001b[0mget_ipython\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0msystem\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34m'streamlit run app.py'\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/ngrok.py\u001b[0m in \u001b[0;36mconnect\u001b[0;34m(addr, proto, name, pyngrok_config, **options)\u001b[0m\n\u001b[1;32m    348\u001b[0m     \u001b[0mlogger\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0minfo\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"Opening tunnel named: {name}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    349\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 350\u001b[0;31m     \u001b[0mapi_url\u001b[0m \u001b[0;34m=\u001b[0m \u001b[0mget_ngrok_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mapi_url\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    351\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    352\u001b[0m     \u001b[0mlogger\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mdebug\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"Creating tunnel with options: {options}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/ngrok.py\u001b[0m in \u001b[0;36mget_ngrok_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    170\u001b[0m     \u001b[0minstall_ngrok\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    171\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 172\u001b[0;31m     \u001b[0;32mreturn\u001b[0m \u001b[0mprocess\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mget_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    173\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    174\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/process.py\u001b[0m in \u001b[0;36mget_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    263\u001b[0m         \u001b[0;32mreturn\u001b[0m \u001b[0m_current_processes\u001b[0m\u001b[0;34m[\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mngrok_path\u001b[0m\u001b[0;34m]\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    264\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 265\u001b[0;31m     \u001b[0;32mreturn\u001b[0m \u001b[0m_start_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    266\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    267\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/process.py\u001b[0m in \u001b[0;36m_start_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    426\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    427\u001b[0m         \u001b[0;32mif\u001b[0m \u001b[0mngrok_process\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mstartup_error\u001b[0m \u001b[0;32mis\u001b[0m \u001b[0;32mnot\u001b[0m \u001b[0;32mNone\u001b[0m\u001b[0;34m:\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 428\u001b[0;31m             raise PyngrokNgrokError(f\"The ngrok process errored on start: {ngrok_process.startup_error}.\",\n\u001b[0m\u001b[1;32m    429\u001b[0m                                     \u001b[0mngrok_process\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mlogs\u001b[0m\u001b[0;34m,\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    430\u001b[0m                                     ngrok_process.startup_error)\n",
            "\u001b[0;31mPyngrokNgrokError\u001b[0m: The ngrok process errored on start: authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n."
          ]
        }
      ],
      "source": [
        "from pyngrok import ngrok\n",
        "\n",
        "public_url = ngrok.connect(8501).public_url\n",
        "print(f\"公開URL: {public_url}\")\n",
        "!streamlit run app.py"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "kbYyXVFjELSN"
      },
      "source": [
        "公開URLの後に記載されているURLにブラウザでアクセスすると、streamlitのUIが表示されます。\n",
        "\n",
        "app.pyのコメントアウトされている箇所を編集することで、UIがどの様に変化するか確認してみましょう。\n",
        "\n",
        "streamlitの公式ページには、ギャラリーページがあります。\n",
        "\n",
        "streamlitを使うとpythonという一つの言語であっても、様々なUIを実現できることがわかると思います。\n",
        "\n",
        "https://streamlit.io/gallery"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "MmtP5GLOELSN"
      },
      "source": [
        "後片付けとして、使う必要のないngrokのトンネルを削除します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 12,
      "metadata": {
        "id": "8Ek9QgahELSO"
      },
      "outputs": [],
      "source": [
        "from pyngrok import ngrok\n",
        "ngrok.kill()"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "o-T8tFpyELSO"
      },
      "source": [
        "# 02_streamlit_app"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "QqogFQKnELSO"
      },
      "source": [
        "\n",
        "ディレクトリ「02_streamlit_app」に移動します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 13,
      "metadata": {
        "id": "UeEjlJ7uELSO",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "e0adf1c8-a009-471a-b1e8-412fa8b625df"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "/content/lecture-ai-engineering/day1/02_streamlit_app\n"
          ]
        }
      ],
      "source": [
        "%cd /content/lecture-ai-engineering/day1/02_streamlit_app"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "-XUH2AstELSO"
      },
      "source": [
        "必要なライブラリをインストールします。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 14,
      "metadata": {
        "id": "mDqvI4V3ELSO"
      },
      "outputs": [],
      "source": [
        "%%capture\n",
        "!pip install -r requirements.txt"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "ZO31umGZELSO"
      },
      "source": [
        "ngrokとhuggigfaceのトークンを使用して、認証を行います。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 15,
      "metadata": {
        "id": "jPxTiEWQELSO",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "b767b45c-8670-4922-ad72-3063e9068c76"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "ERROR:  accepts 1 arg(s), received 0\n",
            "usage: huggingface-cli <command> [<args>] login [-h] [--token TOKEN]\n",
            "                                                [--add-to-git-credential]\n",
            "huggingface-cli <command> [<args>] login: error: argument --token: expected one argument\n"
          ]
        }
      ],
      "source": [
        "!ngrok authtoken $$NGROK_TOKEN\n",
        "!huggingface-cli login --token $$HUGGINGFACE_TOKEN"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "dz4WrELLELSP"
      },
      "source": [
        "stramlitでHuggingfaceのトークン情報を扱うために、streamlit用の設定ファイル（.streamlit）を作成し、トークンの情報を格納します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 16,
      "metadata": {
        "id": "W184-a7qFP0W"
      },
      "outputs": [],
      "source": [
        "# .streamlit/secrets.toml ファイルを作成\n",
        "import os\n",
        "import toml\n",
        "\n",
        "# 設定ファイルのディレクトリ確保\n",
        "os.makedirs('.streamlit', exist_ok=True)\n",
        "\n",
        "# 環境変数から取得したトークンを設定ファイルに書き込む\n",
        "secrets = {\n",
        "    \"huggingface\": {\n",
        "        \"token\": os.environ.get(\"HUGGINGFACE_TOKEN\", \"\")\n",
        "    }\n",
        "}\n",
        "\n",
        "# 設定ファイルを書き込む\n",
        "with open('.streamlit/secrets.toml', 'w') as f:\n",
        "    toml.dump(secrets, f)"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "fK0vI_xKELSP"
      },
      "source": [
        "アプリを起動します。\n",
        "\n",
        "02_streamlit_appでは、Huggingfaceからモデルをダウンロードするため、初回起動には2分程度時間がかかります。\n",
        "\n",
        "この待ち時間を利用して、app.pyのコードを確認してみましょう。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 24,
      "metadata": {
        "id": "TBQyTTWTELSP",
        "colab": {
          "base_uri": "https://localhost:8080/",
          "height": 480
        },
        "outputId": "50d8d7e5-c95c-42cc-e327-fbf80b69f478"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stderr",
          "text": [
            "ERROR:pyngrok.process.ngrok:t=2025-05-02T09:47:18+0000 lvl=eror msg=\"failed to reconnect session\" obj=tunnels.session err=\"authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n\"\n"
          ]
        },
        {
          "output_type": "error",
          "ename": "PyngrokNgrokError",
          "evalue": "The ngrok process errored on start: authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n.",
          "traceback": [
            "\u001b[0;31m---------------------------------------------------------------------------\u001b[0m",
            "\u001b[0;31mPyngrokNgrokError\u001b[0m                         Traceback (most recent call last)",
            "\u001b[0;32m<ipython-input-24-9e3cd01e641d>\u001b[0m in \u001b[0;36m<cell line: 0>\u001b[0;34m()\u001b[0m\n\u001b[1;32m      1\u001b[0m \u001b[0;32mfrom\u001b[0m \u001b[0mpyngrok\u001b[0m \u001b[0;32mimport\u001b[0m \u001b[0mngrok\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m      2\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m----> 3\u001b[0;31m \u001b[0mpublic_url\u001b[0m \u001b[0;34m=\u001b[0m \u001b[0mngrok\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mconnect\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;36m8501\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mpublic_url\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m      4\u001b[0m \u001b[0mprint\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"公開URL: {public_url}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m      5\u001b[0m \u001b[0mget_ipython\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0msystem\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34m'streamlit run app.py'\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/ngrok.py\u001b[0m in \u001b[0;36mconnect\u001b[0;34m(addr, proto, name, pyngrok_config, **options)\u001b[0m\n\u001b[1;32m    348\u001b[0m     \u001b[0mlogger\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0minfo\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"Opening tunnel named: {name}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    349\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 350\u001b[0;31m     \u001b[0mapi_url\u001b[0m \u001b[0;34m=\u001b[0m \u001b[0mget_ngrok_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mapi_url\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    351\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    352\u001b[0m     \u001b[0mlogger\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mdebug\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0;34mf\"Creating tunnel with options: {options}\"\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/ngrok.py\u001b[0m in \u001b[0;36mget_ngrok_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    170\u001b[0m     \u001b[0minstall_ngrok\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    171\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 172\u001b[0;31m     \u001b[0;32mreturn\u001b[0m \u001b[0mprocess\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mget_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    173\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    174\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/process.py\u001b[0m in \u001b[0;36mget_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    263\u001b[0m         \u001b[0;32mreturn\u001b[0m \u001b[0m_current_processes\u001b[0m\u001b[0;34m[\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mngrok_path\u001b[0m\u001b[0;34m]\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    264\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 265\u001b[0;31m     \u001b[0;32mreturn\u001b[0m \u001b[0m_start_process\u001b[0m\u001b[0;34m(\u001b[0m\u001b[0mpyngrok_config\u001b[0m\u001b[0;34m)\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0m\u001b[1;32m    266\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    267\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n",
            "\u001b[0;32m/usr/local/lib/python3.11/dist-packages/pyngrok/process.py\u001b[0m in \u001b[0;36m_start_process\u001b[0;34m(pyngrok_config)\u001b[0m\n\u001b[1;32m    426\u001b[0m \u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    427\u001b[0m         \u001b[0;32mif\u001b[0m \u001b[0mngrok_process\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mstartup_error\u001b[0m \u001b[0;32mis\u001b[0m \u001b[0;32mnot\u001b[0m \u001b[0;32mNone\u001b[0m\u001b[0;34m:\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[0;32m--> 428\u001b[0;31m             raise PyngrokNgrokError(f\"The ngrok process errored on start: {ngrok_process.startup_error}.\",\n\u001b[0m\u001b[1;32m    429\u001b[0m                                     \u001b[0mngrok_process\u001b[0m\u001b[0;34m.\u001b[0m\u001b[0mlogs\u001b[0m\u001b[0;34m,\u001b[0m\u001b[0;34m\u001b[0m\u001b[0;34m\u001b[0m\u001b[0m\n\u001b[1;32m    430\u001b[0m                                     ngrok_process.startup_error)\n",
            "\u001b[0;31mPyngrokNgrokError\u001b[0m: The ngrok process errored on start: authentication failed: Usage of ngrok requires a verified account and authtoken.\\n\\nSign up for an account: https://dashboard.ngrok.com/signup\\nInstall your authtoken: https://dashboard.ngrok.com/get-started/your-authtoken\\r\\n\\r\\nERR_NGROK_4018\\r\\n."
          ]
        }
      ],
      "source": [
        "from pyngrok import ngrok\n",
        "\n",
        "public_url = ngrok.connect(8501).public_url\n",
        "print(f\"公開URL: {public_url}\")\n",
        "!streamlit run app.py"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "H0E7rw2lGQBS"
      },
      "source": [
        "アプリケーションの機能としては、チャット機能や履歴閲覧があります。\n",
        "\n",
        "これらの機能を実現するためには、StreamlitによるUI部分だけではなく、SQLiteを使用したチャット履歴の保存やLLMのモデルを呼び出した推論などの処理を組み合わせることで実現しています。\n",
        "\n",
        "- **`app.py`**: アプリケーションのエントリーポイント。チャット機能、履歴閲覧、サンプルデータ管理のUIを提供します。\n",
        "- **`ui.py`**: チャットページや履歴閲覧ページなど、アプリケーションのUIロジックを管理します。\n",
        "- **`llm.py`**: LLMモデルのロードとテキスト生成を行うモジュール。\n",
        "- **`database.py`**: SQLiteデータベースを使用してチャット履歴やフィードバックを保存・管理します。\n",
        "- **`metrics.py`**: BLEUスコアやコサイン類似度など、回答の評価指標を計算するモジュール。\n",
        "- **`data.py`**: サンプルデータの作成やデータベースの初期化を行うモジュール。\n",
        "- **`config.py`**: アプリケーションの設定（モデル名やデータベースファイル名）を管理します。\n",
        "- **`requirements.txt`**: このアプリケーションを実行するために必要なPythonパッケージ。"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "Xvm8sWFPELSP"
      },
      "source": [
        "後片付けとして、使う必要のないngrokのトンネルを削除します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 18,
      "metadata": {
        "id": "WFJC2TmZELSP"
      },
      "outputs": [],
      "source": [
        "from pyngrok import ngrok\n",
        "ngrok.kill()"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "rUXhIzV7ELSP"
      },
      "source": [
        "# 03_FastAPI\n",
        "\n",
        "ディレクトリ「03_FastAPI」に移動します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 19,
      "metadata": {
        "id": "4ejjDLxr3kfC",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "240cfbdc-67ac-48aa-beac-38a9f003a8b1"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "/content/lecture-ai-engineering/day1/03_FastAPI\n"
          ]
        }
      ],
      "source": [
        "%cd /content/lecture-ai-engineering/day1/03_FastAPI"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "f45TDsNzELSQ"
      },
      "source": [
        "必要なライブラリをインストールします。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 20,
      "metadata": {
        "id": "9uv6glCz5a7Z"
      },
      "outputs": [],
      "source": [
        "%%capture\n",
        "!pip install -r requirements.txt"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "JfrmE2VmELSQ"
      },
      "source": [
        "ngrokとhuggigfaceのトークンを使用して、認証を行います。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 21,
      "metadata": {
        "id": "ELzWhMFORRIO",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "5557e9de-f8f2-4b8c-c08b-c79581c8fa53"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "ERROR:  accepts 1 arg(s), received 0\n",
            "usage: huggingface-cli <command> [<args>] login [-h] [--token TOKEN]\n",
            "                                                [--add-to-git-credential]\n",
            "huggingface-cli <command> [<args>] login: error: argument --token: expected one argument\n"
          ]
        }
      ],
      "source": [
        "!ngrok authtoken $$NGROK_TOKEN\n",
        "!huggingface-cli login --token $$HUGGINGFACE_TOKEN"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "t-wztc2CELSQ"
      },
      "source": [
        "アプリを起動します。\n",
        "\n",
        "「02_streamlit_app」から続けて「03_FastAPI」を実行している場合は、モデルのダウンロードが済んでいるため、すぐにサービスが立ち上がります。\n",
        "\n",
        "「03_FastAPI」のみを実行している場合は、初回の起動時にモデルのダウンロードが始まるので、モデルのダウンロードが終わるまで数分間待ちましょう。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 22,
      "metadata": {
        "id": "meQ4SwISn3IQ",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "cc111caf-7d26-43fe-a08c-cd3fbcf06ed7"
      },
      "outputs": [
        {
          "output_type": "stream",
          "name": "stdout",
          "text": [
            "2025-05-02 09:45:37.827564: E external/local_xla/xla/stream_executor/cuda/cuda_fft.cc:477] Unable to register cuFFT factory: Attempting to register factory for plugin cuFFT when one has already been registered\n",
            "WARNING: All log messages before absl::InitializeLog() is called are written to STDERR\n",
            "E0000 00:00:1746179138.094800    4546 cuda_dnn.cc:8310] Unable to register cuDNN factory: Attempting to register factory for plugin cuDNN when one has already been registered\n",
            "E0000 00:00:1746179138.170380    4546 cuda_blas.cc:1418] Unable to register cuBLAS factory: Attempting to register factory for plugin cuBLAS when one has already been registered\n",
            "2025-05-02 09:45:38.736345: I tensorflow/core/platform/cpu_feature_guard.cc:210] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.\n",
            "To enable the following instructions: AVX2 FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.\n",
            "モデル名を設定: google/gemma-2-2b-jpn-it\n",
            "/content/lecture-ai-engineering/day1/03_FastAPI/app.py:134: DeprecationWarning: \n",
            "        on_event is deprecated, use lifespan event handlers instead.\n",
            "\n",
            "        Read more about it in the\n",
            "        [FastAPI docs for Lifespan Events](https://fastapi.tiangolo.com/advanced/events/).\n",
            "        \n",
            "  @app.on_event(\"startup\")\n",
            "FastAPIエンドポイントを定義しました。\n",
            "Ngrok認証トークンが'NGROK_TOKEN'環境変数に設定されていません。\n",
            "Colab Secrets(左側の鍵アイコン)で'NGROK_TOKEN'を設定することをお勧めします。\n",
            "Ngrok認証トークンを入力してください (https://dashboard.ngrok.com/get-started/your-authtoken): object address  : 0x790699baf940\n",
            "object refcount : 2\n",
            "object type     : 0x9d5ea0\n",
            "object type name: KeyboardInterrupt\n",
            "object repr     : KeyboardInterrupt()\n",
            "lost sys.stderr\n"
          ]
        }
      ],
      "source": [
        "!python app.py"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "RLubjIhbELSR"
      },
      "source": [
        "FastAPIが起動すると、APIとクライアントが通信するためのURL（エンドポイント）が作られます。\n",
        "\n",
        "URLが作られるのと合わせて、Swagger UIというWebインターフェースが作られます。\n",
        "\n",
        "Swagger UIにアクセスすることで、APIの仕様を確認できたり、APIをテストすることができます。\n",
        "\n",
        "Swagger UIを利用することで、APIを通してLLMを動かしてみましょう。"
      ]
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "XgumW3mGELSR"
      },
      "source": [
        "後片付けとして、使う必要のないngrokのトンネルを削除します。"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": 23,
      "metadata": {
        "id": "RJymTZio-WPJ"
      },
      "outputs": [],
      "source": [
        "from pyngrok import ngrok\n",
        "ngrok.kill()"
      ]
    }
  ],
  "metadata": {
    "colab": {
      "provenance": [],
      "gpuType": "T4",
      "include_colab_link": true
    },
    "kernelspec": {
      "display_name": "Python 3",
      "name": "python3"
    },
    "language_info": {
      "name": "python"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 0
}