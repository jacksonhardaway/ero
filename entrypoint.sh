#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FILE" ]
then
  echo "Missing source file"
  return 1
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch main "https://x-access-token:$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Deleting files"
rm -rf $CLONE_DIR/*

DEST_COPY="$CLONE_DIR/$INPUT_DESTINATION_FOLDER"

echo "Copying contents to git repo"
mkdir -p "$DEST_COPY"

cp -R "$INPUT_SOURCE_FILE" "$DEST_COPY"

cd "$CLONE_DIR"

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing git commit"
  git push -u origin HEAD:main
else
  echo "No changes detected"
fi

COMMIT_HASH=$(git show -s --format=%H)
echo "::set-output name=commit_hash::$COMMIT_HASH"
