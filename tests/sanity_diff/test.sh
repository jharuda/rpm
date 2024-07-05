#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
. /usr/share/beakerlib/beakerlib.sh || exit 1


rlJournalStart
    rlPhaseStartSetup "Install lib, programs setup"
        rlRun "tmp=\$(mktemp -d)" 0 "Create tmp directory"
        rlRun "pushd $tmp"
        rlRun "set -o pipefail"
        rlRun "rlImport snapshot"

        rlRun "yum remove -y mc tmux" 0 "Make sure there are not 2 programs that we plan to use for this test"
        rlRun "yum install -y mc" 0 "Make sure there are not 2 programs that we plan to use for this test"
    rlPhaseEnd

    rlPhaseStartTest "Show diff before snapshot"
        rlRun "RpmSnapshotShowDiff" 0 "Diff prints message to log when there is no snapshot"
    rlPhaseEnd

    rlPhaseStartTest "Create snapshot"
        rlRun "RpmSnapshotCreate"
        diff_before_install="$( RpmSnapshotShowDiff )"
        rlLog "diff_before_install is:"
        echo "$diff_before_install"
        if [[ "$diff_before_install" == "" ]]; then
            rlPass "'diff_before_install' is empty"
        else
            rlLogError "'diff_before_install' should be empty"
        fi
    rlPhaseEnd

    rlPhaseStartTest "Install tmux"
        declare -r diff_tmuxIN="diff_tmuxIN.txt"
        declare -i diff_tmuxIN_count
        rlRun "yum install -y tmux"
        rlRun "RpmSnapshotShowDiff"
        rlRun "RpmSnapshotShowDiff > ${diff_tmuxIN}"

        rlAssertGrep "^\+tmux " "$diff_tmuxIN" -E

        diff_tmuxIN_count="$( wc -l ${diff_tmuxIN} | cut -d' ' -f1 )"
        if [[ "$diff_tmuxIN_count" == "1" ]]; then
            rlPass "There is 1 different line returned by 'RpmSnapshotDiff'"
        else
            rlFail "There are '${diff_tmuxIN_count}' different lines of number returned by 'RpmSnapshotDiff'"
        fi
    rlPhaseEnd

    rlPhaseStartTest "Remove mc and keep tmux installed"
        declare -r diff_mcRM_tmuxIN="diff_mcRM_tmuxIN.txt"
        declare -i diff_mcRM_tmuxIN_count
        rlRun "yum rm -y mc"
        rlRun "RpmSnapshotShowDiff"
        rlRun "RpmSnapshotShowDiff > ${diff_mcRM_tmuxIN}"

        rlAssertGrep "^\+tmux " "$diff_mcRM_tmuxIN" -E
        rlAssertGrep "^\-mc " "$diff_mcRM_tmuxIN" -E

        diff_mcRM_tmuxIN_count="$( wc -l ${diff_mcRM_tmuxIN} | cut -d' ' -f1 )"
        if [[ "$diff_mcRM_tmuxIN_count" == "2" ]]; then
            rlPass "There are 2 different line returned by 'RpmSnapshotDiff'"
        else
            rlFail "There are '${diff_tmuxIN_count}' different lines of number returned by 'RpmSnapshotDiff'"
        fi
    rlPhaseEnd

    rlPhaseStartTest "Install mc and remove tmux - default state before test"
        declare -r diff_mcIN_tmuxRM="diff_mcIN_tmuxRM.txt"
        rlRun "yum install -y mc"
        rlRun "yum rm -y tmux"
        rlRun "RpmSnapshotShowDiff"
        rlRun "RpmSnapshotShowDiff > ${diff_mcIN_tmuxRM}"

        if [[ "$( cat ${diff_mcIN_tmuxRM} )" == "" ]]; then
            rlPass "'RpmSnapshotShowDiff' is empty"
        else
            rlLogError "'RpmSnapshotShowDiff' should be empty"
        fi
    rlPhaseEnd

    rlPhaseStartTest "Snapshot revert"
        rlRun "RpmSnapshotRevert" 0 "Uninstall 'mc' and 'tmux'"
        rlRun "RpmSnapshotDiscard"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "yum remove -y tmux mc" 0 "Remove leftover packages"
        rlRun "popd"
        rlRun "rm -r $tmp" 0 "Remove tmp directory"
    rlPhaseEnd
rlJournalEnd
