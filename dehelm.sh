#!/bin/bash
set -e

helm template "$1" "$2" > helm.yaml

function clean(){
    grep -vi "$1" helm.yaml > intermediate.yaml
    mv intermediate.yaml helm.yaml
}

function patch(){
    echo "resources:" > kustomization.yaml
    for n in base/*
    do
        printf '\055 %s\n' "$n" >> kustomization.yaml
    done

    echo "" >> kustomization.yaml

    echo "patchesStrategicMerge:" >> kustomization.yaml
    for n in patches/*
    do
        printf '\055 %s\n' "$n" >> kustomization.yaml
    done
}

clean helm
clean "namespace: default"
clean "# Source:"
clean "chart:"

# go get -v github.com/mogensen/kubernetes-split-yaml
kubernetes-split-yaml --outdir 'base' helm.yaml
find ./base -name "*-persistentvolumeclaim.yaml" -delete

patch
rm helm.yaml