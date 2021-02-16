# caMicroscope on Slate

- caMicroscope

https://wolf.cci.emory.edu//camic_org/apps/landing/landing.html

- OLCF's SLATE

https://docs.olcf.ornl.gov/services_and_applications/slate/overview.html#what-is-slate

## Preliminaries

caMicroscope uses `docker-compose` to start its back-end and front-end services. Details about
caMicroscope deployment is available in the next link.

https://github.com/camicroscope/Distro

This repository includes the caMicroscope deployment process in Slate, a k8s cluster.

The caMicroscope service naming conventions follows those denoted in the next docker-compose specification: 

https://github.com/camicroscope/Distro/blob/v3.8.4/caMicroscope.yml

Services' volumes are  mounted in 

```
/gpfs/alpine/proj-shared/gen150/caMicroscope 
``` 

Services: `mongodb`, `iipimage`, `SlideLoader`, `caracal`

- Login to Slate's Marble and activate GEN150-app subproject

```
oc login https://api.marble.ccs.ornl.gov
oc project gen150-app
```

# MongoDB

## ca-mongo

There are two caMicroscope services related to MongoDB, `ca-mongo` and `ca-idx`. `ca-mongo` hosts the database
and `ca-idx` initialize it. 

In terms of Slate, `ca-mongo` is an stateful set paired with a service so as to be accessible accross Slate nodes.
`ca-mongo` creates the database in

```
/gpfs/alpine/proj-shared/gen150/caMicroscope/mongodb
``` 

To create the `ca-mongo` service and stateful set use the next commands:

```
oc create -f mongo-service.yaml
oc create -f mongo-stateful-s.yaml
```

run `oc describe service ca-mongo-service` to get the IP address of the node that is running the pod of the stateful set:

```
Name:              ca-mongo-service
Namespace:         gen150-app
Labels:            app=ca-mongo
Annotations:       <none>
Selector:          app=ca-mongo
Type:              ClusterIP
IP:            --> 172.25.165.159 <---
Port:              ca-mongo-port-service  27017/TCP
TargetPort:        ca-mongo-port/TCP
Endpoints:         10.34.42.71:27017
Session Affinity:  None
Events:            <none>
```

in this case `172.25.165.159`, will be used when initializing the mongodb tables.

## ca-idx

`ca-idx` is a job that calls the configuration scripts available in

https://github.com/benjha/caMicroscope_SLATE/tree/main/Distro

These scripts where updated from caMicroscope's Distro repository to support Slate.

To create the `ca-idx` job use the next command:

```
oc create -f idx-job.yaml
```

From `idx-job.yaml` note `CA_MICROSCOPE_DISTRO_ROOT` and `CA_MONGO_HOST` environment variables. In particular,
`CA_MONGO_HOST` should be set to `172.25.165.159` which is the IP address of 'ca-mongo-service'.

# ca-back
