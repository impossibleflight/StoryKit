#!/bin/sh

#  copy_fixtures.sh
#  StoryKitTool
#
#  Created by John Clayton on 1/22/19.
#  

fixtures_dir="${SRCROOT}/Tests/${TARGET_NAME}/Fixtures/"
resources_dir="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

cp -R $fixtures_dir $resources_dir
