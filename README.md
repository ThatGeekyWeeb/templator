***
Templator - Converts Void Linux templates into `crew` .rb's
***

Within this repo are multiple tools for usage with the automation of packaging programs within `crew`.

## Dependencies
`crew`\
`node` - Use nodebrew - For `patch_grabber.sh`\
`gitio-cli` - Install from submodule\
`wget` - For `patch_grabber.sh`\
`wl_clipboard` - For `patch_grabber.sh`
*** 

#### `templator` - The main tool
Generates `.rb` for your package

Usage: `bash ./templator.sh ./template`
Options:
- `search_bol=1` (`search_bol=1 bash ./templator ./template`) - Runs `crew search` with a list of deps - Uses `search.sh`
- `no_checks` (`bash ./templator ./template no_checks`) - Allows `python3-module` build type scripts to be used
***
Currently output is redirected to `$pkgname.rb` automatticly 
***
#### `tempnail` - Nails for the `templator` wall
Downloads the `template` for `$pkgname`

Usage: `bash ./tempnail.sh "$pkgname"` - (`vim` = `bash ./tempnail.sh "vim"`)
***
#### `rawgrab` - Grabs raw files from any repo, any tree/tag with any file name.
Usage: `bash ./rawgrab.sh "$user/$repo" "$tree" "$filename" "$output"`
***
**NOTE:** This software is meant to be used at bash tools for a personal project, thus documentaion has not been provided ~ The source contains comments which outline how the script works.
