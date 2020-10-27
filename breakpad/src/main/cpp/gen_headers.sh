#!/bin/bash

if [[ ! -d include ]]; then
  mkdir include
fi

INCLUDE_PATH="$(pwd)/include"
rm -rf include/*

function walk_path() {
  DIR=${1}
  TARGET_DIR=${DIR:13}
  mkdir "${INCLUDE_PATH}/${TARGET_DIR}"

  for f in "${DIR}"/*.h; do
    if [[ -f ${f} ]]; then
      cp -v "${f}" "${INCLUDE_PATH}/${TARGET_DIR}/"
    fi
  done

  for f in "${DIR}"/*; do
    if [[ -d ${f} ]]; then
      walk_path "${f}"
      continue
    fi
  done
}

walk_path breakpad/src

mv -v include/common/android/include/* include/
