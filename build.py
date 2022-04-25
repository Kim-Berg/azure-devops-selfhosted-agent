import os
from yaml import load, dump
from pprint import pprint
from collections.abc import MutableMapping

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

# change path to directory of this script
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)
# Define standard project paths
CAC_PATH = os.path.abspath(os.path.join('.', 'build_config'))
IAC_PATH = os.path.abspath(os.path.join('.', 'builds'))
DESIRED_STATE_PATH=os.path.abspath('desired_settings.yaml')
HCL_TEMPLATE=os.path.join(os.path.abspath('./templates'), 'agent-packer.hcl.j2')
PLAYBOOK_TEMPLATE=os.path.join(os.path.abspath('./templates'), 'playbook.hcl.j2')
# Gathered from ENV
ENV_CLIENT_ID=os.environ['AZURE_CLIENT_ID']
ENV_CLIENT_SECRET=os.environ['AZURE_CLIENT_SECRET']
ENV_TENANT_ID=os.environ['AZURE_TENANT_ID']
ENV_SUBSCRIPTION_ID=os.environ['AZURE_SUBSCRIPTION_ID']


def validate_dsc(dsc):
    """

    """
    pass

def render_template(dst_path, config, template_path, file_name):
    """
        Render HCL packer file in side folder dst_path
    """
    pass

def flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, MutableMapping):
            items.extend(flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


with open(DESIRED_STATE_PATH, 'r') as stream:
    cac_path = os.path.abspath(os.path.join('.', 'build_config'))
    iac_path = os.path.abspath(os.path.join('.', 'builds'))

    dsc = flatten(load(stream.read(), Loader=Loader))
    dsc['client_id'] = ENV_CLIENT_ID
    dsc['client_secret'] = ENV_CLIENT_SECRET
    dsc['tenant_id'] = ENV_TENANT_ID
    dsc['subscription_id'] = ENV_SUBSCRIPTION_ID

    match dsc["deployment_agent_type"]:
        case "AzureDevOps":
            hcl_file_name='local_debug.pkr.hcl'
            dst_render_path = os.path.join(CAC_PATH, "AzureDevOps", f"{dsc['deployment_name']}.hcl")
            print(dst_render_path)
            render_template(dst_path=dst_render_path, config=dsc, template_path="", file_name="")
    