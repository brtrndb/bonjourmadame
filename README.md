# bonjourmadame.sh

Download your lovely daily Madame from [BonjourMadame](http://dites.bonjourmadame.fr/).

## Installation

First, clone the repository.

```sh
$ git clone https://github.com/brtrndb/bonjourmadame.git
```

## Requirements

The script requires the `recode` package to format HTML accentued characters into UTF8.

```sh
$ sudo apt-get install recode
```

## Usage

```sh
$ ./bonjourmadame.sh -h
Usage: bonjourmadame.sh { -a | -t | -c | -h } [ -d date ] [ -f folder ]
-a, --all:      Donwload all Madames.
--start, --end: Start/end date.
-t, --today:    Download today's Madame. This is the default option.
-d, --date:     Download Madame for a specific date (YYYY-MM-DD). Note: lowest date is 2015-12-01.
-c, --cron:     Add a crontab entry every weekdays at 10:30AM.
-f, --folder:   Target folder for photos. Default folder is /home/$USER/Images/BM.
-h, --help:     Display usage.
```

## License

See [LICENSE.md](./LICENSE.md).
