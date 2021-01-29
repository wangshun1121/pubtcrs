# 第一轮筛选非常简单：TCR的p.adjust<1e-10，而且Reads Count至少为5

$NNN=0;

print "Sample\tcount\tfreq\tcdr3nt\tcdr3aa\tv\td\tj\tVEnd\tDStart\tDEnd\tJStart\tpgen\tpvalue\tqvalue\tStatus\n";
while($Line=<>){
    chomp($Line);
    $ID=(split/\//,$Line)[-1];
    $ID=~s/\.txt//;
    $Q=`wc -l $Line`;
    chomp($Q);
    $N=1;
    open I,"$Line";
    <I>;
    while(<I>){
        chomp;
        my @a=split/\t/;
        if($a[0]<5){last;}
        if($a[-2] eq 'NA'){next;}
        unless($a[-2] < 1e-30){next;}
        
        if($a[3] =~ m/\*/){next;}
        if(length($a[3])<6){next;}
        unless($a[4]=~m/TRBV(\d+)/){next;}
        my $TCR=$1;
        if($TCR eq '22'){next;} # No V22 in DB
        if($TCR eq '8'){next;} # No V8 in DB
        if($TCR<10){$TCR='V0'.$TCR;}
        else{$TCR='V'.$TCR;}
        
        $a[2]="$TCR,$a[3]";
        $_=join("\t",@a);
        print "$ID\t$_\n";
        $N++;
        if($N>$Q/5000){last;}
    }
    close I;

    $NNN++;
    if($NNN % 100 == 0){print STDERR "$NNN\n";}
    elsif($NNN % 10 == 0){print STDERR ". ";}
    else{print STDERR '.';}
    
}
