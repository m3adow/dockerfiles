FROM etherpad/etherpad:latest

# Change home directory so npm can create its cache dir
# (until https://github.com/ether/etherpad-lite/pull/3674 has been merged)
ENV HOME=/opt/etherpad-lite
RUN npm install sqlite3 ep_hash_auth
