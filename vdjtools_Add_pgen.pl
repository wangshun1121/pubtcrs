#!/usr/env/perl
# add TCR beta generation probability to vdjtools file

use strict;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use FindBin qw($Bin);
use File::Basename;
use FileHandle;
use Parallel::ForkManager;

our $CPU=`grep proc /proc/cpuinfo|wc -l`; chomp($CPU); # Threads Number

our $input=();
our $out=();
our $threads=$CPU;
our $tmp='/tmp';
our $help;

GetOptions(
 'in=s' => \$input,
 'out=s' => \$out,
 'p|threads=i' => \$threads,
 'tmp=s' => \$tmp,
 'h|help' => \$help
);

my $Mannual=<<M;
perl $0
  为VDJtools格式的输入数据添加一列pgen信息
  运行该脚本需要安装uuid（apt-get install uuid）
    -in         输入文件（vdjtools格式）
    -out        输出文件
    -p|threads  运行线程数[$threads]
    -tmp        临时文件夹[$tmp]

    -h|help     Show this message
M

if($help){print $Mannual; exit();}
unless($input){print $Mannual; exit();}

my $N=0;
my %Pool=();
my %Line=();
open I,$input;
$_=<I>;
while(<I>){
    chomp;
    my @a=split/\t/;
    if($a[3] =~ m/\*/){next;}
    if(length($a[3])<6){next;}
    unless($a[4]=~m/TRBV(\d+)/){next;}
    my $TCR=$1;
    if($TCR eq '22'){next;} # No V22 in DB
    if($TCR eq '8'){next;} # No V8 in DB
    if($TCR<10){$TCR='V0'.$TCR;}
    else{$TCR='V'.$TCR;}
    $Line{$_}="$TCR,$a[3]";
    $Pool{$N}.="$TCR,$a[3]\n";
    $N++;
    if($N == $threads){$N=0;}
    
}
close I;

my $uuid=`uuid`;
chomp($uuid);
my $tmpDir="$tmp/$uuid";

system("mkdir -p $tmpDir");

my $pm=new Parallel::ForkManager($threads);
foreach my $i(keys %Pool){
    # 并行开跑
    my $pid=$pm->start and next;
    open O,">$tmpDir/$i.csv";
    print O $Pool{$i};
    close O;
    my $CMD="$Bin/bin/pgen -i $tmpDir/$i.csv -d $Bin/db -o $tmpDir/$i.txt";
    #print "$CMD\n";
    system($CMD);

    $pm->finish;
}
$pm->wait_all_children;

my %PGEN=();
foreach my $i(keys %Pool){
    open I,"$tmpDir/$i.txt";
    while(<I>){
        chomp;
        $_=~m/pgen\:\ (\S+)\ tcr\: (\S+)$/;
        $PGEN{$2}=$1;
    }
    close I;
}
system("rm -rf $tmpDir");

open I,$input;
open O,">$out";
$_=<I>;
chomp;
print O "$_\tpgen\n";
while(<I>){
    chomp;
    my $P='NA';
    if($PGEN{$Line{$_}}){$P=$PGEN{$Line{$_}};}
    print O "$_\t$P\n";
}
close O;
