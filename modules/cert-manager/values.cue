// Code generated by timoni.
// Note that this file must have no imports and all values must be concrete.

@if(!debug)

package main

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Defaults
values: {
	metadata: labels: team: "dev"
	installCRDs: true
	config: logging: format:  "json"
	resources: requests: cpu: "100m"
	ingressShim: defaultIssuerName: "dev"

	webhook: {
		networkPolicy: {
			enabled: true
			spec: {
				ingress: [
					{
						from: [
							{
								ipBlock: cidr: "0.0.0.0/0"
							},
						]
					},
				]
				egress: [
					{
						ports: [
							{
								port:     80
								protocol: "TCP"
							},
							{
								port:     443
								protocol: "TCP"
							},
							{
								port:     53
								protocol: "TCP"
							},
							{
								port:     53
								protocol: "UDP"
							},
							{
								port:     6443
								protocol: "TCP"
							},
						]
						to: [
							{
								ipBlock: cidr: "0.0.0.0/0"
							},
						]
					},
				]
			}
		}
	}

	// Test Job
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}
