#!/bin/bash

function usage {
	echo "Usage: tpch-setup.sh scale_factor ,[Fact file location],[TPCH_HOME],[Query Location]"
	exit 1
}

function runcommand {
	if [ "X$DEBUG_SCRIPT" != "X" ]; then
		$1
	else
		$1 2>/dev/null
	fi
}


# Get the parameters.
SCALE=$1
DSS_PATH=$2
TPCH_HOME=$3
DSS_DIS_QUERY=$4


# Sanity checking.
if [ X"$SCALE" = "X" ]; then
	usage
fi
if [ X"$DSS_PATH" = "X" ]; then
	DSS_PATH=/tmp/tpch-generate
fi

if [ X"$DSS_DIS_QUERY" = "X" ]; then
	DSS_DIS_QUERY=/tmp/allqueries.sql
fi

if [ X"$TPCH_HOME" = "X" ]; then
	CWD=$(pwd)
	TPCH_HOME="${CWD}/tpch-gen/tpch_2_17_0"
fi





cd tpch-gen
sh genratedata.sh ${SCALE} ${DSS_PATH} ${TPCH_HOME} ${DSS_DIS_QUERY}


hdfs dfs -put ${DSS_PATH} ${DSS_PATH}/${SCALE}/
hdfs dfs -ls ${DSS_PATH}/${SCALE} > /dev/null
if [ $? -ne 0 ]; then
	echo "Data generation failed, exiting."
	exit 1
fi

echo "TPC-DS text data generation complete."

# Create the text/flat tables as external tables. These will be later be converted to ORCFile.
echo "Loading text data into external tables."
#runcommand "beeline -i settings/load-flat.sql -f ddl-tpcds/text/alltables.sql -d DB=tpcds_text_${SCALE} -d LOCATION=${DIR}/${SCALE}"

runcommand "beeline -u jdbc:hive2://hacluster  -i settings/carbon-load-init.sql -f ddl-tpch/bin_normal/alltables.sql -d DB=tpch_text_${SCALE} -d LOCATION=${DSS_PATH}/${SCALE}"



# Create the optimized tables.
i=1
total=8

if test $SCALE -le 1000; then 
	SCHEMA_TYPE=normal
else
	SCHEMA_TYPE=partitioned
fi

DATABASE=tpch_${SCHEMA_TYPE}_carbon_${SCALE}


#beeline -u jdbc:hive2://hacluster -i settings/carbon-load-init.sql -f ddl-tpch/bin_${SCHEMA_TYPE}/alltables.sql -d DB=${SCHEMA_TYPE}_${SCALE}
runcommand "beeline -u jdbc:hive2://hacluster   -f ddl-tpch/bin_normal/alltables_carbon.sql -d DB=${DATABASE} "


for t in ${TABLES}
do
	echo "Optimizing table $t ($i/$total)."
	COMMAND="beeline -u jdbc:hive2://hacluster -f ddl-tpch/bin_${SCHEMA_TYPE}/insertinto.sql \
	    -d DB=${DATABASE} \
	    -d SOURCE=tpch_text_${SCALE}  \
        -d SCALE=${SCALE} \
		-d TABLENAME=${t} "
	runcommand "$COMMAND"
	if [ $? -ne 0 ]; then
		echo "Command failed, try 'export DEBUG_SCRIPT=ON' and re-running"
		exit 1
	fi
	i=`expr $i + 1`
done




echo "Data loaded into database ${DATABASE}."






