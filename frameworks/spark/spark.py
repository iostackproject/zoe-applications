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


def spark_master_service(mem_limit, image):
    """
    :type mem_limit: int
    :type image: str
    :rtype: dict
    """
    service = {
        'name': "spark-master",
        'docker_image': image,
        'monitor': False,
        'required_resources': {"memory": mem_limit},
        'ports': [
            {
                'name': "Spark master web interface",
                'protocol': "http",
                'port_number': 8080,
                'path': "/",
                'is_main_endpoint': False
            }
        ],
        'environment': [
            ["SPARK_MASTER_IP", "spark-master-0-{execution_name}-{user_name}-{deployment_name}-zoe.{user_name}-{deployment_name}-zoe"],
            ["HADOOP_USER_NAME", "{user_name}"]
        ],
        'networks': [],
        'total_count': 1,
        'essential_count': 1,
        'startup_order': 0
    }
    return service


def spark_worker_service(count, mem_limit, cores, image):
    """
    :type count: int
    :type mem_limit: int
    :type cores: int
    :type image: str
    :rtype List(dict)

    :param count: number of workers
    :param mem_limit: hard memory limit for workers
    :param cores: number of cores this worker should use
    :param image: name of the Docker image
    :return: a list of service entries
    """
    worker_ram = mem_limit - (1024 ** 3) - (512 * 1025 ** 2)
    service = {
        'name': "spark-worker",
        'docker_image': image,
        'monitor': False,
        'required_resources': {"memory": mem_limit},
        'ports': [
            {
                'name': "Spark worker web interface",
                'protocol': "http",
                'port_number': 8081,
                'path': "/",
                'is_main_endpoint': False
            }
        ],
        'environment': [
            ["SPARK_WORKER_CORES", str(cores)],
            ["SPARK_WORKER_RAM", str(worker_ram)],
            ["SPARK_MASTER_IP", "spark-master-0-{execution_name}-{user_name}-{deployment_name}-zoe.{user_name}-{deployment_name}-zoe"],
            ["SPARK_LOCAL_IP", "spark-worker-{index}-{execution_name}-{user_name}-{deployment_name}-zoe.{user_name}-{deployment_name}-zoe"],
            ["HADOOP_USER_NAME", "{user_name}"]
        ],
        'networks': [],
        'total_count': count,
        'essential_count': 1,
        'startup_order': 1
    }
    return service


def spark_submit_service(mem_limit, worker_mem_limit, image, command):
    """
    :type mem_limit: int
    :type worker_mem_limit: int
    :type image: str
    :type command: str
    :rtype: dict
    """
    executor_ram = worker_mem_limit - (2 * 1024 ** 3)
    service = {
        'name': "spark-submit",
        'docker_image': image,
        'monitor': True,
        'required_resources': {"memory": mem_limit},
        'ports': [
            {
                'name': "Spark application web interface",
                'protocol': "http",
                'port_number': 4040,
                'path': "/",
                'is_main_endpoint': False
            }
        ],
        'environment': [
            ["SPARK_MASTER_IP", "spark-master-0-{execution_name}-{user_name}-{deployment_name}-zoe.{user_name}-{deployment_name}-zoe"],
            ["SPARK_EXECUTOR_RAM", str(executor_ram)],
            ["HADOOP_USER_NAME", "{user_name}"]
        ],
        'command': command,
        'total_count': 1,
        'essential_count': 1,
        'startup_order': 2
    }
    return service
