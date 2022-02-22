# Deploying Tanzu Application Platform with GitOps

_Still work in progress_

This project shows how to deploy
[Tanzu Application Platform](https://tanzu.vmware.com/application-platform) (TAP)
with a GitOps approach. Using this strategy, you can share the same configuration
across different installations
(one commit means one `tanzu package installed update` for every cluster),
while tracking any configuration updates with Git (easy rollbacks).

**Please note that this project is authored by a VMware employee under open source license terms.**

## How does it work?

You don't need to deploy any additional components to your cluster.
This GitOps approach relies on [kapp-controller](https://carvel.dev/kapp-controller/)
and [ytt](https://carvel.dev/ytt/) to track Git commits and apply the configuration
to every cluster. These tools are part of the TAP prerequisites.

## How to use it?

Make sure [Cluster Essentials for VMware Tanzu is deployed to your cluster](https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-general.html#install-cluster-essentials-for-vmware-tanzu-2).

You don't need to use the `tanzu` CLI to apply the configuration with a GitOps approach:
all `tanzu` commands described in the documentation have been integrated as YAML definitions.

Create new file `tap-install-config.yml` in `gitops`, reusing content from [`tap-install-config.yml.tpl`](gitops/tap-install-config.yml.tpl).
Edit this file accordingly:

```yaml
#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  #! Set Backstage catalogs to include by default.
  catalogs:
  - https://github.com/tanzu-corp/tap-catalog/blob/main/catalog-info.yaml

  registry:
    host: registry.tanzu4u.net
    repositories:
      buildService: tanzu/tanzu-build-service
      ootbSupplyChain: tanzu/tanzu-supply-chain

  domains:
    main: apps.tanzu4u.net
    tapGui: tap-gui.apps.tanzu4u.net
    learningCenter: learningcenter.apps.tanzu4u.net
    knative: apps.tanzu4u.net
#@ end
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tap-install-gitops
  namespace: tap-install-gitops
data:
  tap-config.yml: #@ yaml.encode(config())
```

Do the same with [`tap-install-secrets.yml.tpl`](gitops/tap-install-secrets.yml.tpl)
by creating `tap-install-secrets.yml`:

```yaml
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
```

Make sure these files are not publicly available (for obvious reasons!).

You are now ready to apply the GitOps configuration:

```shell
kapp deploy -a tap-install-gitops -f <(ytt -f gitops)
```

At this point, kapp-controller will monitor the Git repository: any updates
(commits) will be applied to your cluster, without having to run any commands.

Check that TAP is being deployed by running this command:

```shell
tanzu package installed list -n tap-install
```

Enjoy!

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2022 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
