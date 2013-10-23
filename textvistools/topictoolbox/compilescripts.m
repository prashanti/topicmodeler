% compile all mex cpp scripts
mex -O GibbsSamplerLDA.cpp -largeArrayDims
mex -O GibbsSamplerAT.cpp -largeArrayDims
mex -O GibbsSamplerHMMLDA.cpp -largeArrayDims
mex -O GibbsSamplerLDACOL.cpp -largeArrayDims
mex -O binarysearchstrings.c -largeArrayDims
