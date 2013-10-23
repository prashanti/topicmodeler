import os
import arcgisscripting

gp = arcgisscripting.create()
try:

	print "Creating folder 'ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217'"
	os.makedirs("ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217")

	print "Creating Layer 'Document Year'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","Document Year")
	gp.AddJoin("Document Year","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Metadata_20120916_142354_404217","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("Document Year","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/Document Year")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans5_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans25_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans125_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans584_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans1751_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2686_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2916_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20120916-142354-404217.gdb/Documents_20120916_142354_492092_1","hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932_conf")
	gp.AddJoin("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932_conf","PointID","./GDB_05creatSOM+TS=20120916-142354-404217.gdb/hkmeans_nClus_5_2932_20120916_142354_629646","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932_conf","ArcGIS-layers/Layers_05creatSOM+TS=20120916-142354-404217/hkmeans_nClus_5_2932_20120916_142354_629646-hkmeans2932_conf")
except:
	print gp.GetMessages()

print "Done Creating Layers"
