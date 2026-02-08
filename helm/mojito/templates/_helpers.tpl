{{/*
Expand the name of the chart.
*/}}
{{- define "mojito.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mojito.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mojito.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mojito.labels" -}}
helm.sh/chart: {{ include "mojito.chart" . }}
{{ include "mojito.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mojito.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mojito.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mojito.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mojito.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build Spring Application JSON environment variable
*/}}
{{- define "mojito.springApplicationJson" -}}
{
  "spring.flyway.enabled": {{ .Values.api.springApplication.flyway.enabled | quote }},
  "l10n.flyway.clean": "false",
  "spring.jpa.database-platform": {{ .Values.api.springApplication.jpa.databasePlatform | quote }},
  "spring.jpa.hibernate.ddl-auto": {{ .Values.api.springApplication.jpa.hibernateDdlAuto | quote }},
  "spring.jpa.defer-datasource-initialization": {{ .Values.api.springApplication.jpa.deferDatasourceInitialization | quote }},
  "spring.datasource.url": "jdbc:mysql://{{ include "mojito.fullname" . }}-mysql:{{ .Values.mysql.service.port }}/{{ .Values.mysql.auth.database }}?characterEncoding=UTF-8&useUnicode=true",
  "spring.datasource.username": {{ .Values.mysql.auth.username | quote }},
  "spring.datasource.password": {{ .Values.mysql.auth.password | quote }},
  "spring.datasource.driverClassName": {{ .Values.api.springApplication.datasource.driverClassName | quote }}
  {{- if .Values.api.quartz.enabled }}
  ,"l10n.org.quartz.scheduler.enabled": "false",
  "l10n.org.multi-quartz.enabled": "true",
  "l10n.org.multi-quartz.schedulers.default.quartz.jobStore.useProperties": "true",
  "l10n.org.multi-quartz.schedulers.default.quartz.scheduler.instanceId": {{ .Values.api.quartz.scheduler.instanceId | quote }},
  "l10n.org.multi-quartz.schedulers.default.quartz.jobStore.isClustered": {{ .Values.api.quartz.scheduler.clustered | quote }},
  "l10n.org.multi-quartz.schedulers.default.quartz.threadPool.threadCount": {{ .Values.api.quartz.scheduler.threadCount }}
  {{- end }}
}
{{- end }}
