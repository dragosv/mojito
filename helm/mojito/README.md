# Mojito Helm chart

This chart deploys:

- `api` and `worker` deployments based on `docker/docker-compose-api-worker.yml`
- an `api` service (`ClusterIP` by default)
- optional MySQL Operator resources (`InnoDBCluster`) when `mysql.operator.enabled=true`

## Dependency

The chart declares the official MySQL Operator chart as a dependency in `Chart.yaml`.

## Usage

```bash
helm dependency update helm/mojito
helm upgrade --install mojito helm/mojito
```

## Important defaults

- API replicas: `1`
- Worker replicas: `2`
- Image: `mojito:latest`
- MySQL cluster name: `mojito-mysql`
- App DB user/password: `mojito` / `ChangeMe`

## Configure

Set overrides with `-f` values files or `--set`.

Common overrides:

```bash
--set image.repository=<your-registry>/mojito \
--set image.tag=<tag> \
--set mysql.auth.rootPassword=<root-password> \
--set mysql.auth.appPassword=<app-password>
```

Use an external MySQL service instead of creating an `InnoDBCluster`:

```bash
--set mysql.operator.enabled=false \
--set mysql.cluster.create=false \
--set mysql.host=<mysql-service-host>
```
