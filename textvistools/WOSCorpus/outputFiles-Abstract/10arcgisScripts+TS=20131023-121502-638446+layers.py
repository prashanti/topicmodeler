import os
import arcgisscripting

gp = arcgisscripting.create()
try:

	print "Creating folder 'ArcGIS-layers/Layers_05creatSOM+TS=20131023-121502-478030'"
	os.makedirs("ArcGIS-layers/Layers_05creatSOM+TS=20131023-121502-478030")

	print "Creating Layer 'Document Year'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Documents_20131023_121502_507900_1","Document Year")
	gp.AddJoin("Document Year","PointID","./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Metadata_20131023_121502_478030","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("Document Year","ArcGIS-layers/Layers_05creatSOM+TS=20131023-121502-478030/Document Year")

	print "Creating Clustering Layer 'kmeans_nClus_20_20_20131023_121502_568818-kmeans20'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Documents_20131023_121502_507900_1","kmeans_nClus_20_20_20131023_121502_568818-kmeans20")
	gp.AddJoin("kmeans_nClus_20_20_20131023_121502_568818-kmeans20","PointID","./GDB_05creatSOM+TS=20131023-121502-478030.gdb/kmeans_nClus_20_20_20131023_121502_568818","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("kmeans_nClus_20_20_20131023_121502_568818-kmeans20","ArcGIS-layers/Layers_05creatSOM+TS=20131023-121502-478030/kmeans_nClus_20_20_20131023_121502_568818-kmeans20")

	print "Creating Clustering Layer 'kmeans_nClus_20_20_20131023_121502_568818-kmeans20_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131023-121502-478030.gdb/Documents_20131023_121502_507900_1","kmeans_nClus_20_20_20131023_121502_568818-kmeans20_conf")
	gp.AddJoin("kmeans_nClus_20_20_20131023_121502_568818-kmeans20_conf","PointID","./GDB_05creatSOM+TS=20131023-121502-478030.gdb/kmeans_nClus_20_20_20131023_121502_568818","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("kmeans_nClus_20_20_20131023_121502_568818-kmeans20_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131023-121502-478030/kmeans_nClus_20_20_20131023_121502_568818-kmeans20_conf")
except:
	print gp.GetMessages()

print "Done Creating Layers"
