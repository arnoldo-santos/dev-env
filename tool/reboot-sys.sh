#!/usr/bin/env bash

# ───────────────────────────────────────────────────────────────
# Configuration / Constants
# ───────────────────────────────────────────────────────────────

readonly COUNTDOWN_SECONDS=30
readonly REBOOT_CMD="sudo reboot"

# Accepted answers (case insensitive)
readonly -A YES_ANSWERS=([yes]=1 [y]=1)
readonly -A NO_ANSWERS=([no]=1 [n]=1 [q]=1 [quit]=1 [c]=1 [cancel]=1)

# ───────────────────────────────────────────────────────────────
# Helper functions
# ───────────────────────────────────────────────────────────────

print_instructions() {
	cat <<-'EOF'
		Reboot system automatically in 30 seconds

		Type:
		  • 'yes' | 'y'        → reboot immediately
		  • 'no' | 'n' | 'q' | 'quit' | 'c' | 'cancel' → cancel reboot
		  • Invalid or empty   → countdown continues
	EOF
	echo
}

normalize_input() {
	local input="$1"
	# Remove leading/trailing whitespace and convert to lowercase
	echo "$input" | tr '[:upper:]' '[:lower:]' | xargs
}

is_yes() {
	local answer="$1"
	[[ ${YES_ANSWERS[$answer]+_} ]]
}

is_no() {
	local answer="$1"
	[[ ${NO_ANSWERS[$answer]+_} ]]
}

print_countdown() {
	local remaining=$1
	printf "\rReboot now? (y/n/q) [%02d seconds left]: " "$remaining"
}

# ───────────────────────────────────────────────────────────────
# Main logic
# ───────────────────────────────────────────────────────────────

countdown_reboot() {
	local total_seconds=$1
	local start_time
	start_time=$(date +%s)

	while true; do
		local current_time
		current_time=$(date +%s)
		local elapsed=$((current_time - start_time))
		local remaining=$((total_seconds - elapsed))

		if ((remaining <= 0)); then
			echo -e "\n\nTime's up!"
			echo "Rebooting..."
			$REBOOT_CMD
			return 0
		fi

		print_countdown "$remaining"

		# Try to read with 1-second timeout
		if read -t 1 -r answer; then
			echo # new line after user input

			# Normalize only if we got something
			local norm
			norm=$(normalize_input "$answer")

			if is_yes "$norm"; then
				echo "Rebooting immediately..."
				$REBOOT_CMD
				return 0
			elif is_no "$norm"; then
				echo "Reboot cancelled."
				return 0
			else
				# Invalid → just continue (show next second)
				echo "Invalid input — ignored"
				# We don't 'continue' here — let the loop sleep the rest of the second
			fi
		fi
		# No input → loop continues → updates display next second
	done
}

# ───────────────────────────────────────────────────────────────
# Public entry point
# ───────────────────────────────────────────────────────────────

reboot_with_countdown() {
	print_instructions
	countdown_reboot "$COUNTDOWN_SECONDS"
}

# For testing / direct call:
# reboot_with_countdown
