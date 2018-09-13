# An Introduction to DataFrames

[Bogumił Kamiński](http://bogumilkaminski.pl/about/), May 23, 2018

A brief introduction to basic usage of [DataFrames](https://github.com/JuliaData/DataFrames.jl).
Tested under Julia 0.6.2, DataFrames 0.11.6, CSV 0.2.4, JLD 0.8.3, Missings 0.2.9, CategoricalArrays 0.3.9, FreqTables 0.2.2, DataFramesMeta 0.3.0, StatPlots 0.7.2.

I will try to keep it up to date as the package evolves.
This tutorial covers
[DataFrames](https://github.com/JuliaData/DataFrames.jl),
[CSV](https://github.com/JuliaData/CSV.jl),
[JLD](https://github.com/JuliaIO/JLD.jl),
[Missings](https://github.com/JuliaData/Missings.jl),
and [CategoricalArrays](https://github.com/JuliaData/CategoricalArrays.jl),
as they constitute the core of [DataFrames](https://github.com/JuliaData/DataFrames.jl).

In the last [extras](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/13_extras.ipynb)
part mentions *selected* functionalities of *selected* useful packages that I find useful for data manipulation, currently those are:
[FreqTables](https://github.com/nalimilan/FreqTables.jl),
[DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl),
[StatPlots](https://github.com/JuliaPlots/StatPlots.jl).

# TOC

| File                                                                                                              | Topic                             |
|-------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| [01_constructors.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/01_constructors.ipynb)   | Creating DataFrame and conversion |
| [02_basicinfo.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/02_basicinfo.ipynb)         | Getting summary information       |
| [03_missingvalues.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/03_missingvalues.ipynb) | Handling missing values           |
| [04_loadsave.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/04_loadsave.ipynb)           | Loading and saving DataFrames     |
| [05_columns.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/05_columns.ipynb)             | Working with columns of DataFrame |
| [06_rows.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/06_rows.ipynb)                   | Working with row of DataFrame     |
| [07_factors.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/07_factors.ipynb)             | Working with categorical data     |
| [08_joins.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/08_joins.ipynb)                 | Joining DataFrames                |
| [09_reshaping.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/09_reshaping.ipynb)         | Reshaping DataFrames              |
| [10_transforms.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/10_transforms.ipynb)       | Transforming DataFrames           |
| [11_performance.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/11_performance.ipynb)     | Performance tips                  |
| [12_pitfalls.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/12_pitfalls.ipynb)           | Possible pitfalls                 |
| [13_extras.ipynb](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/13_extras.ipynb)               | Additional interesting packages   |

Changelog:

| Date       | Changes                                                                                           |
|------------|---------------------------------------------------------------------------------------------------|
| 2017-12-05 | Initial release                                                                                   |
| 2017-12-06 | Added description of `insert!`, `merge!`, `empty!`, `categorical!`, `delete!`, `DataFrames.index` |
| 2017-12-09 | Added performance tips                                                                            |
| 2017-12-10 | Added pitfalls                                                                                    |
| 2017-12-18 | Added additional worthwhile packages: *FreqTables* and *DataFramesMeta*                           |
| 2017-12-29 | Added description of `filter` and `filter!`                                                       |
| 2017-12-31 | Added description of conversion to `Matrix`                                                       |
| 2018-04-06 | Added example of extracting a row from a `DataFrame`                                              |
| 2018-04-21 | Major update of whole tutorial                                                                    |
| 2018-05-01 | Added `byrow!` example                                                                            |
| 2018-05-13 | Added `StatPlots` package to extras                                                               |
| 2018-05-23 | Improved comments in sections 1 do 5 by [Jane Herriman](https://github.com/xorJane)               |

# Core functions summary

1. Constructors: `DataFrame`
2. Getting summary: `size`, `nrow`, `ncol`, `length`, `describe`, `showcols`, `names`, `eltypes`, `head`, `tail`
3. Handling missing: `missing` (singleton instance of `Missing`), `ismissing`, `Missings.T`, `skipmissing`, `coalesce`, `allowmissing`, `disallowmissing`, `allowmissing!`, `completecases`, `dropmissing`, `dropmissing!`, disallowmissing, disallowmissing!
4. Loading and saving: `CSV` (package), `JLD` (package), `CSV.read`, `CSV.write`, `save` (from `JLD`), `load` (from `JLD`)
5. Working with columns: `rename`, `rename!`, `names!`, `hcat`, `insert!`, `DataFrames.hcat!`, `merge!`, `delete!`, `empty!`, `categorical!`, `DataFrames.index`
6. Working with rows: `sort!`, `sort`, `issorted`, `append!`, `vcat`, `push!`, `view`, `filter`, `filter!`, `deleterows!`, `unique`, `nonunique`, `unique!`
7. Working with categorical: `categorical`, `cut`, `isordered`, `ordered!`, `levels`, `unique`, `levels!`, `droplevels!`, `get`, `recode`, `recode!`
8. Joining: `join`
9. Reshaping: `stack`, `melt`, `stackdf`, `meltdf`, `unstack`
10. Transforming: `groupby`, `vcat`, `by`, `aggregate`, `eachcol`, `eachrow`, `colwise`
11. Extras:
    * [FreqTables](https://github.com/nalimilan/FreqTables.jl): `freqtable`, `prop`
    * [DataFramesMeta](https://github.com/JuliaStats/DataFramesMeta.jl): `@with`, `@where`, `@select`, `@transform`, `@orderby`, `@linq`,
      `by`, `based_on`, `byrow!`
    * [StatPlots](https://github.com/JuliaPlots/StatPlots.jl): `@df`, `plot`, `density`, `histogram`,`boxplot`, `violin`

# Changes in DataFrames master since last update of the tutorial

1. Improved rendering of `#undef` in HTML/LaTeX.
2. Added `permutecols!` function.
