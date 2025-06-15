#!/bin/bash

if ! command -v brew &> /dev/null; then
  echo "Homebrew 未安装，正在安装 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew 已安装，跳过安装步骤"
fi

if ! command -v python3 &> /dev/null; then
  echo "Python3 未安装，正在安装 Python3..."
  brew install python
else
  echo "Python3 已安装，版本：$(python3 --version)"
fi

if ! command -v pip3 &> /dev/null; then
  echo "pip3 未安装，尝试安装 pip3..."
  python3 -m ensurepip --upgrade
else
  echo "pip3 已安装，版本：$(pip3 --version)"
fi

echo "开始安装所需的Python第三方库..."
pip3 install --upgrade requests urllib3 pycryptodome tqdm

if ! command -v wine &> /dev/null; then
  echo "wine 未安装，正在安装 wine-stable..."
  brew install --cask wine-stable
else
  echo "wine 已安装，版本：$(wine --version)"
fi