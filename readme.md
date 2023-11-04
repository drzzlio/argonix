# ArgoNix

Integrating argo and nix.

Goals are to use argo's repo watching and  reconciliation loop as a CI/CD job
controller (in the k8s sense) and metadata API. Using argo as a lightweight
controller runtime is a thought that has fascinated me for a long time.

Nix's ability to define structured metadata, and drive the build and runtime,
will be leveraged for specifying the environment the jobs run in, what they
run, and which should be in the cluster based on metadata in the cluster _and_
the app repo.
