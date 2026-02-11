{{- define "mojito.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mojito.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "mojito.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mojito.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "mojito.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "mojito.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mojito.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "mojito.mysqlHost" -}}
{{- if .Values.mysql.host -}}
{{- .Values.mysql.host -}}
{{- else -}}
{{- .Values.mysql.cluster.name -}}
{{- end -}}
{{- end -}}

{{- define "mojito.datasourceUrl" -}}
{{- printf "jdbc:mysql://%s:%v/%s?characterEncoding=UTF-8&useUnicode=true" (include "mojito.mysqlHost" .) .Values.mysql.database.port .Values.mysql.database.name -}}
{{- end -}}

{{- define "mojito.springJson" -}}
{{- $root := index . "root" -}}
{{- $component := index . "component" -}}
{{- $shared := deepCopy $root.Values.springApplicationJson.shared -}}
{{- $componentMap := (index $root.Values.springApplicationJson $component) | default dict -}}
{{- $config := mergeOverwrite $shared $componentMap -}}
{{- $_ := set $config "spring.datasource.url" (include "mojito.datasourceUrl" $root) -}}
{{- $_ := set $config "spring.datasource.username" $root.Values.mysql.auth.appUser -}}
{{- $_ := set $config "spring.datasource.password" $root.Values.mysql.auth.appPassword -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.default.quartz.dataSource.myDS.URL" (include "mojito.datasourceUrl" $root) -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.default.quartz.dataSource.myDS.user" $root.Values.mysql.auth.appUser -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.default.quartz.dataSource.myDS.password" $root.Values.mysql.auth.appPassword -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.lowPriority.quartz.dataSource.myDS.URL" (include "mojito.datasourceUrl" $root) -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.lowPriority.quartz.dataSource.myDS.user" $root.Values.mysql.auth.appUser -}}
{{- $_ := set $config "l10n.org.multi-quartz.schedulers.lowPriority.quartz.dataSource.myDS.password" $root.Values.mysql.auth.appPassword -}}
{{- toJson $config -}}
{{- end -}}
