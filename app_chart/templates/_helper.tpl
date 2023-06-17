{{- define "labels" -}}
{{- range $key, $value := .Values.deploy.matchlabels}}
    {{ $key }}: {{ $value }}
{{- end}}
{{- end}}
