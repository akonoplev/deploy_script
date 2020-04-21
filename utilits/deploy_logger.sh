#!/bin/sh

#  deploy_logger.sh
#  Teamo
#
#  Created by Andrei Konoplev on 15.04.2020.
#  Copyright © 2020 Виктор Заикин. All rights reserved.

log() {
    prefix="[deploy_script]"
    echo "$prefix $1"
}

log_seporator() {
	seporator="========================================="
	echo $seporator
}

log_did_start() {
	log_seporator
	log "[🚀] Did start: $1"
}

log_did_finish() {
	log "[😀] Did successfully finish on step: $1"
}

log_did_finish_or_exit_if_failed () {
	rc=$?
	if [[ $rc != 0 ]]; then
		log "[🤬] Deploy task failed on step: $1"
		exit $rc
	else log_did_finish $1
	fi
}

log_param() {
	log "param '$1' = '$2'"
}
