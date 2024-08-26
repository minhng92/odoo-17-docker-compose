#!/bin/bash
DESTINATION=$1
PORT=$2
CHAT=$3

# clone Odoo directory
git clone --depth=1 https://github.com/minhng92/odoo-17-docker-compose $DESTINATION
rm -rf $DESTINATION/.git

# set permission
mkdir -p $DESTINATION/postgresql
sudo chmod -R 777 $DESTINATION

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Running on macOS. Skipping inotify configuration."
else
  # config for Linux
  if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then
    echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf)
  else
    echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf
  fi
  sudo sysctl -p
fi


# Update docker-compose configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS sed syntax
  sed -i '' 's/10017/'$PORT'/g' $DESTINATION/docker-compose.yml
  sed -i '' 's/20017/'$CHAT'/g' $DESTINATION/docker-compose.yml
else
  # Linux sed syntax
  sed -i 's/10017/'$PORT'/g' $DESTINATION/docker-compose.yml
  sed -i 's/20017/'$CHAT'/g' $DESTINATION/docker-compose.yml
fi

# run Odoo
docker compose -f $DESTINATION/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Master Password: minhng.info | Live chat port: '$CHAT
