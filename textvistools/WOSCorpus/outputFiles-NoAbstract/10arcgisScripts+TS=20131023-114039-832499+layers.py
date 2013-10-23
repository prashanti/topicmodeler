import os
import arcgisscripting

gp = arcgisscripting.create()
try:

	print "Creating folder 'ArcGIS-layers/Layers_05creatSOM+TS=20131023-114039-732931'"
	os.makedirs("ArcGIS-layers/Layers_05creatSOM+TS=20131023-114039-732931")

	print "Creating Layer 'Document Year'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Documents_20131023_114039_753275_1","Document Year")
	gp.AddJoin("Document Year","PointID","./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Metadata_20131023_114039_732931","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("Document Year","ArcGIS-layers/Layers_05creatSOM+TS=20131023-114039-732931/Document Year")

	print "Creating Clustering Layer 'kmeans_nClus_20_20_20131023_114039_788177-kmeans20'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Documents_20131023_114039_753275_1","kmeans_nClus_20_20_20131023_114039_788177-kmeans20")
	gp.AddJoin("kmeans_nClus_20_20_20131023_114039_788177-kmeans20","PointID","./GDB_05creatSOM+TS=20131023-114039-732931.gdb/kmeans_nClus_20_20_20131023_114039_788177","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("kmeans_nClus_20_20_20131023_114039_788177-kmeans20","ArcGIS-layers/Layers_05creatSOM+TS=20131023-114039-732931/kmeans_nClus_20_20_20131023_114039_788177-kmeans20")

	print "Creating Clustering Layer 'kmeans_nClus_20_20_20131023_114039_788177-kmeans20_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-114039-732931.gdb/Documents_20131023_114039_753275_1","kmeans_nClus_20_20_20131023_114039_788177-kmeans20_conf")
	gp.AddJoin("kmeans_nClus_20_20_20131023_114039_788177-kmeans20_conf","PointID","./GDB_05creatSOM+TS=20131023-114039-732931.gdb/kmeans_nClus_20_20_20131023_114039_788177","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("kmeans_nClus_20_20_20131023_114039_788177-kmeans20_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131023-114039-732931/kmeans_nClus_20_20_20131023_114039_788177-kmeans20_conf")
except:
	print gp.GetMessages()

print "Done Creating Layers"
