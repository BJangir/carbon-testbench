#this will genrate the data based of scale factore


function usage {
	echo "Usage: tpch-setup.sh scale_factor ,[Fact file location],[TPCH_HOME],[Query Location]"
	exit 1
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
	TPCH_HOME="${CWD}/tpch_2_17_0"
fi


# Tables in the TPC-H schema.
TABLES="part partsupp supplier customer orders lineitem nation region"

mkdir -p ${DSS_PATH}
sudo hdfs dfs -mkdir -p ${DSS_PATH}
sudo hdfs dfs -ls ${DSS_PATH}/${SCALE}/lineitem > /dev/null



# Fact file path 
#DSS_PATH=/opt/babu/flatfiles
#TPCH_HOME=/opt/babu/tpch_2_17_0
DSS_QUERY=$TPCH_HOME/dbgen/queries
#DSS_DIS_QUERY=/opt/babu/all.sql

sudo mkdir -p $DSS_PATH
sudo chmod 777 $DSS_PATH
touch $DSS_DIS_QUERY
chmod 777 $DSS_DIS_QUERY
cd $TPCH_HOME/dbgen
sudo DSS_PATH=$DSS_PATH $TPCH_HOME/dbgen/dbgen -f -s ${SCALE}
sudo DSS_QUERY=${DSS_QUERY} $TPCH_HOME/dbgen/qgen -s ${SCALE} > $DSS_DIS_QUERY

