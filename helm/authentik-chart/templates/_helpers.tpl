{{/*
Expand the name of the chart.
*/}}
{{- define "authentik-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "authentik-chart.fullname" -}}
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
{{- define "authentik-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "authentik-chart.labels" -}}
helm.sh/chart: {{ include "authentik-chart.chart" . }}
{{ include "authentik-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "authentik-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "authentik-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "authentik-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authentik-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL fullname
*/}}
{{- define "authentik-chart.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "authentik-chart.fullname" .) }}
{{- end }}

{{/*
Redis fullname
*/}}
{{- define "authentik-chart.redis.fullname" -}}
{{- printf "%s-redis" (include "authentik-chart.fullname" .) }}
{{- end }}

{{/*
Server fullname
*/}}
{{- define "authentik-chart.server.fullname" -}}
{{- printf "%s-server" (include "authentik-chart.fullname" .) }}
{{- end }}

{{/*
Worker fullname
*/}}
{{- define "authentik-chart.worker.fullname" -}}
{{- printf "%s-worker" (include "authentik-chart.fullname" .) }}
{{- end }}