# Mojito Helm Chart - Quick Start Guide

## Deploy Mojito in 5 Minutes

### 1. Prerequisites

- Kubernetes cluster (1.19+)
- Helm installed (3.0+)
- kubectl configured to access your cluster
- Sufficient cluster resources (minimum 2GB RAM, 2 CPUs)

### 2. Quick Start - Development

```bash
# Make deployment script executable
chmod +x helm/deploy.sh

# Deploy to development environment
./helm/deploy.sh development default
```

### 3. Quick Start - Production

```bash
# Update passwords in production values
vim helm/mojito/values-production.yaml

# Deploy to production
./helm/deploy.sh production production
```

### 4. Access the Application

```bash
# Port forward to access locally
kubectl port-forward svc/mojito-api 8080:8080

# Open in browser
open http://localhost:8080
```

### 5. Verify Deployment

```bash
# Check all pods are running
kubectl get pods

# Check services
kubectl get svc

# View deployment logs
kubectl logs -l app.kubernetes.io/instance=mojito,app.kubernetes.io/component=api

# Get detailed deployment info
helm status mojito
helm values mojito
helm get manifest mojito
```

## Common Tasks

### Scale API Replicas

```bash
# Using Helm
helm upgrade mojito ./helm/mojito \
  --set api.replicaCount=3 \
  -f ./helm/mojito/values-production.yaml

# Or using kubectl directly
kubectl scale deployment/mojito-api --replicas=3
```

### Enable Auto-scaling

```bash
helm upgrade mojito ./helm/mojito \
  --set api.autoscaling.enabled=true \
  --set api.autoscaling.minReplicas=2 \
  --set api.autoscaling.maxReplicas=5 \
  -f ./helm/mojito/values-production.yaml
```

### Change Java Version

```bash
helm upgrade mojito ./helm/mojito \
  --set api.image.tag=bk21 \
  -f ./helm/mojito/values-production.yaml
```

### Enable Ingress

```bash
helm upgrade mojito ./helm/mojito \
  --set api.ingress.enabled=true \
  --set api.ingress.hosts[0].host=mojito.example.com \
  --set api.ingress.hosts[0].paths[0].path=/ \
  -f ./helm/mojito/values-production.yaml
```

### Access Database

```bash
# Connect to MySQL from host
kubectl port-forward svc/mojito-mysql 3306:3306
mysql -h localhost -u mojito -p

# Execute command in MySQL pod
kubectl exec -it <mysql-pod-name> -- mysql -u mojito -p
```

### View Application Logs

```bash
# API logs
kubectl logs -f deployment/mojito-api

# MySQL logs
kubectl logs -f deployment/mojito-mysql

# All logs
kubectl logs -f -l app.kubernetes.io/instance=mojito
```

### Backup Database

```bash
kubectl exec deployment/mojito-mysql -- mysqldump -u mojito -pChangeMe mojito > mojito-backup.sql
```

### Restore Database

```bash
kubectl exec -i deployment/mojito-mysql -- mysql -u mojito -pChangeMe mojito < mojito-backup.sql
```

## Environment-Specific Deployments

### Development with Debug Mode

```bash
helm install mojito ./helm/mojito \
  -f ./helm/mojito/values-development.yaml \
  --set api.debugMode=true \
  --set api.image.tag=bk17
```

### Staging with Auto-scaling

```bash
helm install mojito ./helm/mojito \
  -f ./helm/mojito/values-production.yaml \
  --set api.replicaCount=2 \
  --set api.autoscaling.enabled=true \
  --set api.autoscaling.minReplicas=2 \
  --set api.autoscaling.maxReplicas=4
```

### Production with TLS

```bash
helm install mojito ./helm/mojito \
  -f ./helm/mojito/values-production.yaml \
  --set api.ingress.enabled=true \
  --set api.ingress.hosts[0].host=mojito.company.com \
  --set api.ingress.tls[0].secretName=mojito-tls \
  --set api.ingress.tls[0].hosts[0]=mojito.company.com
```

## Troubleshooting

### Pod stuck in Pending

```bash
# Check pod events
kubectl describe pod <pod-name>

# Check resource availability
kubectl top nodes
kubectl describe nodes
```

### Database connection failed

```bash
# Verify MySQL is running
kubectl get pods -l app.kubernetes.io/component=database

# Check MySQL logs
kubectl logs -l app.kubernetes.io/component=database

# Test connection
kubectl exec deployment/mojito-api -- nc -zv mojito-mysql 3306
```

### Application fails to start

```bash
# Check logs
kubectl logs deployment/mojito-api

# Describe pod
kubectl describe pod <api-pod-name>

# Check if database is initialized
kubectl logs deployment/mojito-mysql
```

## Cleanup

```bash
# Delete specific release
./helm/uninstall.sh mojito default

# Delete all Mojito resources in a namespace
kubectl delete all -l app.kubernetes.io/instance=mojito

# Delete PersistentVolumeClaims (caution!)
kubectl delete pvc -l app.kubernetes.io/instance=mojito
```

## Next Steps

- Read the full README: `helm/README.md`
- Customize values: Edit `helm/mojito/values.yaml`
- Set up monitoring: Configure Prometheus/Grafana
- Enable CI/CD: Configure GitOps with ArgoCD
- Configure backup: Set up automated database backups
- Security: Implement network policies and pod security policies
