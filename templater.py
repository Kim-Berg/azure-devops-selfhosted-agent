import os
from yaml import load
from collections.abc import MutableMapping

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

class Template(object):
    def __init__(self, cac_path:str, iac_path:str, templates_folder:str, dsc:dict):
        self.cac_path = cac_path
        self.iac_path =iac_path
        self.template_folder = templates_folder
        self.dsc = dsc
        self.playbook_template_path = os.path.join(self.template_folder, 'playbooks')

    def set_env(self):
        self.env = Environment(
            loader=FileSystemLoader([self.hcl_template_path, self.playbook_template_path])
        )

    def azuredevops(self, dst_path):
        # prepare runtime for ado template rendering
        self.hcl_template_path = os.path.join(self.template_folder, 'AzureDevOps')
        self.set_env()

        # gather templates
        green_hcl_template = self.env.get_template('green-image.hcl.j2')
        blue_hcl_template = self.env.get_template('blue-image.hcl.j2')
        # set destination path
        blue_image_path = os.path.join(dst_path, 'blue-image.pkr.hcl')
        green_image_path = os.path.join(dst_path, 'green-image.pkr.hcl')
        
        with open(green_image_path, 'w') as green_img:
            green_img.write(green_hcl_template.render(dsc=self.dsc))

        with open(blue_image_path, 'w') as blue_img:
            blue_img.write(blue_hcl_template.render(dsc=self.dsc))

    def playbook(self, dst_path):
        playbook_yaml_template = self.env.get_template('playbook.yaml.j2')
        with open(dst_path, 'w') as playbook:
            playbook.write(playbook_yaml_template.render(dsc=self.dsc))

# change path to directory of this script
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

DESIRED_STATE_PATH=os.path.abspath('desired_settings.yaml')
# Gathered from ENV

with open(DESIRED_STATE_PATH, 'r') as stream:
    dsc = flatten(load(stream.read(), Loader=Loader))
    agent_type = dsc["deployment_agent_type"]

    cac_path=os.path.abspath(os.path.join('.', 'build_config'))
    iac_path=os.path.abspath(os.path.join('.', 'builds'))

    build = Template(
        cac_path=cac_path,
        iac_path=iac_path,
        templates_folder=os.path.abspath('templates'),
        dsc=dsc
    )

    match agent_type:
        case "AzureDevOps":
            ado_instance = getattr(build, agent_type.lower())
            ado_instance(
                dst_path=iac_path
            )
        case "Github":
            # just to show to scale out code
            pass
    