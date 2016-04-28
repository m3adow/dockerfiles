This is a simple nginx webserver container which by defaults shows its hostname on the `index.html` (index.html is a symlink to /etc/hostname). I needed it to quickly deploy some distinguishable web server containers for some load balancing tests. 

Just run `docker run -d --rm m3adow/webtest`.

If you want, you can adjust the hostname: `docker run -d --rm -h webnode1 m3adow/webtest`
