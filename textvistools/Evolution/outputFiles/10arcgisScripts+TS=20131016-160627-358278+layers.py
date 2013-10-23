import os
import arcgisscripting

gp = arcgisscripting.create()
try:

	print "Creating folder 'ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498'"
	os.makedirs("ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498")

	print "Creating Layer 'Document Year'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","Document Year")
	gp.AddJoin("Document Year","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Metadata_20131016_160627_268498","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("Document Year","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/Document Year")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans5_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans25_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans125_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans490_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans993_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1197_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1240_conf")

	print "Creating Clustering Layer 'hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241_conf'"
	gp.MakeFeatureLayer("./GDB_05creatSOM+TS=20131016-160627-268498.gdb/Documents_20131016_160627_286666_1","hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241_conf")
	gp.AddJoin("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241_conf","PointID","./GDB_05creatSOM+TS=20131016-160627-268498.gdb/hkmeans_nClus_5_1241_20131016_160627_316676","rowID","KEEP_ALL")
	gp.SaveToLayerFile_management("hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241_conf","ArcGIS-layers/Layers_05creatSOM+TS=20131016-160627-268498/hkmeans_nClus_5_1241_20131016_160627_316676-hkmeans1241_conf")
except:
	print gp.GetMessages()

print "Done Creating Layers"
