# Contributing

Changes to Jupyter Notebooks are notoriously difficult to review in git /
GitHub. 

In order to make it easier to review changes to notebook files, we use custom
Jupyter configuration and template files to automatically generate an output
"script" file with the contents of the notebook exported to a plain text file.
For julia notebooks, these produce `.jl` files.

In order to make sure this configuration applies to your changes, **please
ensure that you launch Jupyter from the top of this repo directory!** You can
do that via one of these approaches:
- Launch Jupyter via the commandline from this repo:
  ```bash
  $ cd JuliaBoxTutorials
  $ jupyter notebook
  ```
- Launch Jupyter via IJulia from this repo:
  ```bash
  $ cd JuliaBoxTutorials
  $ julia
  julia> IJulia.notebook(dir=".")  # This `dir="."` is required!
  ```

This will ensure that every time you save an .ipynb file, it will export a .jl script in our `.nbexports` directory! :)

## Jupyter configuration details

The jupyter configuration is managed via two files:
- `jupyter_notebook_config.py`: Configure jupyter to export a script whenever a
  notebook is saved.
- `jupyter_script_export_template.tpl`: A template file specifying how to
  export the script. This is needed because by default, jupyter doesn't output
  the Markdown cells in Julia notebooks into comment blocks. (It only does that
  for python notebooks.)


NOTE: Since these are only generated when saving a notebook file, if you delete
or rename an ipynb file, you'll need to manually delete the outdated .nbexport
file. See below.

## Manual nbconvert

To manually trigger exporting script files, you can use nbconvert, via the following command:
```bash
$ jupyter nbconvert --to script "/path/to/nb.ipynb" --template=./jupyter_script_export_template.tpl
```

To re-generate all script files, you can run:
```bash
$ rm .nbexports/*
$ julia
julia> let nbexports = "$(pwd())/.nbexports", tmpl = "$(pwd())/jupyter_script_export_template.tpl"
           for (root, dirs, files) in walkdir(".")
               for file in files
                   if endswith(file, ".ipynb")
                       outdir = joinpath(nbexports, root)
                       run(`jupyter nbconvert --to script $root/$file --template=$tmpl --output-dir=$outdir`)
                   end
               end
           end
       end
```
