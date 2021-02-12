# caMicroscope on SLATE

- caMicroscope

https://wolf.cci.emory.edu//camic_org/apps/landing/landing.html

- OLCF's SLATE

https://docs.olcf.ornl.gov/services_and_applications/slate/overview.html#what-is-slate

## Preliminaries

caMicroscope uses docker-compose to start its back-end and front-end services. Details about
caMicroscope deployment is available in the next link.

https://github.com/camicroscope/Distro

This repository includes the caMicroscope deployment process in SLATE, a k8s cluster.

The caMicroscope service naming conventions follows those denoted in the next docker-compose specification: 

https://github.com/camicroscope/Distro/blob/v3.8.4/caMicroscope.yml

Services' volumes are  mounted in 

```
/gpfs/alpine/proj-shared/gen150/caMicroscope 
``` 
