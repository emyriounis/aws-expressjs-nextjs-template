#!/bin/bash

terraform state pull > ./tf.state

rm -rf ./inframap
git clone https://github.com/cycloidio/inframap
cd inframap
go mod download
make build
cd ..

set -e
terraform graph -type=plan | dot -Tpng > ./tf-graph/default.png
./inframap generate --connections=false ./tf.state | dot -Tpng > ./tf-graph/lite.png
./inframap generate ./tf.state --raw | dot -Tpng > ./tf-graph/full.png
set +e

rm ./tf.state
rm -rf ./inframap

echo "Visualization generated successfully"
