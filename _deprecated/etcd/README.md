This is a adoption of elcolio/etcd. As I wanted to have an image with fresh releases of etcd, I adjusted the way etcd is downloaded. Also I updated the base image to alpine:latest as I prefer fresh OS as well. Everything else is identical.

---
---

##Itty bitty Etcd container

***NOTE: The tags have recently been updated!  Use elcolio/etcd:2.0.X for a specific version.  The current latest is 2.0.10***

This image weighs in at 20.17 MB due to the inclusion of TLS support and etcdctl.  The `-data-dir` is a volume mounted to `/data`, and the default ports are bound to Etcd and exposed.

Recently added a run script so that http is not hard-coded into the Dockerfile (for running over SSL).  Just overwrite `$CLIENT_URLS` and `$PEER_URLS` at runtime (these are the **listening** URLs).  You'll still need to set the `-advertise-client-urls` and `-initial-advertise-peer-urls` flags if the container will be part of a cluster.

Since the image uses an `ENTRYPOINT` it accepts passthrough arguments to etcd.

```sh
docker run \
  -d \
  -p 2379:2379 \
  -p 2380:2380 \
  -p 4001:4001 \
  -p 7001:7001 \
  -v /data/backup/dir:/data \
  --name some-etcd \
  elcolio/etcd:latest \
  -name some-etcd \
  -discovery=https://discovery.etcd.io/blahblahblahblah \
  -advertise-client-urls http://192.168.1.99:4001 \
  -initial-advertise-peer-urls http://192.168.1.99:7001
```
