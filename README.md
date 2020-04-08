# Git-Crypt Docker Image

Run `git-crypt` inside docker.

This runs git-crypt in GnuPG mode inside a docker container.

Usage:

Create a wrapper that runs the image as follows:

```
docker run --rm --interactive \
  --env HOME=$HOME \
  --env GIT_CRYPT_PATH=$REPODIR/build/tools/git-crypt \
  --user $(id -u):$(id -g) \
  --workdir $REPODIR \
  --volume /tmp:/tmp:ro \
  --volume $HOME/.gitconfig:$HOME/.gitconfig:ro \
  --volume $HOME/.gnupg:$HOME/.gnupg \
  --volume $REPODIR:$REPODIR
  --tmpfs /run/usr/$(id -u):mode=0700,uid=$(id -u),gid=$(id -g)
  courtapi/git-crypt:latest $@
```
