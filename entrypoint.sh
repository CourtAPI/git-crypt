#!/bin/sh

command=$1

set -e

# run gpg-agent daemon and force TTY pinentry
gpg-agent --daemon --pinentry-program /usr/bin/pinentry

git_dir=$(git rev-parse --git-dir)

finish() {
  # restore git-crypt paths to docker tool version inside the repo,
  # (if git-crypt is still active)
  if [ -f "$git_dir/git-crypt/keys/default" ]; then
    if [ ! -z "$GIT_CRYPT_PATH" ]; then
      git config filter.git-crypt.smudge "\"$GIT_CRYPT_PATH\" smudge"
      git config filter.git-crypt.clean  "\"$GIT_CRYPT_PATH\" clean"
      git config diff.git-crypt.textconv "\"$GIT_CRYPT_PATH\" diff"
    fi
  fi
}

trap finish EXIT

# set git-crypt paths to the paths in the container so that git-crypt can call
# other tools if needed.
if [ -f "$git_dir/git-crypt/keys/default" ]; then
  git config filter.git-crypt.smudge "\"/usr/local/bin/git-crypt\" smudge"
  git config filter.git-crypt.clean  "\"/usr/local/bin/git-crypt\" clean"
  git config diff.git-crypt.textconv "\"/usr/local/bin/git-crypt\" diff"
fi

/usr/local/bin/git-crypt $@ < /dev/stdin
