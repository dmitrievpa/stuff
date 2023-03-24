#!/bin/bash
set -xe
pull_update() {
    echo "Pull and update $1 container"
    docker-compose --context remote -f ./sausage-store.yaml pull --ignore-pull-failures backend-$1
    docker-compose --context remote --env-file ./sausage-store.env -f ./sausage-store.yaml up --force-recreate -d backend-$1
}

check_healthy() {
    for timeout in 1 2 3 4 5 6
    do
        healthy=$(docker --context=remote container ls --filter health=healthy --format  {{.Names}} | grep $1)
        if [ $healthy ]
        then
            return 0
        fi
        sleep 10
    done
    return 1
}

container_blue=$(docker --context=remote container ls --filter health=healthy --format  {{.Names}} | grep blue)
container_green=$(docker --context=remote container ls --filter health=healthy --format  {{.Names}} | grep green)

if [ $container_blue ]
then
    healthy_blue=true
else
    healthy_blue=false
fi

if [ $container_green ]
then
    healthy_green=true
else
    healthy_green=false
fi

if $healthy_blue
then
    pull_update green
    if check_healthy green
    then
        pull_update blue
        if ! check_healthy blue; then echo "The blue one never came to life"; fi
    else
        echo "The green one never came to life"
    fi
elif $healthy_green
then
    pull_update blue
    if check_healthy blue
    then
        pull_update green
        if ! check_healthy green; then echo "The green one never came to life"; fi
    else
        echo "The blue one never came to life"
    fi
else
    echo "WTF all containers is down!"
fi
