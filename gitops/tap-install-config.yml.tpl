#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  #! Set Backstage catalogs to include by default.
  catalogs:
  - https://github.com/tanzu-corp/tap-catalog/blob/main/catalog-info.yaml

  registry:
    host: registry.tanzu.corp
    repositories:
      buildService: tanzu/tanzu-build-service
      ootbSupplyChain: tanzu/tanzu-supply-chain

  domains:
    main: apps.tanzu.corp
    tapGui: tap-gui.apps.tanzu.corp
    learningCenter: learningcenter.apps.tanzu.corp
    knative: apps.tanzu.corp
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tap-install-gitops
  namespace: tap-install-gitops
data:
  tap-config.yml: #@ yaml.encode(config())
