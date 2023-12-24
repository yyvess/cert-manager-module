package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ControllerDeploymentSpec: appsv1.#DeploymentSpec & {
	_main_config:            #Config
	_deployment_component:   string
	_deployment_strategy:    appsv1.#DeploymentStrategy
	_deployment_prometheus?: #Prometheus
	_meta:                   timoniv1.#MetaComponent & {
		#Meta:      _main_config.metadata
		#Component: _deployment_component
	}

	replicas: _main_config.controller.replicas
	selector: matchLabels: _meta.#LabelSelector

	if _deployment_strategy != _|_ {
		strategy: _deployment_strategy
	}

	template: corev1.#PodTemplateSpec & {
		metadata: labels: _meta.#LabelSelector

		if _main_config.controller.podLabels != _|_ {
			metadata: labels: _main_config.controller.podLabels
		}

		if _main_config.controller.podAnnotations != _|_ {
			metadata: annotations: _main_config.controller.podAnnotations
		}

		if _deployment_prometheus != _|_ && _deployment_prometheus.serviceMonitor == _|_ {
			metadata: annotations: "prometheus.io/path":   "/metrics"
			metadata: annotations: "prometheus.io/scrape": "true"
			metadata: annotations: "prometheus.io/port":   "9402"
		}

		spec: corev1.#PodSpec & {
			if _main_config.controller.serviceAccount != _|_ {
				serviceAccountName: _main_config.controller.serviceAccount.name
			}

			if _main_config.controller.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: _main_config.controller.automountServiceAccountToken
			}

			if _main_config.controller.enableServiceLinks != _|_ {
				enableServiceLinks: _main_config.controller.enableServiceLinks
			}

			if _main_config.priorityClass != _|_ {
				priorityClassName: _main_config.priorityClass
			}

			if _main_config.controller.securityContext != _|_ {
				securityContext: _main_config.controller.securityContext
			}

			if _main_config.controller.volumes != _|_ {
				volumes: _main_config.controller.volumes
			}

			if _main_config.controller.config != _|_ {
				volumes: [
					{
						name: "config"
						configMap: name: _meta.name
					},
				]
			}

			containers: [...corev1.#Container] & [
					{
					name: _meta.name

					image:           _main_config.controller.image.reference
					imagePullPolicy: _main_config.controller.imagePullPolicy

					if _main_config.controller.containerSecurityContext != _|_ {
						securityContext: _main_config.controller.containerSecurityContext
					}

					if _main_config.controller.volumeMounts != _|_ || _main_config.controller.config != _|_ {
						volumeMounts: [
							if _main_config.controller.config != _|_ {
								name:      "config"
								mountPath: "/var/cert-manager/config"
							},
							if _main_config.controller.volumeMounts != _|_ {
								_main_config.controller.volumeMounts
							},
						]
					}

					ports: [{
						containerPort: 9402
						name:          "http-metrics"
						protocol:      "TCP"
					}, {
						containerPort: 9403
						name:          "http-healthz"
						protocol:      "TCP"
					}]

					args: [...string]
					args: _main_config.controller.extraArgs
					args: [
						"--v=\(_main_config.logLevel)",

						if _main_config.controller.config != _|_ {
							"--config=/var/cert-manager/config/config.yaml"
						},

						if _main_config.controller.clusterResourceNamespace != _|_ {
							"--cluster-resource-namespace=\(_main_config.controller.clusterResourceNamespace)"
						},

						if _main_config.controller.clusterResourceNamespace == _|_ {
							"--cluster-resource-namespace=$(POD_NAMESPACE)"
						},

						"--leader-election-namespace=\(_main_config.leaderElection.namespace)",

						if _main_config.leaderElection.leaseDuration != _|_ {
							"--leader-election-lease-duration=\(_main_config.leaderElection.leaseDuration)"
						},

						if _main_config.leaderElection.renewDeadline != _|_ {
							"--leader-election-renew-deadline=\(_main_config.leaderElection.renewDeadline)"
						},

						if _main_config.leaderElection.retryPeriod != _|_ {
							"--leader-election-retry-period=\(_main_config.leaderElection.retryPeriod)"
						},

						"--acme-http01-solver-image=\(_main_config.acmeSolver.image.reference)",

						if _main_config.controller.ingressShim.defaultIssuerName != _|_ {
							"--default-issuer-name=\(_main_config.leaderElection.defaultIssuerName)"
						},

						if _main_config.controller.ingressShim.defaultIssuerKind != _|_ {
							"--default-issuer-kind=\(_main_config.leaderElection.defaultIssuerKind)"
						},

						if _main_config.controller.ingressShim.defaultIssuerGroup != _|_ {
							"--default-issuer-group=\(_main_config.leaderElection.defaultIssuerGroup)"
						},

						if _main_config.controller.featureGates != _|_ {
							"--feature-gates=\(_main_config.controller.featureGates)"
						},

						if _main_config.controller.maxConcurrentChallenges != _|_ {
							"--max-concurrent-challenges=\(_main_config.controller.maxConcurrentChallenges)"
						},

						if _main_config.controller.enableCertificateOwnerRef != _|_ {
							"--enable-certificate-owner-ref=true"
						},

						if _main_config.controller.dns01RecursiveNameserversOnly != _|_ {
							"--dns01-recursive-nameservers-only=true"
						},

						if _main_config.controller.dns01RecursiveNameservers != _|_ {
							"--dns01-recursive-nameservers=\(_main_config.controller.dns01RecursiveNameservers)"
						},
					]

					env: [...corev1.#EnvVar]
					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},
					]
					env: _main_config.controller.extraEnv

					if _main_config.controller.proxy != _|_ {
						env: [
							if _main_config.controller.proxy.httpProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: _main_config.controller.proxy.httpProxy
								}
							},
							if _main_config.controller.proxy.httpsProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: _main_config.controller.proxy.httpsProxy
								}
							},
							if _main_config.controller.proxy.noProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: _main_config.controller.proxy.noProxy
								}
							},
						]
					}

					if _main_config.controller.resources != _|_ {
						resources: _main_config.controller.resources
					}

					if _main_config.controller.livenessProbe != _|_ {
						livenessProbe: _main_config.controller.livenessProbe & {
							httpGet: {
								port:   "http-healthz"
								path:   "/livez"
								scheme: "HTTP"
							}
							initialDelaySeconds: *10 | int
							periodSeconds:       *10 | int
							timeoutSeconds:      *15 | int
							successThreshold:    *1 | int
							failureThreshold:    *8 | int
						}
					}
				},
			]

			if _main_config.controller.nodeSelector != _|_ {
				nodeSelector: _main_config.controller.nodeSelector
			}

			if _main_config.controller.affinity != _|_ {
				affinity: _main_config.controller.affinity
			}

			if _main_config.controller.tolerations != _|_ {
				tolerations: _main_config.controller.tolerations
			}

			if _main_config.controller.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: _main_config.controller.topologySpreadConstraints
			}

			if _main_config.controller.podDNSPolicy != _|_ {
				dnsPolicy: _main_config.controller.podDNSPolicy
			}

			if _main_config.controller.podDNSConfig != _|_ {
				dnsConfig: _main_config.controller.podDNSConfig
			}
		}
	}
}
