#! /usr/bin/env bash

set -e

if [[ $OSTYPE != darwin* ]]; then
  SUDO=sudo
fi

if [[ -d taiga-back ]]; then
    rm -rf taiga-back
fi

if [[ -d  taiga-front-dist ]]; then
  rm -rf taiga-front-dist
fi

git clone -b stable --single-branch https://github.com/taigaio/taiga-back.git
git clone -b stable --single-branch https://github.com/taigaio/taiga-front-dist

if [[ $OSTYPE != darwin* ]]; then
    sed -i 's/^enum34/#enum34/' taiga-back/requirements.txt
    sed -i -e '/sample_data/s/^/#/' taiga-back/regenerate.sh
else
    sed -i '.bak' 's/^enum34/#enum34/' taiga-back/requirements.txt
    sed -i '.bak' '/sample_data/s/^/#/' taiga-back/regenerate.sh
fi

cp taiga-back/requirements.txt .

$SUDO docker build -t queeno/taiga .

rm requirements.txt

if [[ -d  taiga-back ]]; then
  rm -rf taiga-back
fi

if [[ -d  taiga-front-dist ]]; then
  rm -rf taiga-front-dist
fi
