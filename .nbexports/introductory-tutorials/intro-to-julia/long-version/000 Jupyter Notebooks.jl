# ------------------------------------------------------------------------------------------
# ## Getting started with Jupyter notebooks
#
# Jupyter notebooks are a convenient way to run, display, and present interactive code. The
# main concept is a cell — a single chunk of text. Cells may be markdown (like this one) or
# code (like the next).
#
# ### Running a cell
# To execute code within a cell, select that cell and either (1) hit `Shift` and `Enter` or
# (2) hit the run button (the right pointing arrow) above.
# ------------------------------------------------------------------------------------------

1 + 1
2 + 2

# ------------------------------------------------------------------------------------------
# If you're new to jupyter notebooks, note that only the last line of a cell prints by
# default when you execute that cell and that you can suppress this output with a semicolon
# ------------------------------------------------------------------------------------------

1 + 1
2 + 2;

# ------------------------------------------------------------------------------------------
# ## Changing modes and inserting new cells
#
# You can use the menu above or key combinations — ESC will drop out of editing a cell and
# into a command mode where there are special keyboard shortcuts to insert/cut/modify cells
# themselves. Try `ESC` and then `a` or `b` for "above" and "below".
#
# See the Help menu for all available shortcuts
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ## Special modes for cells
#
# Cells can change their behavior depending on their very first character
# ------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
# ### How to get docs for Julia functions
#
# To get docs for a function you're not familiar with, precede it with a question mark.
# (This works at the REPL too!)
# ------------------------------------------------------------------------------------------

?println

# ------------------------------------------------------------------------------------------
# ### How to use shell commands
#
# Type `;` and then you can use shell commands. For example,
# ------------------------------------------------------------------------------------------

;ls

;pwd

# ------------------------------------------------------------------------------------------
# ### Interacting with the package manager
#
# Julia's package manager has a special "command" syntax mode — you can enter it with a `]`
# character.
# ------------------------------------------------------------------------------------------

]status
