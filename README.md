## Description

A tool to select or unselect some resources from a set of `k8s` manifests (e.g, from `helm template` output).
The tool is useful for quick debugging and patching.

This is the new and the official repository for the small script https://gist.github.com/icy/228d7ce15b6c1fc66994a490608e6c7c . 
The script is written now in Ruby, and it needs some better documentation, e2e tests and some ehancements. 

## Examples

### external-dns without secret

```
helm template \
  -n external-dns \
  dwh \
  --set txtOwnerId=example.net \
  --set provider=aws \
  --set aws.zoneType=public \
  --set domainFilters[0]=example.net \
  --set annotationFilter="external-dns/primary notin (excluded)" \
  --set aws.credentials.accessKey="dummy" \
  --set aws.credentials.secretKey="dummy" \
  oci://registry-1.docker.io/bitnamicharts/external-dns \
| k8s-select 'kind!=^Secret$'
```

## Version 1.0

https://gist.github.com/icy/228d7ce15b6c1fc66994a490608e6c7c
