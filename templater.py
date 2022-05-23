import os
from yaml import load
from collections.abc import MutableMapping
from pprint import pprint

from jinja2 import Environment, FileSystemLoader

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

def flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, MutableMapping):
            items.extend(flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)

class TemplateWrapper(object):
    def __init__(self, cac_path:str, iac_path:str, templates_folder:str, scripts_path:str, dsc:dict):
        self.cac_path = cac_path
        self.iac_path =iac_path
        self.template_root_folder = templates_folder
        self.scripts_path  = scripts_path
        self.dsc = dsc
        self.set_template_paths()

    def set_template_paths(self):
        self.env = Environment(
            loader=FileSystemLoader([
                os.path.join(self.template_root_folder, 'hcl'), 
                os.path.join(self.template_root_folder, 'playbooks'),
                os.path.join(self.template_root_folder, 'scripts')
            ])
        )

    def azurevmss(self):
        # gather templates
        green_hcl_template = self.env.get_template('azure-vmss.hcl.j2')
        # set destination path
        green_image_path = os.path.join(self.iac_path, 'azure-vmss.pkr.hcl')
        with open(green_image_path, 'w') as green_img:
            green_img.write(green_hcl_template.render(dsc=self.dsc))

    def playbook(self):
        # gather templates
        playbook_yaml_template = self.env.get_template('playbook.yaml.j2')
        # set destination path
        playbook_path = os.path.join(self.cac_path, 'playbook.yaml')
        with open(playbook_path, 'w') as playbook:
            playbook.write(playbook_yaml_template.render(dsc=self.dsc))

    def prestateimg(self):
        # gather templates
        pre_processor_script_template = self.env.get_template('pre-processor-img.sh.j2')
        # set destination path
        script_path = os.path.join(self.scripts_path, 'pre-processor-img.sh')
        with open(script_path, 'w') as script:
            script.write(pre_processor_script_template.render(dsc=self.dsc))

# change path to directory of this script
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

DESIRED_STATE_PATH=os.path.abspath('desired_settings.yaml')
# Gathered from ENV

with open(DESIRED_STATE_PATH, 'r') as stream:
    dsc = flatten(load(stream.read(), Loader=Loader))
    pprint(dsc)

    cac_path=os.path.abspath(os.path.join('.', 'build_config'))
    iac_path=os.path.abspath(os.path.join('.', 'builds'))
    scripts_path=os.path.abspath(os.path.join('.', 'scripts'))

    build = TemplateWrapper(
        cac_path=cac_path,
        iac_path=iac_path,
        templates_folder=os.path.abspath('templates'),
        scripts_path=scripts_path,
        dsc=dsc
    )
    build.azurevmss()
    build.playbook()
    build.prestateimg()