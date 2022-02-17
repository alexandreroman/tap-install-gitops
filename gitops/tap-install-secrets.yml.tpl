#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  credentials:
    #! Pick one registry for downloading images: Tanzu Network or Pivotal Network
    #! (use tanzuNet as key).
    tanzuNet:
      username: INSERT-TANZUNET-USERNAME
      password: INSERT-TANZUNET-PASSWORD
    tanzuNet-pivnet:
      host: registry.pivotal.io
      username: INSERT-PIVNET-USERNAME
      password: INSERT-PIVNET-PASSWORD

    registry:
      username: INSERT-REGISTRY-USERNAME
      password: INSERT-REGISTRY-PASSWORD

    #! Remove suffix "-disabled" to enable GitHub integration:
    #! - set clientId and clientSecret to enable authentication,
    #! - set token to download resources from GitHub (such as Backstage catalogs).
    github-disabled:
      clientId: INSERT-GITHUB-CLIENTID
      clientSecret: INSERT-GITHUB-CLIENTSECRET
      token: INSERT-GITHUB-TOKEN

    #! Remove suffix "-disabled" to enable Backstage persistence.
    backstage-disabled:
      database:
        client: pg
        host: INSERT-DB-HOST
        port: 5432
        username: INSERT-DB-USERNAME
        password: INSERT-DB-PASSWORD
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: tap-install-gitops-github
  namespace: tap-install-gitops
stringData:
  username: github
  password: INSERT-GITHUB-TOKEN
---
apiVersion: v1
kind: Secret
metadata:
  name: tap-install-gitops
  namespace: tap-install-gitops
stringData:
  tap-secrets.yml: #@ yaml.encode(config())
