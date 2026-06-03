# Phase 4 - Open edX Deployment

## Goal

Deploy Open edX on the existing AWS EKS platform using Tutor.

## Existing Platform

- EKS cluster: openedx-eks-dev
- ingress-nginx installed
- RDS MySQL available
- Redis running in-cluster
- S3 bucket available
- EBS CSI installed
- Metrics Server installed

## Deployment Strategy

Use Tutor to generate and deploy Open edX Kubernetes workloads.

## Integration Targets

- MySQL: AWS RDS
- Redis: redis-master.redis.svc.cluster.local
- Object storage: S3 bucket
- Ingress: existing ingress-nginx
- Namespace: openedx

## Validation

- LMS reachable
- CMS reachable
- login works
- database persistence works
- Redis connectivity works
- S3 uploads/static/media work
- pods healthy
