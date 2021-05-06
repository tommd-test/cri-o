#!/usr/bin/env bats

load helpers

ROOT="$TESTDIR/crio"
RUNROOT="$TESTDIR/crio-run"
KPOD_OPTIONS="--root $ROOT --runroot $RUNROOT ${STORAGE_OPTS} --runtime $RUNTIME_BINARY"
function teardown() {
    cleanup_test
}

function start_sleep_container () {
    pod_id=$(crioctl pod run --config "$TESTDATA"/sandbox_config.json)
    ctr_id=$(crioctl ctr create --config "$TESTDATA"/container_config_sleep.json --pod "$pod_id")
    crioctl ctr start --id "$ctr_id"
}

@test "kill a bogus container" {
    run ${KPOD_BINARY} ${KPOD_OPTIONS} kill foobar
    echo "$output"
    [ "$status" -ne 0 ]
}

@test "kill a running container by id" {
    start_crio
    ${KPOD_BINARY} ${KPOD_OPTIONS} pull docker.io/library/busybox:latest
    ctr_id=$( start_sleep_container )
    crioctl ctr status --id "$ctr_id"
    ${KPOD_BINARY} ${KPOD_OPTIONS} ps -a
    ${KPOD_BINARY} ${KPOD_OPTIONS} logs "$ctr_id"
    crioctl ctr status --id "$ctr_id"
    run ${KPOD_BINARY} ${KPOD_OPTIONS} kill "$ctr_id"
    echo "$output"
    [ "$status" -eq 0 ]
    cleanup_ctrs
    cleanup_pods
    stop_crio
}

@test "kill a running container by id with TERM" {
    start_crio
    ${KPOD_BINARY} ${KPOD_OPTIONS} pull docker.io/library/busybox:latest
    ctr_id=$( start_sleep_container )
    crioctl ctr status --id "$ctr_id"
    ${KPOD_BINARY} ${KPOD_OPTIONS} ps -a
    ${KPOD_BINARY} ${KPOD_OPTIONS} logs "$ctr_id"
    crioctl ctr status --id "$ctr_id"
    run ${KPOD_BINARY} ${KPOD_OPTIONS} kill -s TERM "$ctr_id"
    echo "$output"
    [ "$status" -eq 0 ]
    cleanup_ctrs
    cleanup_pods
    stop_crio
}

@test "kill a running container by name" {
    start_crio
    ${KPOD_BINARY} ${KPOD_OPTIONS} pull docker.io/library/busybox:latest
    ctr_id=$( start_sleep_container )
    crioctl ctr status --id "$ctr_id"
    ${KPOD_BINARY} ${KPOD_OPTIONS} ps -a
    ${KPOD_BINARY} ${KPOD_OPTIONS} logs "$ctr_id"
    crioctl ctr status --id "$ctr_id"
    ${KPOD_BINARY} ${KPOD_OPTIONS} ps -a
    run ${KPOD_BINARY} ${KPOD_OPTIONS} kill "k8s_container999_podsandbox1_redhat.test.crio_redhat-test-crio_1"
    echo "$output"
    [ "$status" -eq 0 ]
    cleanup_ctrs
    cleanup_pods
    stop_crio
}

@test "kill a running container by id with a bogus signal" {
    start_crio
    ${KPOD_BINARY} ${KPOD_OPTIONS} pull docker.io/library/busybox:latest
    ctr_id=$( start_sleep_container )
    crioctl ctr status --id "$ctr_id"
    ${KPOD_BINARY} ${KPOD_OPTIONS} logs "$ctr_id"
    crioctl ctr status --id "$ctr_id"
    run ${KPOD_BINARY} ${KPOD_OPTIONS} kill -s foobar "$ctr_id"
    echo "$output"
    [ "$status" -ne 0 ]
    cleanup_ctrs
    cleanup_pods
    stop_crio
}
