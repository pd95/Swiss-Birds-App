#!/bin/bash

LOCAL_CONFIG_FILE="$CI_WORKSPACE/LocalConfig.xcconfig"

if [ -z "$CI_BUNDLE_ID" -o -z "$CI_TEAM_ID" ]; then
    echo "ERROR: Make sure to specify the CI_BUNDLE_ID or CI_TEAM_ID arguments"
    exit 1
fi

if [ -f "${LOCAL_CONFIG_FILE}" ]; then
    echo "LocalConfig.xcconfig does exist with the following content:"
    cat "$LOCAL_CONFIG_FILE"
else 
    echo "LocalConfig.xcconfig does not exists.
Creating new config from environment..."
    cat > "$LOCAL_CONFIG_FILE" <<EOL
// Local Config
PRODUCT_BUNDLE_IDENTIFIER = ${CI_BUNDLE_ID}
DEVELOPMENT_TEAM = ${CI_TEAM_ID}
CODE_SIGN_STYLE = Automatic
EOL
fi
