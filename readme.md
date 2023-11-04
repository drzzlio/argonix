# ArgoNix

Integrating argo and nix.

Goals are to use argo's repo watching and  reconciliation loop as a CI/CD job
controller (in the k8s sense) and metadata API. Using argo as a lightweight
controller runtime is a thought that has fascinated me for a long time.

Nix's ability to define structured metadata, and drive the build and runtime,
will be leveraged for specifying the environment the jobs run in, what they
run, and which should be in the cluster based on metadata in the cluster _and_
the app repo.

## Configuration Management Plugin

A CMP is one way that argo provides for tapping into its resource-generation
pipeline. We can hijack the flow, and instead of generating resources from
something static, like a kustomization in the gitops repo, we can synthesize
these resources based on the current state of the jobs and the repo.

This CMP will be called for us, in the local synced repo source dir, when the
repo pointed to by the Application using it is changed. Discovery can make the
CMP connection implicit, perhaps it is automatically chosen for apps with a
`flake.nix`.
