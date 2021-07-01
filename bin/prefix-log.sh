#!/usr/bin/env bash

# The wrapper utility that prints the name of the current progam in the supervisor logs

exec 3>&1
exec 4>&2

printf -v PREFIX "%-10.10s" ${SUPERVISOR_PROCESS_NAME}

exec 1> >( perl -ne '$| = 1; print "'"${PREFIX}"' | $_"' >&3)
exec 2> >( perl -ne '$| = 1; print "'"${PREFIX}"' | $_"' >&4)

exec "$@"
