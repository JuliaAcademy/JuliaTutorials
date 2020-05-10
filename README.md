# JuliaBoxTutorials

This repository contains introductory tutorials for the [Julia language](http://julialang.org/) in the form of [Jupyter Notebooks](https://jupyter.org/about). You can run the notebooks locally by [installing nteract](https://nteract.io). 

## Running Julia on your Computer

You can also do these tutorials by installing `julia` on your computer, setting up Jupyter, and downloading this tutorial repository to your computer.
If you're new to Julia, you can do that by following these steps:

1. Download julia from https://julialang.org/downloads/ (download the latest "stable" version).
   - Follow the instructions to install it on your computer (e.g. On macOS, drag it to Applications. On Windows, run the installer.)
2. Install julia's Jupyter Notebooks integration: IJulia.jl
   - Open the installed julia application, and you are presented with a "REPL" prompt. This is the main Julia interface. There, type this closing bracket
     character: <kbd>]</kbd> to open the package manager. Then type `add IJulia` to install the jupyter notebook interface for julia.
   - Then exit the package manager by pressing <kbd>delete</kbd> (as if you're deleting the `]` you typed to enter package mode)
   - Now you can open the jupyter notebooks by entering `using IJulia`, then once that loads, entering `IJulia.notebook()`, which should
     open a Jupyter tab in your browser.
3. Last, download the tutorials from this repository, via the github Clone/Download button above, or clicking this link:
    - https://github.com/JuliaComputing/JuliaBoxTutorials/archive/master.zip
    - (If you've never used GitHub before, it's a place to collaborate on open source software. Julia itself is also [developed on github!](https://github.com/JuliaLang/julia))

And now from the Jupyter tab in your browser, you can navigate to the folder where you downloaded the tutorials, and then click
on the name of one of them to get started! Enjoy!
