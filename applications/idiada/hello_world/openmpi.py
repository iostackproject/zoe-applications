#!/usr/bin/env python

# Copyright (c) 2015, Daniele Venzano
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

#################################
# Zoe Application customization #
#################################

APP_NAME = 'openmpi-hello'
MPIRUN_COMMANDLINE = 'mpirun -hostfile hostlist MPI_Hello'
MPIRUN_IMAGE = '192.168.45.252:5000/zoeapps/openmpi-ubuntu14'
WORKER_IMAGE = '192.168.45.252:5000/zoeapps/openmpi-ubuntu14'
WORKER_COUNT = 4
CPU_COUNT_PER_WORKER = 1
WORKER_MEMORY = 1024 ** 3

#####################
# END CUSTOMIZATION #
#####################


def openmpi_worker_service(counter, image, worker_memory):
    """
    :type counter: int
    :type worker_memory: int
    :rtype: dict
    """
    service = {
        'name': "mpiworker{}".format(counter),
        'docker_image': image,
        'monitor': False,
        'required_resources': {"memory": worker_memory},
        'ports': [],
        'environment': [],
        'volumes': [],
        'command': ''
    }
    return service


def openmpi_mpirun_service(mpirun_commandline, image, worker_memory):
    """
    :type mpirun_commandline: str
    :type worker_memory: int
    :rtype: dict
    """
    service = {
        'name': "mpirun",
        'docker_image': image,
        'monitor': True,
        'required_resources': {"memory": worker_memory},
        'ports': [],
        'environment': [],
        'volumes': [],
        'command': mpirun_commandline
    }
    return service


def openmpi_app(name, mpirun_image, worker_image, mpirun_commandline, worker_count, worker_memory):
    app = {
        'name': name,
        'version': 1,
        'will_end': True,
        'priority': 512,
        'requires_binary': True,
        'services': []
    }
    for i in range(worker_count):
        proc = openmpi_worker_service(i, worker_image, worker_memory)
        app['services'].append(proc)
    proc = openmpi_mpirun_service(mpirun_commandline, mpirun_image, worker_memory)
    app['services'].append(proc)
    return app


if __name__ == "__main__":
    app_dict = openmpi_app(APP_NAME, MPIRUN_IMAGE, WORKER_IMAGE, MPIRUN_COMMANDLINE, WORKER_COUNT, WORKER_MEMORY)
    json.dump(app_dict, open('zoeapp.json', 'w'), sort_keys=True, indent=4)
    print('Wrote application description to "zoeapp.json"')

    with open('hostlist', 'w') as fp:
        for wc in range(WORKER_COUNT):
            fp.write('mpiworker{}-mpihellodemo-zoeadmin-iostack-zoe:{}\n'.format(wc, CPU_COUNT_PER_WORKER))
    print('Wrote MPI host list file in "hostlist", execution name set to "mpihellodemo"')

