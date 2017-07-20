#!/usr/bin/perl
use strict;
use Getopt::Tabular;
use Data::Dumper;
use NeuroDB::MRI;
use NeuroDB::DBI;
use File::Basename;

my $num_args = $#ARGV +1;
print "You should specify a folder matching PSCID_DCCID_Project_VisitLabel.\n" if $num_args=0;
my $folder=$ARGV[0];
my $folder_name=basename($folder);

print "Folder is $folder\n";

my %folderIDs;

if($folder_name =~ /([^_]+)_(\d+)_([^_]+)_([^_]+)_(\d+)_(\d+)/){

    $folderIDs{'PSCID'} = NeuroDB::MRI::my_trim($1);
    $folderIDs{'CandID'} = NeuroDB::MRI::my_trim($2);
    my $cohort = NeuroDB::MRI::my_trim($3);
    my $visit = NeuroDB::MRI::my_trim($4);
    $folderIDs{'old_visitLabel'} = $cohort."_".$visit;
    $folderIDs{'end'} = $5."_".$6;

    print "PSCID is $folderIDs{'PSCID'}, DCCID is $folderIDs{'CandID'} and old visit label was $folderIDs{'old_visitLabel'}, ";

} else { print "$folder_name does not match PSCID_DCCID_Project_VisitLabel.\n"; exit 1; }

$folderIDs{'new_visitLabel'}="PREEN00" if ($folderIDs{'old_visitLabel'} eq "PreventAD_EN");
$folderIDs{'new_visitLabel'}="PREBL00" if ($folderIDs{'old_visitLabel'} eq "PreventAD_BL");
$folderIDs{'new_visitLabel'}="NAPEN00" if ($folderIDs{'old_visitLabel'} eq "Naproxen_EN");
$folderIDs{'new_visitLabel'}="NAPBL00" if ($folderIDs{'old_visitLabel'} eq "Naproxen_BL");
$folderIDs{'new_visitLabel'}="NAPFU03" if ($folderIDs{'old_visitLabel'} eq "Naproxen_FU03");

print "new visit label will be: $folderIDs{'new_visitLabel'}.\n";


opendir (DIR, $folder) or die $!;
while (my $file = readdir(DIR)){
    next if ($file =~ m/^\./);
    next if ($file =~ m/.bak/);
    my $f = $folder."/".$file;
    print "Updating header of file $f ...\n";
    `dcmodify -ma PatientName=$folderIDs{'PSCID'}_$folderIDs{'CandID'}_$folderIDs{'new_visitLabel'} $f`;    
}
closedir(DIR);

my $new_name=dirname($folder)."/".$folderIDs{'PSCID'}."_".$folderIDs{'CandID'}."_".$folderIDs{'new_visitLabel'}."_".$folderIDs{'end'};
print "Renaming folder $folder to $new_name \n";
rename($folder,$new_name);

print "Deleting .bak files.\n";
`rm $new_name/*.bak`;


