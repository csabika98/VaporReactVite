#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
"$HOME/.local/bin/swift" build
"$HOME/.local/bin/swift" run
