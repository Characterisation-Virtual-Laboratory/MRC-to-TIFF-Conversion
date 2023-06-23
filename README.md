### MRC to TIFF Conversion
A wrapper script for iMODs mrc2tif function.  Converts all mrc files within a folder to tiff.<br>
Allows for parallel conversion.
<br><br><br><br>

### Requirements
IMOD
`https://bio3d.colorado.edu/imod`
<br><br><br><br>

### Download Commands
```
$ cd ~/Downloads
$ git clone https://github.com/Characterisation-Virtual-Labratory/MRC-to-TIFF-Conversion
```
<br><br><br><br>

### Install Commands
```
$ cd ~/Downloads/MRC-to-TIFF-Conversion
$ cp ./MRC2TIFF.sh /desired/location
```
<br><br><br><br>

### Configuration
**Edit the following files:**<br>
`/desired/location/MRC2TIFF.sh`<br>
> Option to set a default output location.<br>
> Can be specified at command line.<br>

<br><br><br><br>
### Command
`$ /desired/location/MRC2TIFF.sh [-p n] /src [/dest]`
> -p n		Split the found MRC files into this man groups to be run in parallel.<br>
> /src		Path to source dataset of MRC files.<br>
> /dest		Path to output dir for tiff files.  Project dir + subfolders will be created here.<br>
