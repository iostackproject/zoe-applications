#!/usr/bin/env python

# Copyright (c) 2016, Francesco Pace
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
import frameworks.spark.spark as spark_framework
import frameworks.spark.spark_jupyter as spark_jupyter

#################################
# Zoe Application customization #
#################################

APP_NAME = 'ibm-notebook'
SPARK_MASTER_MEMORY_LIMIT = 512 * (1024 ** 2)  # 512MB
SPARK_WORKER_MEMORY_LIMIT = 12 * (1024 ** 3)  # 12GB
NOTEBOOK_MEMORY_LIMIT = 4 * (1024 ** 3)  # 4GB, contains also the Spark client
SPARK_WORKER_CORES = 6
SPARK_WORKER_COUNT = 2
DOCKER_REGISTRY = '172.17.131.201:5000'  # Set to None to use images from the Docker Hub
SPARK_MASTER_IMAGE = 'iostackrepo/spark-master-ibm'
SPARK_WORKER_IMAGE = 'iostackrepo/spark-worker-ibm'
NOTEBOOK_IMAGE = 'iostackrepo/spark-jupyter-notebook-ibm'


#####################
# END CUSTOMIZATION #
#####################


def spark_jupyter_notebook_ibm_app(name,
                                   notebook_mem_limit, master_mem_limit, worker_mem_limit, worker_cores,
                                   worker_count,
                                   master_image, worker_image, notebook_image):
    sp_master = spark_framework.spark_master_service(int(master_mem_limit), master_image)
    sp_workers = spark_framework.spark_worker_service(int(worker_count), int(worker_mem_limit), int(worker_cores), worker_image)
    jupyter = spark_jupyter.spark_jupyter_notebook_service(int(notebook_mem_limit), int(worker_mem_limit), notebook_image)

    app = {
        'name': name,
        'version': 2,
        'will_end': False,
        'priority': 512,
        'requires_binary': False,
        'services': [
                        sp_master,
                        sp_workers,
                        jupyter,
                    ]
    }
    return app


def create_app(app_name=APP_NAME, notebook_memory_limit=NOTEBOOK_MEMORY_LIMIT,
               spark_master_memory_limit=SPARK_MASTER_MEMORY_LIMIT, spark_worker_memory_limit=SPARK_WORKER_MEMORY_LIMIT,
               spark_worker_cores=SPARK_WORKER_CORES, spark_worker_count=SPARK_WORKER_COUNT,
               docker_registry=DOCKER_REGISTRY, spark_master_image=SPARK_MASTER_IMAGE,
               spark_worker_image=SPARK_WORKER_IMAGE, notebook_image=NOTEBOOK_IMAGE):
    if docker_registry is not None:
        spark_master_image = docker_registry + '/' + spark_master_image
        spark_worker_image = docker_registry + '/' + spark_worker_image
        notebook_image = docker_registry + '/' + notebook_image

    return spark_jupyter_notebook_ibm_app(app_name, notebook_memory_limit, spark_master_memory_limit,
                                          spark_worker_memory_limit, spark_worker_cores, spark_worker_count,
                                          spark_master_image, spark_worker_image, notebook_image)


if __name__ == "__main__":
    app_dict = create_app(app_name=APP_NAME, notebook_memory_limit=NOTEBOOK_MEMORY_LIMIT,
                          spark_master_memory_limit=SPARK_MASTER_MEMORY_LIMIT,
                          spark_worker_memory_limit=SPARK_WORKER_MEMORY_LIMIT,
                          spark_worker_cores=SPARK_WORKER_CORES, spark_worker_count=SPARK_WORKER_COUNT,
                          docker_registry=DOCKER_REGISTRY, spark_master_image=SPARK_MASTER_IMAGE,
                          spark_worker_image=SPARK_WORKER_IMAGE, notebook_image=NOTEBOOK_IMAGE)
    json.dump(app_dict, sys.stdout, sort_keys=True, indent=4)
    sys.stdout.write('\n')
