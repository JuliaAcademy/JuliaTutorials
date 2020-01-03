{# Lines inside these brackets are comments #}
{#- Brackets with a `-` mean to skip whitespace before or after the block. -#}

{#-
 # This file defines a Jinja Template for converting .ipynb files into scripts
 # for either delve or julia. We need this because the default script exporter
 # doesn't render Markdown for any languages except Python.
 # Exporting the markdown makes github reviews of .ipynb files easier.
 # This template is invoked by our custom `jupyter_notebook_config.py`. You can
 # read more about the Jinja template specification here:
 #   http://jinja.pocoo.org/docs/2.10/templates/#comments
 # and here:
 #   https://nbconvert.readthedocs.io/en/latest/customizing.html
 # And the filter functions used in this file are defined here:
 #   https://github.com/pallets/jinja/blob/master/jinja2/filters.py
 # and here:
 #   https://github.com/jupyter/nbconvert/blob/master/nbconvert/filters/strings.py
 -#}

{#- ---------
 # Lines up here, before the `extends` section, go at the top of the file, before any other
 # content from the notebook itself.
 #----------- -#}

{%- if 'name' in nb.metadata.get('kernelspec', {}) and
    nb.metadata.kernelspec.name == 'julia' -%}
# This file was generated from a Julia language jupyter notebook.
{% endif -%}

{% extends 'script.tpl'%}

{% block markdowncell %}
  {#- Turn the contents of the markdown cell into a wrapped comment block, and trim empty lines. -#}

  {#-
   # NOTE: We used `kernelspec.name` not `language_info.name`, for reasons specific to
   # our custom jupyter kernel. I think `language_info.name` might be more robust?
   -#}
  {%- if 'name' in nb.metadata.get('kernelspec', {}) and
    nb.metadata.kernelspec.name == 'julia' -%}
    {%- set commentprefix = '# ' -%}
  {#-
   # Add other languages here as if-else block, e.g. C++ would use '// '
   -#}
  {%- else -%}
    {#- Assume python by default -#}
    {%- set commentprefix = '# ' -%}
  {%- endif -%}

  {%- set commentlen = 92-(commentprefix|length) -%}
  {{- '\n' -}}
  {{- commentprefix ~ '-' * commentlen -}}
  {{- '\n' -}}

  {#- Turn the contents of the markdown cell into a wrapped comment block, and trim empty lines. -#}
  {#- Note: `comment_lines` and `wrap_text` are defined in nbconvert/filters/strings.py -#}
  {{- cell.source | wrap_text(width=commentlen) | comment_lines(prefix=commentprefix) | replace(commentprefix~"\n", commentprefix|trim ~ "\n") -}}

  {{- '\n' -}}
  {{- commentprefix ~ '-' * commentlen -}}
  {{- '\n' -}}

{% endblock markdowncell %}
