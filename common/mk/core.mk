# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variables which should be set on the command line
jira := ""

.PHONEY: help check_prereqs clean_id_and_checksums alternate_track

help: check_prereqs
	${REPO_TOP}/common/bin/mk_help

check_prereqs:
	${REPO_TOP}/common/bin/check-make-prereqs

clean_id_and_checksums: check_prereqs
	${REPO_TOP}/common/bin/clean_id_and_checksums

alternate_track: clean_id_and_checksums
	${REPO_TOP}/common/bin/alternative_track $(jira)
