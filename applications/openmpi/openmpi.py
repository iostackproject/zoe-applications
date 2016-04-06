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
import frameworks.openmpi.openmpi as openmpi_framework

#################################
# Zoe Application customization #
#################################

APP_NAME = 'openmpi-hello'
MPIRUN_COMMANDLINE = 'mpirun <options>'
WORKER_COUNT = 4
CPU_COUNT_PER_WORKER = 1
WORKER_MEMORY = 1024 ** 3

#####################
# END CUSTOMIZATION #
#####################


def openmpi_app(name, mpirun_commandline, worker_count, worker_memory):
    app = {
        'name': name,
        'version': 1,
        'will_end': True,
        'priority': 512,
        'requires_binary': True,
        'services': []
    }
    for i in range(worker_count):
        proc = openmpi_framework.openmpi_worker_service(i, worker_memory)
        app['services'].append(proc)
    proc = openmpi_framework.openmpi_mpirun_service(mpirun_commandline, worker_memory)
    app['services'].append(proc)
    return app


if __name__ == "__main__":
    app_dict = openmpi_app(APP_NAME, MPIRUN_COMMANDLINE, WORKER_COUNT, WORKER_MEMORY)
    json.dump(app_dict, sys.stdout, sort_keys=True, indent=4)
    sys.stdout.write('\n')

    sys.stderr.write('### Copy and customize the following lines to the hostlist file passed to mpirun #####\n')
    for wc in range(WORKER_COUNT):
        sys.stderr.write('mpiworker{}-##Zoe execution name##-##zoe user name##-##zoe deployment name##-zoe:{}\n'.format(wc, CPU_COUNT_PER_WORKER))
