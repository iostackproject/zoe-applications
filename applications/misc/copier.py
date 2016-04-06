#!/usr/bin/env python

# Copyright (c) 2016, Daniele Venzano
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
import json
sys.path.append('../..')
from frameworks.utils.utils import copier_service

#################################
# Zoe Application customization #
#################################

APP_NAME = 'copier'
SRC_HOST_PATH = '/mnt/nfs/data'  # Must be a directory that will be mounted as a volume
SRC_PATH = '*'  # Contents of SRC_HOST_PATH to copy in the workspace
DST_PATH = 'data'  # Copy destination inside the Zoe workspace

#####################
# END CUSTOMIZATION #
#####################


def copier_app(app_name, src_volume_host_path, src_path, dst_path):
    app = {
        'name': app_name,
        'version': 1,
        'will_end': True,
        'priority': 512,
        'requires_binary': False,
        'services': [
            copier_service(src_volume_host_path, src_path, dst_path)
        ]
    }
    return app

if __name__ == "__main__":
    app_dict = copier_app(APP_NAME, SRC_HOST_PATH, SRC_PATH, DST_PATH)
    json.dump(app_dict, sys.stdout, sort_keys=True, indent=4)
    sys.stdout.write('\n')
