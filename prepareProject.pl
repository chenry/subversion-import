#!/opt/local/bin/perl -w

use strict;
use File::Copy;
my $projectDir;
my @projectDirectories;

main();

sub main {
  validateArgs();
  transformEachProjectDirectory();  
}

sub transformEachProjectDirectory {
  # open the project directory and read all of the
  # directories within it.
  opendir(PROJ_DIR, $projectDir);

  my @allFiles = readdir(PROJ_DIR);

  foreach my $currFile (@allFiles) {
    if (-d "$projectDir/$currFile" && $currFile !~ /^\./) {
      push(@projectDirectories, $currFile);
    }
  } 

  foreach my $currProj (@projectDirectories) {
    transformProjectDir("$projectDir/$currProj");
  }

  closedir(PROJ_DIR);
}	

sub transformProjectDir {
  my ($currProjDir) = @_;
  print "Current project Directory: $currProjDir\n";

  createTrunkDir($currProjDir);
  mkdir("$currProjDir/branch");
  mkdir("$currProjDir/tags");
}

sub createTrunkDir {
  my ($currProjDir) = @_;

  # build the list of files and directories that exist in the current project directory
  opendir(CURR_PROJ_DIR, $currProjDir);
  my @allFiles = readdir(CURR_PROJ_DIR);
  my $trunkDir = "$currProjDir/trunk";
  mkdir("$currProjDir/trunk");

  # move all of the files into the trunkDir
  foreach my $currFile (@allFiles) {
    my $fullPathCurrFile = "$currProjDir/$currFile";
    if (-d $fullPathCurrFile && $currFile !~ /^\./) {
	    recursiveAddFolderToDestinationDir($fullPathCurrFile, $currFile, $trunkDir);
    } else {
      move($fullPathCurrFile, $trunkDir);  
    }
  } 

  closedir(CURR_PROJ_DIR);
}

sub recursiveAddFolderToDestinationDir() {
  my ($fullPathCurrDir, $currDir, $destDir) = @_;
  
  # make the directory in the destDir

  mkdir("$destDir/$currDir");
  opendir(DIR, $fullPathCurrDir);
  my @allFiles = readdir(DIR);
  closedir(DIR);

  foreach my $currFile (@allFiles) {
    my $fullPathCurrFile = "$fullPathCurrDir/$currFile";
    if (-d $fullPathCurrFile && $currFile !~ /^\./) {
      print"$fullPathCurrFile is directory and we will copy it to $destDir/$currDir\n"; 
    } elsif ($currFile =~ /^\./) {
    } else {
      print"will copy $currFile to $destDir/$currDir\n";
    }
  }

}

sub validateArgs {
  my $argSize = @ARGV;
  if ($argSize != 1) {
    print "usage: prepareProject.pl <directoryOfProjects>\n"; 
    exit(0);
  }

  $projectDir = $ARGV[0];
}
