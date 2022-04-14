import os
from yaml import load, dump
from pprint import pprint

# change path to directory of this script
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

BUILD_CONFIG_PATH=os.path.abspath('./build_config')
BUILD_IMAGE_BASEPATH=os.path.abspath('./builds')
DESIRED_STATE_PATH=os.path.abspath('desired_settings.yaml')
HCL_TEMPLATE=os.path.join(os.path.abspath('./templates'), 'agent-packer.hcl.j2')
PLAYBOOK_TEMPLATE=os.path.join(os.path.abspath('./templates'), 'playbook.hcl.j2')

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

def render_template(dst_path, config, template_path, file_name):
    """
        Render HCL packer file in side folder dst_path
    """
    template


with open(DESIRED_STATE_PATH, 'r') as stream:
    dsc = load(stream.read(), Loader=Loader)
    # save all desired settings below
    try:
        ds_environment = dsc['azure']['environment']
        ds_location = dsc['azure']['location']
        ds_scale_set_create = dsc['scale_set']['new_instance']
        ds_scale_set_rg = dsc['scale_set']['settings']['resource_group']
        ds_scale_set_name = dsc['scale_set']['settings']['name']
        ds_platform_type = dsc['platform']['type']
        ds_build_rg = dsc['builds']['resource_group']
        ds_build_linux_enable = dsc['builds']['linux']['enable']
        ds_build_linux_image_offer = dsc['builds']['linux']['settings']['image_offer']
        ds_build_linux_image_gpg_packages = dsc['builds']['linux']['settings']['gpg_packages']
        ds_build_linux_image_repositories = dsc['builds']['linux']['settings']['repositories']
        ds_build_linux_image_packages = dsc['builds']['linux']['settings']['packages']
        ds_build_windows_enable = dsc['builds']['windows']['enable']
        ds_build_windows_image_offer = dsc['builds']['windows']['image_offer']
        ds_build_windows_image_powershell_modules = dsc['builds']['windows']['powershell_modules']
        ds_build_windows_image_choco_packages = dsc['builds']['windows']['choco_packages']
    except (KeyError, ValueError) as err:
        print(f'Missing config key in {DESIRED_STATE_PATH}: ', err)

    match ds_platform_type:
        case "AzureDevOps":
            hcl_file_name='local_debug.pkr.hcl'
            dst_render_path = os.path.join(BUILD_IMAGE_BASEPATH, ds_platform_type, )
            render_template(dst_path=dst_render_path, config=dsc, template_path="", file_name="")
    