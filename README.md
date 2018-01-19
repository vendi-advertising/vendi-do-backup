# vendi-do-backup

## Install

This installs the most recent version to `/usr/local/bin`.

```
pushd ~
wget $(curl -s https://api.github.com/repos/vendi-advertising/vendi-do-backup/releases/latest | grep browser_download_url | cut -d '"' -f 4)
sudo mv vendi-do-backup.phar /usr/local/bin/vendi-do-backup
sudo chmod +x /usr/local/bin/vendi-do-backup
popd
```

You need to get your [keys from DigitalOcean](https://cloud.digitalocean.com/settings/api/tokens) and also create a space (which is used as the bucket parameter).

## To Run

```
vendi-do-backup backup \
    --private-key=YOUR_SECRET_HERE \
    --public-key=YOUR_KEY_HERE \
    --file=/path/to/file \
    --bucket=previously-created-bucket-here \
    --region=nyc3 \
    --name=new-file-name
```

### Parameters

#### `--private-key`
**Required**. Your key's secret, only shown once during key creation [at DigitalOcean](https://cloud.digitalocean.com/settings/api/tokens) in the _Spaces access keys_ section. If you don't have this either regenerate the existing key (assuming you aren't using it anywhere) or just generate a new key.

#### `--public-key`
**Required**. The public portion of your key. See `--private-key`.

#### `--file`
**Required**. The path to the file to backup.

#### `--bucket`
**Required**. The name of your [_Space_ in DigitalOcean](https://cloud.digitalocean.com/spaces). This must be created before running the script, it won't do it for you.

#### `--name`
**Required**. The name of the file as it should appear in the space. We currently don't do anything smart about trying to figure out the "name portion" of `--file` parameter. You should be able to supply forward slashes here to create sub folders however this has not been tested.

#### `--region`
**Optional**. The region shortname for your _Space_. Currently DigitalOcean only supports _Spaces_ in `nyc3` and `ams3`.
