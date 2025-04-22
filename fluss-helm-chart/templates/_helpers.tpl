{{/*
Expand the name of the chart.
*/}}
{{- define "fluss.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fluss.fullname" -}}
{{- if .Values.global.fullnameOverride }}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.global.nameOverride }}
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
{{- define "fluss.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fluss.labels" -}}
helm.sh/chart: {{ include "fluss.chart" . }}
{{ include "fluss.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (Aligning with plan's simpler labels)
*/}}
{{- define "fluss.selectorLabels" -}}
app: {{ include "fluss.name" . }}
# component: <set in specific template>
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fluss.serviceAccountName" -}}
{{- if .Values.global.serviceAccount.create }}
{{- default (include "fluss.fullname" .) .Values.global.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.global.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Helper for ZooKeeper servers string (if needed, currently using direct env in values)
*/}}
# {{- define "fluss.zookeeperServers" -}}
# {{- $zkFullName := printf "%s-zookeeper" (include "fluss.fullname" .) -}}
# {{- $zkPort := .Values.zookeeper.service.port | default 2181 -}}
# {{- range $i, $e := until (.Values.zookeeper.replicaCount | int) -}}
# {{- printf "%s-%d.%s:%d" $zkFullName $i $zkFullName $zkPort -}}
# {{- if ne $i (sub (.Values.zookeeper.replicaCount | int) 1) -}},{{- end -}}
# {{- end -}}
# {{- end }}

{{/*
Helper for MinIO endpoint (if needed, currently using direct env in templates)
*/}}
# {{- define "fluss.minioEndpoint" -}}
# {{- printf "http://%s-minio:%d" (include "fluss.fullname" .) (.Values.minio.service.port | default 9000) -}}
# {{- end }} 