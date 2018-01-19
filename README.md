# vendi-do-backup

## Install
```
pushd ~
wget $(curl -s https://api.github.com/repos/vendi-advertising/vendi-do-backup/releases/latest | grep browser_download_url | cut -d '"' -f 4)
sudo mv vendi-do-backup.phar /usr/local/bin/vendi-do-backup
sudo chmod +x /usr/local/bin/vendi-do-backup
popd
```
