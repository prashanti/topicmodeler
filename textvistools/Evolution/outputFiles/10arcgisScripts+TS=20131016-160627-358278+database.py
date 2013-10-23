import arcgisscripting

gp = arcgisscripting.create()
try:
	gp.toolbox = "management"
	print "Creating Geodatabase GDB_05creatSOM+TS=20131016-160627-268498"
	gp.CreateFileGDB(".","GDB_05creatSOM+TS=20131016-160627-268498.gdb")

	print "Importing Documents Shape 'Documents_20131016_160627_286666_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131016-160627-286666+docs.shp","./GDB_05creatSOM+TS=20131016-160627-268498.gdb","Documents_20131016_160627_286666_1")

	print "Importing Neurons Shape 'Neurons_20131016_160627_286666_1'"
	gp.FeatureclassToFeatureclass_conversion("06sompak+TS=20131016-160627-286666+neurons.shp","./GDB_05creatSOM+TS=20131016-160627-268498.gdb","Neurons_20131016_160627_286666_1")

	print "Importing Metadata Table 'Metadata_20131016_160627_268498'"
	gp.TableToTable_conversion("05creatSOM+TS=20131016-160627-268498+rowsmetadata.tab","./GDB_05creatSOM+TS=20131016-160627-268498.gdb","Metadata_20131016_160627_268498")
	gp.addindex("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Metadata_20131016_160627_268498","rowID","rowID","UNIQUE")

	print "Importing Topics Table 'Topics_20131016_160627_268498'"
	gp.TableToTable_conversion("05creatSOM+TS=20131016-160627-268498+colsnames.tab","./GDB_05creatSOM+TS=20131016-160627-268498.gdb","Topics_20131016_160627_268498")
	gp.addindex("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Topics_20131016_160627_268498","columnID","columnID","UNIQUE")

	print "Importing Clustering Table 'hkmeans_nClus_5_1241_20131016_160627_316676'"
	gp.TableToTable_conversion("07clusterDocs+TS=20131016-160627-316676+hkmeans+5_1241.tab","./GDB_05creatSOM+TS=20131016-160627-268498.gdb","hkmeans_nClus_5_1241_20131016_160627_316676")
	gp.addindex("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","rowID","UNIQUE")
except:
	print gp.GetMessages()

print "Done Creating Geodatabase"
