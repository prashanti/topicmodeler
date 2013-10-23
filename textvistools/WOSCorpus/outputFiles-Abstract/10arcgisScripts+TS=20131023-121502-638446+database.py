import arcgisscripting

gp = arcgisscripting.create()
try:
	gp.toolbox = "management"
	print "Creating Geodatabase GDB_05creatSOM+TS=20131023-121502-478030"
	gp.CreateFileGDB(".","GDB_05creatSOM+TS=20131023-121502-478030.gdb")

	print "Importing Documents Shape 'Documents_20131023_121502_507900_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131023-121502-507900+docs.shp","./GDB_05creatSOM+TS=20131023-121502-478030.gdb","Documents_20131023_121502_507900_1")

	print "Importing Neurons Shape 'Neurons_20131023_121502_507900_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131023-121502-507900+neurons.shp","./GDB_05creatSOM+TS=20131023-121502-478030.gdb","Neurons_20131023_121502_507900_1")

	print "Importing Metadata Table 'Metadata_20131023_121502_478030'"
	gp.TableToTable_conversion("05creatSOM+TS=20131023-121502-478030+rowsmetadata.tab","./GDB_05creatSOM+TS=20131023-121502-478030.gdb","Metadata_20131023_121502_478030")
	gp.addindex("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Metadata_20131023_121502_478030","rowID","rowID","UNIQUE")

	print "Importing Topics Table 'Topics_20131023_121502_478030'"
	gp.TableToTable_conversion("05creatSOM+TS=20131023-121502-478030+colsnames.tab","./GDB_05creatSOM+TS=20131023-121502-478030.gdb","Topics_20131023_121502_478030")
	gp.addindex("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Topics_20131023_121502_478030","columnID","columnID","UNIQUE")

	print "Importing Clustering Table 'kmeans_nClus_20_20_20131023_121502_568818'"
	gp.TableToTable_conversion("07clusterDocs+TS=20131023-121502-568818+kmeans+20_20.tab","./GDB_05creatSOM+TS=20131023-121502-478030.gdb","kmeans_nClus_20_20_20131023_121502_568818")
	gp.addindex("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/kmeans_nClus_20_20_20131023_121502_568818","rowID","rowID","UNIQUE")
except:
	print gp.GetMessages()

print "Done Creating Geodatabase"
