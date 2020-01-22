import io
import os

dir_path = os.path.dirname(os.path.realpath(__file__))
nbexports_path = os.path.join(dir_path, ".nbexports")

from notebook.utils import to_api_path

_script_exporter = None

def script_post_save(model, os_path, contents_manager, **kwargs):
    if model['type'] != 'notebook':
        return

    from nbconvert.exporters.script import ScriptExporter
    from nbconvert.exporters.html import HTMLExporter

    global _script_exporter
    if _script_exporter is None:
        _script_exporter = ScriptExporter(parent=contents_manager)
        _script_exporter.template_file = os.path.join(dir_path, 'jupyter_script_export_template.tpl')

    export_script(_script_exporter,   model, os_path, contents_manager, **kwargs)

def export_script(exporter, model, os_path, contents_manager, **kwargs):
    """convert notebooks to Python script after save with nbconvert
    replaces `ipython notebook --script`
    """
    base, ext = os.path.splitext(os_path)
    script, resources = exporter.from_filename(os_path)
    script_fname = base + resources.get('output_extension', '.txt')
    script_repopath = to_api_path(script_fname, contents_manager.root_dir)
    log = contents_manager.log
    script_fullpath = os.path.join(dir_path, ".nbexports", script_repopath)
    os.makedirs(os.path.dirname(script_fullpath), exist_ok=True)
    log.info("Saving script /%s", script_fullpath)
    with io.open(script_fullpath, 'w', encoding='utf-8', newline='\n') as f:
        f.write(script)


c.FileContentsManager.post_save_hook = script_post_save

