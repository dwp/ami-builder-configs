import jinja2
import os
import json
import sys


def handler(event):

    with open('generic_packer_template.json.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('packer.json', 'w+') as packer_file:
        packer_file.write(template.render(
            event=event))


if __name__ == "__main__":
    json_content = json.loads(
        open('manifest.json', 'r').read())
    try:
        handler(json_content)
    except KeyError as key_name:
        sys.exit(1)
    except Exception as e:
        sys.exit(1)
