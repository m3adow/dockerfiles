### Build container for Restic

This is a build container for restic (https://github.com/restic/restic), the fast, secure, efficient backup program.
It will compile the newest restic version on every run and output it on STDOUT. Therefore the intended way of running
it is like this:

```bash
docker run --rm m3adow/restic-builder > ~/bin/restic && docker rmi m3adow/restic-builder \
  && chmod +x ~/bin/restic
```

This is very useful to keep restic up to date on systems without official packages without need to permanently install
the golang build environment.
