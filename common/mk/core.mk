# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variables which should be set on the command line
jira := ""

.PHONEY: help check_preqs new_test_track

help: check_preqs
	${REPO_TOP}/common/bin/mk_help

check_preqs:
	${REPO_TOP}/common/bin/check-make-prereqs

new_test_track: check_preqs
	${REPO_TOP}/common/bin/new_test_track $(jira)
