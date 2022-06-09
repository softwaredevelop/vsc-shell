#!/usr/bin/env bash
# -*- coding: utf-8 -*-

export DEBIAN_FRONTEND=noninteractive

export LISTS_UPDATED=1
if [[ -d "/var/lib/apt/lists" && $(ls /var/lib/apt/lists/ | wc -l) -eq 0 ]]; then
  if apt-get update; then
    LISTS_UPDATED=0
  fi
fi

if (("$LISTS_UPDATED" == 0)); then
  package_list="wget \
        ca-certificates \
        gawk \
        make \
        build-essential"

  apt-get install --no-install-recommends --assume-yes --reinstall $package_list
fi

BASHDB_VERSION=${1:-5.0-1.1.2}
BASHDB=bashdb-"$BASHDB_VERSION".tar.bz2
if [ ! -e "$BASHDB" ]; then
  wget https://sourceforge.net/projects/bashdb/files/bashdb/"$BASHDB_VERSION"/"$BASHDB"

  if [ ! -d "/usr/src/bashdb" ]; then
    mkdir /usr/src/bashdb
    tar -xjf "$BASHDB" --directory=/usr/src/bashdb --strip-components=1
  fi

  rm -f "$BASHDB"
  if [[ -d "/usr/src/bashdb" && "$(ls /usr/src/bashdb/ | wc -l)" != "0" ]]; then
    cd /usr/src/bashdb/ || exit
    ./configure --with-dbg-main
    make --jobs="$(nproc)" all > /dev/null 2>&1
    make --jobs="$(nproc)" check > /dev/null 2>&1
    make install > /dev/null 2>&1
  fi
fi

if (("$LISTS_UPDATED" == 0)); then
  apt-get clean
  rm -fr /var/lib/apt/lists/*
fi
