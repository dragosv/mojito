# README for Mojito Helm Chart

## Overview

This Helm chart deploys the Mojito localization platform on Kubernetes. It includes:
- MySQL database deployment
- Mojito API/WebApp service
- Kubernetes-native configurations (Services, Deployments, Ingress, HPA)
- Multiple environment-specific configurations

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Docker image registry access for Mojito images

## Installation

### Basic Installation (Development)

```bash
helm install mojito ./helm/mojito \
  -f ./helm/mojito/values-development.yaml
```

### Production Installation

```bash
helm install mojito ./helm/mojito \
  -f ./helm/mojito/values-production.yaml
```

### Custom Installation

```bash
helm install mojito ./helm/mojito \
  --values ./helm/mojito/values-production.yaml \
  --set mysql.auth.password=your-secure-password \
  --set api.image.tag=bk21
```

## Configuration

### Key Configuration Values

#### Global Settings
- `global.environment`: Environment name (development, staging, production)

#### MySQL Database
- `mysql.enabled`: Enable/disable MySQL deployment
- `mysql.auth.password`: Database password
- `mysql.persistence.enabled`: Enable persistent storage
- `mysql.persistence.size`: Storage size
- `mysql.resources`: CPU and memory requests/limits

#### API/WebApp
- `api.replicaCount`: Number of replicas
- `api.image.tag`: Docker image tag (bk8, bk11, bk16, bk17, bk21 for different Java versions)
- `api.service.type`: Service type (ClusterIP, LoadBalancer, NodePort)
- `api.resources`: CPU and memory requests/limits
- `api.autoscaling.enabled`: Enable horizontal pod autoscaling
- `api.debugMode`: Enable debug mode (port 5005)
- `api.javaOpts`: JVM options

#### Ingress
- `api.ingress.enabled`: Enable Ingress resource
- `api.ingress.className`: Ingress controller class
- `api.ingress.hosts`: Host and path configurations
- `api.ingress.tls`: TLS configuration

## Available Docker Images

The chart supports multiple Mojito Docker images based on Java versions:

- `bk8`: Java 8 (legacy)
- `bk11`: Java 11
- `bk16`: Java 16
- `bk17`: Java 17 (recommended)
- `bk21`: Java 21 (latest)

Specify the image tag in values:
```yaml
api:
  image:
    tag: bk21
```

## Scaling

### Horizontal Pod Autoscaling

Enable HPA in production:

```yaml
api:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
    targetCPUUtilizationPercentage: 70
```

Then install/upgrade:
```bash
helm upgrade mojito ./helm/mojito -f values-production.yaml
```

### Manual Scaling

```bash
kubectl scale deployment mojito-api --replicas=3
```

## Database Management

### Backup

```bash
kubectl exec -it <mysql-pod> -- mysqldump -u mojito -p mojito > backup.sql
```

### Restore

```bash
kubectl exec -it <mysql-pod> -- mysql -u mojito -p mojito < backup.sql
```

### Direct Database Access

```bash
kubectl port-forward svc/mojito-mysql 3306:3306
mysql -h localhost -u mojito -p
```

## Monitoring

### Check Deployment Status

```bash
kubectl get pods -l app.kubernetes.io/instance=mojito
kubectl get svc -l app.kubernetes.io/instance=mojito
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/instance=mojito,app.kubernetes.io/component=api
kubectl logs -l app.kubernetes.io/instance=mojito,app.kubernetes.io/component=database
```

### Port Forwarding

```bash
kubectl port-forward svc/mojito-api 8080:8080
# Access at http://localhost:8080
```

## Upgrades

### Upgrade to New Version

```bash
helm upgrade mojito ./helm/mojito -f values-production.yaml
```

### Rollback to Previous Version

```bash
helm rollback mojito
```

## Uninstall

```bash
helm uninstall mojito
```

## Clustering and High Availability

For distributed Mojito deployments with multiple API instances:

1. Enable distributed scheduler:
```yaml
api:
  quartz:
    enabled: true
    scheduler:
      clustered: true
      instanceId: "AUTO"
```

2. Ensure shared MySQL database is accessible from all pods
3. Scale API replicas:
```yaml
api:
  replicaCount: 3
```

## Security Considerations

### Production Recommendations

1. **Secrets Management**: Store passwords in Kubernetes Secrets or external secret management
   ```bash
   kubectl create secret generic mojito-db-secret \
     --from-literal=password=your-secure-password
   ```

2. **Network Policies**: Implement network policies to restrict traffic

3. **Pod Security Policies**: Apply appropriate security contexts

4. **RBAC**: Use proper service accounts and roles

5. **TLS/SSL**: Enable TLS for Ingress in production

### Example with External Secrets
```yaml
mysql:
  auth:
    password:
      valueFrom:
        secretKeyRef:
          name: external-secret
          key: db-password
```

## Troubleshooting

### Pod Fails to Start

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check if MySQL is ready
kubectl get pods -l app.kubernetes.io/component=database
```

### Database Connection Issues

```bash
# Verify MySQL service
kubectl get svc mojito-mysql

# Test connection from API pod
kubectl exec -it <api-pod> -- mysql -h mojito-mysql -u mojito -p
```

### Persistent Volume Issues

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

## Support

For issues and support, refer to:
- Mojito Documentation: https://github.com/box/mojito
- Kubernetes Documentation: https://kubernetes.io/docs/
- Helm Documentation: https://helm.sh/docs/
