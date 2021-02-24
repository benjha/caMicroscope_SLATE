# caMicroscope on Slate

- caMicroscope

https://wolf.cci.emory.edu//camic_org/apps/landing/landing.html

- OLCF's SLATE

https://docs.olcf.ornl.gov/services_and_applications/slate/overview.html#what-is-slate

## Preliminaries

caMicroscope uses `docker-compose` to start its back-end and front-end services. Details about
caMicroscope deployment is available in the next link:

https://github.com/camicroscope/Distro

This repository includes the caMicroscope v3.8.4 deployment process in Slate, a k8s cluster.

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
From `mongo-stateful-s.yaml` note that  `ca-mongo` creates the database in `CA_MONGO_ROOT` that points to

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
`CA_MONGO_HOST` should be set to `172.25.165.159` which is the IP address of `ca-mongo-service`.

# IIPImage (ca-iip)

The Docker recipe from

https://github.com/benjha/iipImage/tree/v3.8.4_Slate

is used to build a Docker image of `ca-iip` on Slate using the next commmand:

```
oc new-build https://github.com/benjha/iipImage.git#v3.8.4_Slate
```

To create the `ca-iip` deployment use the next command:

```
oc create -f iip-deployment.yaml
```

From `iip-deployment.yaml` note log data from apache2 and iipsrv is stored in `CA_IIP_ROOT` that points to

```
/gpfs/alpine/gen150/proj-shared/caMicroscope/apache2
```

# SliderLoader (ca-load)

# Caracal (ca-back)

The Docker recipe from 

https://github.com/camicroscope/Caracal/blob/v3.8.4/Dockerfile

is used to build a Docker image of `ca-back` on Slate using the next command:

```
oc new-build https://github.com/camicroscope/caracal.git#v3.8.4 --build-arg "viewer=v3.8.4"
```

to verify that the caracal image is available on Slate type:

```
oc get imagestream
```

this is a sample of the output:

```
NAME           IMAGE REPOSITORY                                            TAGS              UPDATED
...
caracal        registry.apps.marble.ccs.ornl.gov/gen150-app/caracal                          
...
```

The `back-deployment.yaml` specification configures the ca-back deployment. Environment variables of the container
are based on those defined in:

https://github.com/camicroscope/Distro/blob/v3.8.4/caMicroscope.yml

note `DISABLE_SEC` and `ALLOW_PUBLIC` are set to `true` given that Slate provides authentification services. Also note
`MONGO_URI` is set to the IP address of `ca-mongo-service` and `IIP_PATH`  is set to the IP address of `ca-iip-service`.


