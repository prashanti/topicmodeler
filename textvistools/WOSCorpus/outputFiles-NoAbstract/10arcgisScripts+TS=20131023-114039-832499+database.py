import arcgisscripting

gp = arcgisscripting.create()
try:
	gp.toolbox = "management"
	print "Creating Geodatabase GDB_05creatSOM+TS=20131023-114039-732931"
	gp.CreateFileGDB(".","GDB_05creatSOM+TS=20131023-114039-732931.gdb")

	print "Importing Documents Shape 'Documents_20131023_114039_753275_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131023-114039-753275+docs.shp","./GDB_05creatSOM+TS=20131023-114039-732931.gdb","Documents_20131023_114039_753275_1")

	print "Importing Neurons Shape 'Neurons_20131023_114039_753275_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131023-114039-753275+neurons.shp","./GDB_05creatSOM+TS=20131023-114039-732931.gdb","Neurons_20131023_114039_753275_1")

	print "Importing Metadata Table 'Metadata_20131023_114039_732931'"
	gp.TableToTable_conversion("05creatSOM+TS=20131023-114039-732931+rowsmetadata.tab","./GDB_05creatSOM+TS=20131023-114039-732931.gdb","Metadata_20131023_114039_732931")
	gp.addindex("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Metadata_20131023_114039_732931","rowID","rowID","UNIQUE")

	print "Importing Topics Table 'Topics_20131023_114039_732931'"
	gp.TableToTable_conversion("05creatSOM+TS=20131023-114039-732931+colsnames.tab","./GDB_05creatSOM+TS=20131023-114039-732931.gdb","Topics_20131023_114039_732931")
	gp.addindex("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Topics_20131023_114039_732931","columnID","columnID","UNIQUE")

	print "Importing Clustering Table 'kmeans_nClus_20_20_20131023_114039_788177'"
	gp.TableToTable_conversion("07clusterDocs+TS=20131023-114039-788177+kmeans+20_20.tab","./GDB_05creatSOM+TS=20131023-114039-732931.gdb","kmeans_nClus_20_20_20131023_114039_788177")
	gp.addindex("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/kmeans_nClus_20_20_20131023_114039_788177","rowID","rowID","UNIQUE")
except:
	print gp.GetMessages()

print "Done Creating Geodatabase"
