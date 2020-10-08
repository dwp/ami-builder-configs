import botocore
import boto3
import jinja2
import logging
import os
import subprocess
import json
import sys
from botocore.exceptions import ClientError

# Initialise logging
logger = logging.getLogger(__name__)
log_level = os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else "ERROR"
logger.setLevel(logging.getLevelName(log_level.upper()))
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s %(levelname)s %(module)s "
           "%(process)s[%(thread)s] %(message)s",
)
logger.info("Logging at {} level".format(log_level.upper()))


def handler(event, context):
    if 'AWS_PROFILE' in os.environ:
        boto3.setup_default_session(profile_name=os.environ['AWS_PROFILE'])

    if logger.isEnabledFor(logging.DEBUG):
        # Log everything from boto3
        boto3.set_stream_logger()
    logger.debug(f"Using boto3 {boto3.__version__}")
    logger.debug(event)

    with open('generic_packer_template.json.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('packer.json', 'w+') as packer_file:
        packer_file.write(template.render(
            event=event))
        logger.debug(packer_file.read())


if __name__ == "__main__":
    json_content = json.loads(
        open('manifest.json', 'r').read())
    try:
        handler(json_content, None)
    except KeyError as key_name:
        logger.error(f'Key: {key_name} is required in payload')
        sys.exit(1)
    except Exception as e:
        logger.error(e)
        sys.exit(1)
