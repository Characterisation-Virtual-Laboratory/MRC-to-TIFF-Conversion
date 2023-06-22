### MRC to TIFF Conversion ###
A wrapper script for iMODs mrc2tif function.  Converts all mrc files within a folder to tiff.
Allows for parallel conversion.




### Requirements ###
IMOD			(https://bio3d.colorado.edu/imod/)




### Download Commands ###
$ cd ~/Downloads
$ git clone https://github.com/Characterisation-Virtual-Labratory/MRC-to-TIFF-Conversion




### Install Commands ###
$ cd ~/Downloads/MRC-to-TIFF-Conversion
$ cp ./MRC2TIFF.sh /desired/location




### Configuration ###
Edit the following files:
	/desired/location/MRC2TIFF.sh
		Option to set a default output location.
                Can be specified at command line.




### Command ###
$ /desired/location/MRC2TIFF.sh [-p n] /src [/dest]
	-p n		Split the found MRC files into this man groups to be run in parallel.
	/src		Path to source dataset of MRC files.
	/dest		Path to output dir for tiff files.  Project dir + subfolders will be created here.