#!/bin/bash
# file: tool/action.sh

function get_action_in_present_continuous() {
    # parameter: verb's base form
    local action="${1}"

    case "${action}" in
    install) echo "Installing" ;;
    uninstall) echo "Uninstalling" ;;
    upgrade) echo "Upgrading" ;;
    *) echo "unknown" ;;
    esac
}

function get_action_in_simple_past() {
    # parameter: verb's base form
    local action="${1}"

    case "${action}" in
    install) echo "Installed" ;;
    uninstall) echo "Uninstalled" ;;
    upgrade) echo "Upgraded" ;;
    *) echo "unknown" ;;
    esac
}

function get_noun_from_action() {
    # parameter: verb's base form
    local action="${1}"

    case "${action}" in
    install) echo "installation" ;;
    uninstall) echo "uninstallation" ;;
    upgrade) echo "upgrade" ;;
    *) echo "unknown" ;;
    esac
}
