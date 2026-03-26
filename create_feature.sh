#!/bin/bash

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Please provide feature name"
  exit 1
fi

BASE_DIR="lib/features/$FEATURE_NAME"

mkdir -p $BASE_DIR/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{view,view_model}}

echo "Feature '$FEATURE_NAME' created successfully!"