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
from frameworks.utils.utils import sleeper_service

#################################
# Zoe Application customization #
#################################

APP_NAME = 'sleeper'
SLEEP_DURATION = 5  # seconds

#####################
# END CUSTOMIZATION #
#####################


def sleeper_app(name, sleep_duration):
    app = {
        'name': name,
        'version': 1,
        'will_end': True,
        'priority': 512,
        'requires_binary': False,
        'services': [
            sleeper_service(sleep_duration)
        ]
    }
    return app


def create_app(app_name=APP_NAME, sleep_duration=SLEEP_DURATION):
    return sleeper_app(app_name, sleep_duration)

if __name__ == "__main__":
    app_dict = create_app(app_name=APP_NAME, sleep_duration=SLEEP_DURATION)
    json.dump(app_dict, sys.stdout, sort_keys=True, indent=4)
    sys.stdout.write('\n')
