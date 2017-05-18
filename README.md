Extends the official [osrm-backend](https://hub.docker.com/r/osrm/osrm-backend/) volume definition ready to run at cycle.io.

Running
-------

- run the docker container with:

Please have a look into the offical [documentation](https://hub.docker.com/r/osrm/osrm-backend/).

Persistence of configuration
----------------------------

For Open Source Routing Machine to preserve its configuration state across container shutdown and startup you should mount a volume at ```/data```.

Building
--------

```
make build
```

Get a shell in a running container
----------------------------------

```
make shell
```
