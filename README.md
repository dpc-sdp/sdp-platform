# sdp-platform

Manage platform dependencies for SDP projects

## Usage

Add the following to your `composer.json`
```
        "dpc-sdp/sdp-platform": {
            "type": "vcs",
            "no-api": true,
            "url": "https://github.com/dpc-sdp/sdp-platform.git"
        }
```

Require the plugin 
```
composer require dpc-sdp/sdp-platform
```

On install, required files will be copied and updated as required.

## Development

Add files under the `/assets` directory, recreating the path as required. e.g.
to install the file `/scripts/drupal/backup.sh` in the final project, make sure
this file exists at `/assets/scripts/drupal/backup.sh`

Within that file, replacements can be set up. An example from `backup.sh` is the 
replacement `%%PROJECT_NAME%%`.

The array `$directoriesToCopy` has as a directory, including the full relative
path as a top level key. The next level array will have one entry per file and
it can have an optional array of replacements. The example below takes the file
`backup.sh ` and replaces `%%PROJECT_NAME%%` with the value from the environment
variable `PROJECT_NAME`. If this variable does not exist then no replacement will
occur.

```
    $directoriesToCopy = [
      'scripts/drupal' => [
        'backup.sh' => ['%%PROJECT_NAME%%' => 'PROJECT_NAME'],
      ],
    ];
```

### Running from the host machine

The composer plugin will correctly have environment variables set via the `.env`
file that is saved in the repository. As a development task, if the environment is
setup then it can also be run from the host. From `ahoy.yml` a shortcut for
setting up all environment variables would be to run the following from the 
consumer project directory.

```
export $(grep -v '^#' .env | xargs)
```

You can then run `composer update` as usual. Another method is to run the composer
script directly with the snippet below. Be aware that this will run all the post 
install commands.

```
composer run-script post-install-cmd
```
