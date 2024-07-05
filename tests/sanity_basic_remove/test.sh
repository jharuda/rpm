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
    rlPhaseEnd

    rlPhaseStartTest "Create snapshot"
        rlRun "RpmSnapshotCreate"
    rlPhaseEnd

    rlPhaseStartTest "Showing difference before and after install"
        rlRun "RpmSnapshotShowDiff"
        rlRun "yum install -y mc tmux"
        rlRun "RpmSnapshotShowDiff"
    rlPhaseEnd

    rlPhaseStartTest "Snapshot restore"
        rlRun "RpmSnapshotRevert" 0 "Uninstall 'mc' and 'tmux'"
        rlRun "RpmSnapshotDiscard"
    rlPhaseEnd

    rlPhaseStartTest "Checking system programs"
        rlRun "rpm -q mc" 1 "The package 'mc' should be uninstalled"
        rlRun "rpm -q tmux" 1 "The package 'tmux' should be uninstalled"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "yum remove -y tmux mc" 0 "Remove leftover packages"
        rlRun "popd"
        rlRun "rm -r $tmp" 0 "Remove tmp directory"
    rlPhaseEnd
rlJournalEnd
