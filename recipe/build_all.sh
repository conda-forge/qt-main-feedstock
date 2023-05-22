#!/usr/bin/env bash
#
set -ex
docker system prune --force

export CPU_COUNT=${CPU_COUNT:-10}
configs="linux_aarch64_ linux_ppc64le_"

for config_filename in $configs; do
    filename=$(basename ${config_filename})
    config=${filename%.*}
    if [ -f build_artifacts/conda-forge-build-done-${config} ]; then
        echo skipped $config
        continue
    fi

    python build-locally.py $config  2>&1 | tee ${config}-log.txt
    # docker images get quite big clean them up after each build to save your disk....
    docker system prune --force
done

zip log_files.zip *-log.txt
