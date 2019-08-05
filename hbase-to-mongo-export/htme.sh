#!/bin/sh -x

# Placeholder file to be replaced in userdata during deployment as values will be terraform-based
# eg
# java -jar hbase-to-mongo-export.jar \
    # --spring.profiles.active=aesCipherService,batchRun,httpDataKeyService,outputToDirectory,production \
    # --dataKeyServiceUrl=$DKS_LB_DNS \
    # --hbase.zookeeper.quorum=$HBASE_MASTER_URL \
    # --output.batch.size.max 100000-source.table.name=?? \
    # --file.output=/tmp/hbase-export
