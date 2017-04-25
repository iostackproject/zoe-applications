# Spark worker image

This image contains the Scala worker process. It is used by Zoe, the Container Analytics as a
Service system to create on-demand Spark clusters in standalone mode.

Zoe can be found at: https://github.com/DistributedSystemsGroup/zoe

## Setup

The Dockerfile runs the worker process when run. The following options can be passed via environment variables:

* SPARK\_MASTER\_IP: IP address of the Spark master this notebook should use for its kernel
* SPARK\_WORKER\_RAM: How much RAM the worker can use (default is 4g)
* SPARK\_WORKER\_CORES: How many cores can be used by the worker process (default is 4)

