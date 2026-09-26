#!/usr/bin/env bats

setup() {
    CTL="${BATS_TEST_DIRNAME}/../omarchy-shield-ctl"
    chmod +x "$CTL"
}

@test "status returns valid single-line JSON with required telemetry keys" {
    run "$CTL" status
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^\{.*\}$ ]]
    [[ "$output" == *'"mode":'* ]]
    [[ "$output" == *'"ptrace":'* ]]
    [[ "$output" == *'"sudo_state":'* ]]
    [[ "$output" == *'"open_ports":'* ]]
}

@test "rejects unknown subcommand before pkexec" {
    run "$CTL" unknown-cmd
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "rejects invalid mode in apply" {
    run "$CTL" apply gaming 1 60 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid mode"* ]]
}

@test "rejects invalid ptrace_scope values (0 and 3)" {
    run "$CTL" apply daily 0 0 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid ptrace_scope"* ]]

    run "$CTL" apply daily 3 0 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid ptrace_scope"* ]]
}

@test "rejects out-of-range and non-numeric lease values" {
    run "$CTL" apply lab 1 241 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"between 0 and 240"* ]]

    run "$CTL" apply lab 1 -10 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid lease argument"* ]]

    run "$CTL" apply lab 1 forever 0
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid lease argument"* ]]
}

@test "rejects invalid dev_ports flag" {
    run "$CTL" apply daily 1 0 2
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid dev_ports flag"* ]]
}

@test "accepts valid presets and keep flag in --dry-run mode without root" {
    run "$CTL" --dry-run apply public 2 0 0
    [ "$status" -eq 0 ]
    [[ "$output" == "[DRY-RUN] apply mode=public ptrace=2 lease=0 dev_ports=0" ]]

    run "$CTL" --dry-run apply lab 1 60 1
    [ "$status" -eq 0 ]
    [[ "$output" == "[DRY-RUN] apply mode=lab ptrace=1 lease=60 dev_ports=1" ]]

    run "$CTL" --dry-run apply lab 2 keep 1
    [ "$status" -eq 0 ]
    [[ "$output" == "[DRY-RUN] apply mode=lab ptrace=2 lease=keep dev_ports=1" ]]
}

@test "accepts revoke-sudo and bios in --dry-run mode without root" {
    run "$CTL" --dry-run revoke-sudo
    [ "$status" -eq 0 ]
    [[ "$output" == *"[DRY-RUN] revoke-sudo"* ]]

    run "$CTL" --dry-run bios
    [ "$status" -eq 0 ]
    [[ "$output" == *"[DRY-RUN] bios"* ]]
}
