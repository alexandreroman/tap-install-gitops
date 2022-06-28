# Deploying Tanzu Application Platform with GitOps

This project shows how to deploy
[Tanzu Application Platform](https://tanzu.vmware.com/application-platform) (TAP)
with a GitOps approach. Using this strategy, you can share the same configuration
across different installations
(one commit means one `tanzu package installed update` for every cluster),
while tracking any configuration updates with Git (easy rollbacks).

**Please note that this project is authored by a VMware employee under open source license terms.**

## How does it work?

This GitOps approach relies solely on [kapp-controller](https://carvel.dev/kapp-controller/)
and [ytt](https://carvel.dev/ytt/) to track Git commits and apply the configuration
to every cluster. These tools are part of the TAP prerequisites.

## How to use it?
### Setup
1. Make sure [Cluster Essentials for VMware Tanzu is deployed to your cluster](https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-general.html#install-cluster-essentials-for-vmware-tanzu-2).

1. Create new file `tap-install-config.yml` in `gitops`, reusing content from [`tap-install-config.yml.tpl`](gitops/tap-install-config.yml.tpl).
Edit this file accordingly:

1. Do the same with [`tap-install-secrets.yml.tpl`](gitops/tap-install-secrets.yml.tpl)
by creating `tap-install-secrets.yml`:
    - NOTE: This file is in the `.gitignore`. You'll want to make sure it's not committed (for the obvious reasons)

1. (OPTIONAL) Update the `tap-install.yml` with your repository if you've forked the project. Ultimately this is the "single" file that will be causing the declarative loop to occur.

1. (OPTIONAL) If you're updating any of the values of the TAP install, ala the TAP version or the like, you'll want to commit them to your git repo.

1. (OPTIONAL) Remove any of the additional packages from the app in [`tap-install.yml`](gitops/tap-install.yml) should you not want them deployed. (ex. `additional/external-dns`)

### Deploy 
You are now ready to apply the GitOps configuration:

```shell
kapp deploy -a tap-install-gitops -f <(ytt -f gitops)
```

At this point, kapp-controller will monitor the Git repository: any updates
(commits) will be applied to your cluster, without having to run any commands.

Check that TAP is being deployed by running either command below:

```shell
tanzu package installed list -n tap-install

# OR

kctrl package installed list -n tap-install
```

Enjoy!

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2022 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
