#!/usr/local/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
readarray EXISTING_CLIENTS -t a < existing_clients.txt
echo "Who is this project for?"
for ((idx=0; idx<${#EXISTING_CLIENTS[@]}; ++idx)); do
    echo "($idx)" "${EXISTING_CLIENTS[idx]}"
done
read ANS
CLIENT_NAME=${EXISTING_CLIENTS[$ANS]}
CLIENT_NAME=${CLIENT_NAME::-1}
GLOSS_PATH="/Users/samuel/LibraryDrive/reference/Resources/work/pastTranslations/glossaries/${CLIENT_NAME}/glossary.txt"
TM_DIR_PATH="/Users/samuel/LibraryDrive/reference/Resources/work/pastTranslations/tm/${CLIENT_NAME}"
echo $CLIENT_NAME $GLOSS_PATH $TM_DIR_PATH
cp $GLOSS_PATH project/glossary/
for TM in `ls $TM_DIR_PATH`; do
  if [ ${TM: -10} == "omegat.tmx" ]; then
    echo "${TM_DIR_PATH}/${TM}"
    cp "${TM_DIR_PATH}/${TM}" project/tm
  fi
done
cp -r ./project "/Users/samuel/In/$(date +%F)-${CLIENT_NAME}"
