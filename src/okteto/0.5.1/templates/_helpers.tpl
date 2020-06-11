{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "okteto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "okteto.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "okteto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The default public URL of the web app
*/}}
{{- define "okteto.defaultpublic" -}}
{{- $subdomain := required "A valid .Values.subdomain is required" .Values.subdomain }}
{{- printf "%s.%s" "okteto" $subdomain }}
{{- end -}}

{{/*
Allow for overriding the public URL of the application, it defaults to okteto.SUBDOMAINS
*/}}
{{- define "okteto.public" -}}
{{- $name := include "okteto.defaultpublic" . }}
{{- default $name .Values.publicOverride -}}
{{- end -}}

{{/*
Returns the wildcard domain form
*/}}
{{- define "okteto.wildcard" -}}
{{- printf "*.%s" .Values.subdomain -}}
{{- end -}}

{{/*
Returns the name of the mutation webhook
*/}}
{{- define "okteto.webhook" -}}
{{- $name := include "okteto.fullname" . }}
{{- printf "%s-mutation-webhook" $name -}}
{{- end -}}

{{/*
Returns the name of the dev cluster role
*/}}
{{- define "okteto.devclusterrole" -}}
{{- $name := include "okteto.fullname" . }}
{{- printf "%s-psp" $name -}}
{{- end -}}

{{- define "okteto.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "okteto.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
The default public URL of buildkit
*/}}
{{- define "okteto.buildkit" -}}
{{- printf "%s.%s" "buildkit" .Values.subdomain }}
{{- end -}}

{{- define "okteto.registry" -}}
{{- printf "%s.%s" "registry" .Values.subdomain }}
{{- end -}}

{{/*
  Returns true if a solver is configured
*/}}
{{- define "okteto.solverAvailable" -}}
{{- if not .Values.cloud.enabled }}
{{- print false }}
{{- end -}}

{{- if .Values.cloud.provider.aws.enabled }}
{{- print true }}
{{- else if .Values.cloud.provider.gcp.enabled }}
{{- print true }}
{{- else if .Values.cloud.provider.digitalocean.enabled }}
{{- print true }}
{{- else if .Values.cloud.provider.byo.enabled }}
{{- print true }}
{{- else }}
{{- print false }}
{{- end -}}
{{- end -}}

{{- define "okteto.selfSignedIssuer" -}}
{{ printf "%s-selfsign" (include "okteto.fullname" .) }}
{{- end -}}

{{- define "okteto.rootCAIssuer" -}}
{{ printf "%s-ca" (include "okteto.fullname" .) }}
{{- end -}}

{{- define "okteto.rootCACertificate" -}}
{{ printf "%s-ca" (include "okteto.fullname" .) }}
{{- end -}}

{{- define "okteto.internalCertificate" -}}
{{ printf "%s-internal-tls" (include "okteto.fullname" .) }}
{{- end -}}