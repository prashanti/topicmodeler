import arcgisscripting

gp = arcgisscripting.create()
try:
	gp.toolbox = "management"
	print "Creating Geodatabase GDB_05creatSOM+TS=20120916-142354-404217"
	gp.CreateFileGDB(".","GDB_05creatSOM+TS=20120916-142354-404217.gdb")

	print "Importing Documents Shape 'Documents_20120916_142354_492092_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20120916-142354-492092+docs.shp","./GDB_05creatSOM+TS=20120916-142354-404217.gdb","Documents_20120916_142354_492092_1")

	print "Importing Neurons Shape 'Neurons_20120916_142354_492092_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20120916-142354-492092+neurons.shp","./GDB_05creatSOM+TS=20120916-142354-404217.gdb","Neurons_20120916_142354_492092_1")

	print "Importing Metadata Table 'Metadata_20120916_142354_404217'"
	gp.TableToTable_conversion("05creatSOM+TS=20120916-142354-404217+rowsmetadata.tab","./GDB_05creatSOM+TS=20120916-142354-404217.gdb","Metadata_20120916_142354_404217")
	gp.addindex("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Metadata_20120916_142354_404217","rowID","rowID","UNIQUE")

	print "Importing Topics Table 'Topics_20120916_142354_404217'"
	gp.TableToTable_conversion("05creatSOM+TS=20120916-142354-404217+colsnames.tab","./GDB_05creatSOM+TS=20120916-142354-404217.gdb","Topics_20120916_142354_404217")
	gp.addindex("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Topics_20120916_142354_404217","columnID","columnID","UNIQUE")

	print "Importing Clustering Table 'hkmeans_nClus_5_2932_20120916_142354_629646'"
	gp.TableToTable_conversion("07clusterDocs+TS=20120916-142354-629646+hkmeans+5_2932.tab","./GDB_05creatSOM+TS=20120916-142354-404217.gdb","hkmeans_nClus_5_2932_20120916_142354_629646")
	gp.addindex("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","rowID","UNIQUE")
except:
	print gp.GetMessages()

print "Done Creating Geodatabase"
