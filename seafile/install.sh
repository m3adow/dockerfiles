useradd -d /seafile -M -s /bin/bash -c "Seafile User" seafile
mkdir -p /opt/haiwen /seafile/

: ${USE_PRO=false}
: ${PRO_URL=https://download.seafile.com/d/6e5297246c/?p=/pro}

if [ "$USE_PRO" = true ] ; then
  echo "Installing Professional Edition..."
  pro_user_id=`echo $PRO_URL | ack -o '(?<=\/d\/)[a-z0-9]*(?=\/)'`
  pro_filename=$(curl -sL $PRO_URL \
    | ack -o '(?<=\")seafile-pro-server.*x86-64\.tar\.gz(?=\")'|sort -r|head -1)
  download_path="https://download.seafile.com/d/$pro_user_id/files/?p=/pro/$pro_filename&dl=1"
else
  echo "Installing Community Edition..."
  download_path=$(curl -sL https://www.seafile.com/en/download/ \
    | grep -oE 'https://.*seafile-server.*x86-64.tar.gz'|sort -r|head -1)
fi

echo "Downloading & Extracting $download_path..."
curl -sL $download_path | tar -C /opt/haiwen/ -xz
chown -R seafile:seafile /seafile /opt/haiwen
