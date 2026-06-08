from tutor import hooks

hooks.Filters.ENV_PATCHES.add_item(
    (
        "k8s-override",
        """
apiVersion: v1
kind: Service
metadata:
  name: caddy
spec:
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cms
spec:
  template:
    spec:
      containers:
      - name: cms
        resources:
          requests:
            memory: 512Mi
          limits:
            memory: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lms
spec:
  template:
    spec:
      containers:
      - name: lms
        resources:
          requests:
            memory: 512Mi
          limits:
            memory: 1Gi
"""
    )
)

hooks.Filters.ENV_PATCHES.add_item(
    (
        "k8s-services",
        """
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: openedx-web
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
spec:
  ingressClassName: nginx
  rules:
  - host: {{ LMS_HOST }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: caddy
            port:
              number: 80
  - host: {{ CMS_HOST }}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: caddy
            port:
              number: 80
"""
    )
)
