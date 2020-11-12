# NAME

BeakerLib library RpmSnapshot

# DESCRIPTION

This library provide snapshoting functionality for rpm installed on the system.
Reverting is done using /mnt/redhat/brewroot/packages/... If the package is not
found there yum is used assuming that the particullar version is available in
some repo.

# USAGE

To use this functionality you need to import library distribution/RpmSnapshot and
add following line to Makefile.

        @echo "RhtsRequires:    library(distribution/RpmSnapshot)" >> $(METADATA)

And in the code to include rlImport distribution/RpmSnapshot or just
_rlImport --all_ to import all libraries specified in Makelife.

**Code example**

        RpmSnapshotCreate  [RPM_SNAPSHOT]
        yum update -y
        RpmSnapshotRevert  [RPM_SNAPSHOT]
        RpmSnapshotDiscard [RPM_SNAPSHOT]

RPM\_SNAPSHOT is a file which is or will be containing a list of rpms.

There is also a global variable RPM\_SNAPSHOT which can be used for nested
snapshoting a reverting.

# FUNCTIONS

# AUTHORS

- Dalibor Pospisil <dapospis@redhat.com>
