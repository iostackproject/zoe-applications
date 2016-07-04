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
WORKER_MEMORY = 1024 ** 3
WORKER_COUNT = 4
CPU_COUNT_PER_WORKER = 1
DOCKER_REGISTRY = '172.17.131.201:5000'  # Set to None to use images from the Docker Hub
MPIRUN_IMAGE = 'zoeapps/openmpi-ubuntu14'
WORKER_IMAGE = 'zoeapps/openmpi-ubuntu14'
MPIRUN_COMMANDLINE = 'mpirun -hostfile hostlist MPI_Hello'


#####################
# END CUSTOMIZATION #
#####################


def openmpi_worker_service(count, image, worker_memory):
    """
    :type counter: int
    :type worker_memory: int
    :rtype: dict
    """
    service = {
        'name': "mpiworker",
        'docker_image': image,
        'monitor': False,
        'required_resources': {"memory": worker_memory},
        'ports': [],
        'environment': [],
        'volumes': [],
        'command': '',
        'total_count': count,
        'essential_count': count,
        'startup_order': 0
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
        'total_count': 1,
        'essential_count': 1,
        'startup_order': 1
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
    proc = openmpi_worker_service(worker_count, worker_image, worker_memory)
    app['services'].append(proc)
    proc = openmpi_mpirun_service(mpirun_commandline, mpirun_image, worker_memory)
    app['services'].append(proc)
    return app


def create_app(app_name=APP_NAME, mpirun_image=MPIRUN_IMAGE, worker_image=WORKER_IMAGE,
               mpi_commandline=MPIRUN_COMMANDLINE, worker_count=WORKER_COUNT, worker_memory=WORKER_MEMORY,
               docker_registry=DOCKER_REGISTRY, cpu_count_per_worker=CPU_COUNT_PER_WORKER):
    if docker_registry is not None:
        mpirun_image = docker_registry + '/' + mpirun_image
        worker_image = docker_registry + '/' + worker_image

    with open('hostlist', 'w') as fp:
        for wc in range(worker_count):
            fp.write('mpiworker{}-mpihellodemo-zoeadmin-iostack-zoe:{}\n'.format(wc, cpu_count_per_worker))
        print('Wrote MPI host list file in "hostlist", execution name set to "mpihellodemo"')
    return openmpi_app(app_name, mpirun_image, worker_image, mpi_commandline, worker_count, worker_memory)


if __name__ == "__main__":
    app_dict = create_app(APP_NAME, MPIRUN_IMAGE, WORKER_IMAGE, MPIRUN_COMMANDLINE, WORKER_COUNT, WORKER_MEMORY)
    json.dump(app_dict, open('zoeapp.json', 'w'), sort_keys=True, indent=4)
    print('Wrote application description to "zoeapp.json"')
