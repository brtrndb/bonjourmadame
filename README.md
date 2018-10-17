# bonjourmadame.sh

Download your lovely daily Madame from [BonjourMadame](http://dites.bonjourmadame.fr/).

## Installation

First, clone the repository.

```sh
$ git clone https://github.com/brtrndb/bonjourmadame.git
```

## Usage

```sh
$ ./bonjourmadame.sh -h
Usage: bonjourmadame.sh { -c | -t | -a | -h } [ -d date ] [ -f folder ]
-c, --cron:   Add a crontab entry every weekdays at 10:30AM.
-t, --today:  Donwload today's Madame.
-a, --all:    Donwload all Madames.
-d, --date:   Download Madame for a specific date. Note: lowest date is 2015-11-30.
-f, --folder: Target folder for pics.
-h, --help:   Display usage.
```

### Parameters

- `folder`: Folder to save pictures. Default folder is `$HOME/Images/BM`.
- `date`: Specify date. Date format should be like `YYYY-MM-DD`.

## Description

## Notes

The script requires the `recode` package to format HTML accentued characters into UTF8. Install it with `sudo apt-get install recode`.

## License

See [LICENSE.md](./LICENSE.md)
