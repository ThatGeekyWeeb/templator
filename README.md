***
Templator - Converts Void Linux templates into `crew` .rb's
***

Within this repo are multiple tools for usage with the automation of packaging programs within `crew`.

#### `templator` - The main tool
Generates `.rb` for your package

Usage: `bash ./templator.sh ./template`
Options:
- `search_bol=1` (`search_bol=1 bash ./templator ./template`) - Runs `crew search` with a list of deps - Uses `search.sh`
- `no_checks` (`bash ./templator ./template no_checks`) - Allows `python3-module` build type scripts to be used
***
#### `tempnail` - Nails for the `templator` wall
Downloads the `template` for `$pkgname`

Usage: `bash ./tempnail.sh "$pkgname"` - (`vim` = `bash ./tempnail.sh "vim"`)
