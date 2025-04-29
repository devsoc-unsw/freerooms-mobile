#!/bin/sh
# Type a script or drag a script file from your workspace to insert its path.
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

if command -v swiftformat >/dev/null 2>&1
then
    swiftformat .
else
    echo "warning: `swiftformat` command not found - run the command: brew install swiftformat"
fi

if command -v swiftlint >/dev/null 2>&1
then
    swiftlint
else
    echo "warning: `swiftlint` command not found - run the command: brew install swiftlint"
fi

