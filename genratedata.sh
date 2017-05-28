#this will genrate the data based of scale factore

# Fact file path 
DSS_PATH=/opt/babu/flatfiles
TPCH_HOME=/opt/babu/tpch_2_17_0
DSS_QUERY=$TPCH_HOME/dbgen/queries
DSS_DIS_QUERY=/opt/babu/all.sql

sudo mkdir -p $DSS_PATH
sudo chmod 777 $DSS_PATH
touch $DSS_DIS_QUERY
chmod 777 $DSS_DIS_QUERY
cd $TPCH_HOME/dbgen
sudo DSS_PATH=$DSS_PATH $TPCH_HOME/dbgen/dbgen -f -s 1
sudo DSS_QUERY=/opt/babu/tpch_2_17_0/dbgen/queries $TPCH_HOME/dbgen/qgen -s 1 > $DSS_DIS_QUERY

