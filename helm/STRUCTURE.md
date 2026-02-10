# Helm Chart for Mojito - Complete Structure

This directory contains a production-ready Helm chart for deploying the Mojito localization platform on Kubernetes.

## Directory Structure

```
helm/
├── README.md                          # Comprehensive documentation
├── QUICKSTART.md                      # Quick start guide
├── deploy.sh                          # Deployment automation script
├── uninstall.sh                       # Uninstall script
└── mojito/
    ├── Chart.yaml                     # Chart metadata
    ├── values.yaml                    # Default values
    ├── values-development.yaml        # Development environment values
    ├── values-production.yaml         # Production environment values
    ├── values-custom.yaml             # Template for custom values
    └── templates/
        ├── _helpers.tpl               # Helper template functions
        ├── NOTES.txt                  # Post-install notes
        ├── serviceaccount.yaml        # Kubernetes ServiceAccount
        ├── mysql-*.yaml               # MySQL templates (5 files)
        │   ├── mysql-configmap.yaml
        │   ├── mysql-secret.yaml
        │   ├── mysql-pvc.yaml
        │   ├── mysql-service.yaml
        │   └── mysql-deployment.yaml
        └── api-*.yaml                 # API/WebApp templates (4 files)
            ├── api-config.yaml
            ├── api-service.yaml
            ├── api-ingress.yaml
            ├── api-deployment.yaml
            └── api-hpa.yaml
```

## What's Included

### Database Layer
- **MySQL 8.0** deployment with:
  - Persistent volume support
  - Health checks
  - Resource limits
  - ConfigMap for MySQL configuration
  - Secret for credentials
  - Service for internal connectivity

### Application Layer
- **Mojito API/WebApp** deployment with:
  - Multiple Java version support (Java 8, 11, 16, 17, 21)
  - Horizontal Pod Autoscaling
  - Liveness and readiness probes
  - Service for internal connectivity
  - Ingress for external access
  - ConfigMap for Spring Boot configuration
  - Support for distributed scheduler (Quartz)

### Additional Resources
- ServiceAccount for RBAC
- ConfigMaps for configurations
- Secrets for sensitive data
- PersistentVolumeClaims for data persistence
- HorizontalPodAutoscaler for auto-scaling

## Quick Start

1. **Deploy to Development:**
   ```bash
   ./helm/deploy.sh development
   ```

2. **Deploy to Production:**
   ```bash
   ./helm/deploy.sh production
   ```

3. **Access Application:**
   ```bash
   kubectl port-forward svc/mojito-api 8080:8080
   ```

## Configuration Environments

### Development
- Java 17
- Single API replica
- No persistence (emptyDir)
- Debug mode enabled
- Auto-scaling disabled
- Minimal resources

### Production
- Java 21
- 2+ API replicas
- Persistent storage
- Debug mode disabled
- Auto-scaling enabled
- Production resource limits
- Distributed scheduler enabled
- TLS/Ingress configured
- Security context enabled

### Custom
- Template for creating environment-specific configurations
- Highly customizable for specific requirements

## Docker Images

The chart uses Mojito Docker images from the `docker/` folder:

- `bk8`: Java 8 (based on Dockerfile-bk8)
- `bk11`: Java 11 (based on Dockerfile-bk11)
- `bk16`: Java 16 (based on Dockerfile-bk16)
- `bk17`: Java 17 (based on Dockerfile-bk17, recommended)
- `bk21`: Java 21 (based on Dockerfile-bk21, latest)
- `cli-bk8`: CLI utility image

## Key Features

### Scalability
- Horizontal Pod Autoscaling (HPA) based on CPU and memory
- Configurable replica counts
- Load balancing with Kubernetes Services

### High Availability
- Multiple API replicas
- Distributed Quartz scheduler for job processing
- Shared MySQL database
- Health checks and probes

### Security
- Secrets management for credentials
- RBAC with ServiceAccount
- Pod security contexts
- Network isolation via Services

### Persistence
- MySQL data stored in PersistentVolume
- Configurable storage class and size
- Backup/restore capability

### Flexibility
- Environment-specific values files
- Custom configuration support
- Ingress for external access
- Support for different Kubernetes configurations

### Monitoring
- Health check endpoints
- Prometheus metrics support (via actuator)
- Structured logging
- Pod logs accessible via kubectl

## Dependencies

- Kubernetes 1.19+
- Helm 3.0+
- Storage provisioner (for persistent volumes)
- Ingress controller (nginx recommended, if ingress enabled)

## Usage Examples

```bash
# Install development
helm install mojito ./helm/mojito -f ./helm/mojito/values-development.yaml

# Install production
helm install mojito ./helm/mojito -f ./helm/mojito/values-production.yaml

# Upgrade with new image
helm upgrade mojito ./helm/mojito --set api.image.tag=bk21

# Scale replicas
helm upgrade mojito ./helm/mojito --set api.replicaCount=5

# Enable auto-scaling
helm upgrade mojito ./helm/mojito --set api.autoscaling.enabled=true

# Uninstall
helm uninstall mojito
```

## Documentation

- [README.md](./README.md) - Comprehensive guide
- [QUICKSTART.md](./QUICKSTART.md) - Quick start guide with common tasks
- [mojito/Chart.yaml](./mojito/Chart.yaml) - Chart metadata
- [mojito/values.yaml](./mojito/values.yaml) - Default configuration with comments

## Support & Contribution

For issues or improvements, refer to the Mojito project:
- GitHub: https://github.com/box/mojito
- Issues: https://github.com/box/mojito/issues

## Verification Commands

```bash
# Validate chart syntax
helm lint ./helm/mojito

# Test dry-run
helm install mojito ./helm/mojito --dry-run --debug

# Check generated manifests
helm template mojito ./helm/mojito

# Get deployed values
helm values mojito

# Check deployment status
helm status mojito

# View deployment history
helm history mojito
```

## Next Steps

1. Customize `values-production.yaml` for your environment
2. Build or obtain Mojito Docker images
3. Push images to your container registry
4. Update image repository in values if using private registry
5. Deploy using `./helm/deploy.sh production`
6. Configure monitoring and backups
7. Set up CI/CD integration
