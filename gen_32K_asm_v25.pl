use warnings;
use strict;

my %trans_templates = (
EQUAL_PULSE => '
BYTE $DC
BYTE $FC, $FC, $FC, $FC, $FC, $FC
BYTE $DC
BYTE $FC, $FC, $FC, $FC, $FC, $FC
',
VERT_SYNC_PULSE => '
BYTE $DC, $DC, $DC, $DC, $DC, $DC
BYTE $FC
BYTE $DC, $DC, $DC, $DC, $DC, $DC
BYTE $FC
',
BLACK_HSYNC => '
BYTE $DC
BYTE $FC, $FC, $FC, $FC, $FC
BYTE $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
',
BLACK_HSYNC_EF1 => '
BYTE $9C
BYTE $BC, $BC, $BC, $BC, $BC
BYTE $BC, $BC, $BC, $BC, $BC, $BC, $BC, $BC
',
HSYNC_BLANK => '
BYTE $CC
BYTE $EC, $EC, $EC, $EC, $EC
BYTE $EC, $EC, $EC, $EC, $EC, $EC, $EC, $EC
',
BLACK_HSYNC_INT_EF1 => '
BYTE $8C
BYTE $BC, $BC, $BC, $BC, $BC, $BC
BYTE $BC, $BC, $BC, $BC, $BC
BYTE $B4
BYTE $B4
',
HSYNC_DMA => '
BYTE $CC
BYTE $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
BYTE $FC, $FC, $FC
BYTE $FC, $FC
',
HSYNC_DMA_EF1 => '
BYTE $8C
BYTE $B8, $B8, $B8, $B8, $B8, $B8, $B8, $B8
BYTE $BC, $BC, $BC
BYTE $BC, $BC
',
BLACK_HSYNC_RESET => '
BYTE $CC
BYTE $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
BYTE $FC, $FC
BYTE $7C
',
DUMMY => '
BYTE $FF
'
);

my @trans_pass1 =
(
"4:EQUAL_PULSE",
"4:VERT_SYNC_PULSE",
"4:EQUAL_PULSE",

"2:HSYNC_BLANK",

"247:BLACK_HSYNC",

"1:BLACK_HSYNC_RESET"
);

my @trans_pass2 =
(
"4:EQUAL_PULSE",
"4:VERT_SYNC_PULSE",
"4:EQUAL_PULSE",

"2:HSYNC_BLANK",

"27:BLACK_HSYNC",
"1:BLACK_HSYNC_EF1",       
"1:BLACK_HSYNC_INT_EF1",   # 0 before dma
"1:BLACK_HSYNC_EF1",       # 14 before dma   
"1:BLACK_HSYNC_EF1",       # 14 before dma

"124:HSYNC_DMA",           # 1 before dma
"4:HSYNC_DMA_EF1",

"88:BLACK_HSYNC",
"1:BLACK_HSYNC_RESET"
);

my $repeat_count;
my $tran_code;
my $scan_lines_gen = 0;
my $bytes_written = 0;

open(OUTPUT,">",'gen_32k_asm_v20220121.asm') or die "Can't open the output file!\n";

print OUTPUT "  CPU 1802\n";
print OUTPUT "\n";
print OUTPUT "  ORG \$0000\n";
print OUTPUT "\n";

$scan_lines_gen = 0;
$bytes_written = 0;

for my $transaction (@trans_pass1) {

  ($repeat_count,$tran_code) = split(':',$transaction);
  unless ( exists($trans_templates{$tran_code})) {
    die "Tran Code $tran_code does not exist in templates\n";
  }
  
  for (my $lcv1 = 1; $lcv1 <= $repeat_count; $lcv1++) {
    my $temp_string = $trans_templates{$tran_code};
    $temp_string =~ s/BYTE/  BYTE/g;
    print OUTPUT $temp_string;
    
    if ( $tran_code eq 'EQUAL_PULSE' || $tran_code eq 'VERT_SYNC_PULSE' ) {
      $bytes_written = $bytes_written + 14;
    }
    else {
      $bytes_written = $bytes_written + 14;
    }
    $scan_lines_gen++;
  }

}

print "Bytes written at filler time: $bytes_written\n";

while ($bytes_written < 16384) {
    my $temp_string = $trans_templates{DUMMY};
    $temp_string =~ s/BYTE/  BYTE/g;
    print OUTPUT $temp_string;

    $bytes_written = $bytes_written + 1;
}

print "Pass1:\n";
print "Total scan lines generated: $scan_lines_gen\n";
print "Total bytes written: $bytes_written\n";

$scan_lines_gen = 0;
$bytes_written = 0;

for my $transaction (@trans_pass2) {

  ($repeat_count,$tran_code) = split(':',$transaction);
  unless ( exists($trans_templates{$tran_code})) {
    die "Tran Code $tran_code does not exist in templates\n";
  }
  
  for (my $lcv1 = 1; $lcv1 <= $repeat_count; $lcv1++) {
    my $temp_string = $trans_templates{$tran_code};
    $temp_string =~ s/BYTE/  BYTE/g;
    print OUTPUT $temp_string;
    
    if ( $tran_code eq 'EQUAL_PULSE' || $tran_code eq 'VERT_SYNC_PULSE' ) {
      $bytes_written = $bytes_written + 14;
    }
    else {
      $bytes_written = $bytes_written + 14;
    }
    $scan_lines_gen++;
  }

}

print "Bytes written at filler time: $bytes_written\n";

while ($bytes_written < 16384) {
    my $temp_string = $trans_templates{DUMMY};
    $temp_string =~ s/BYTE/  BYTE/g;
    print OUTPUT $temp_string;
    $bytes_written = $bytes_written + 1;
}

print "Pass2:\n";
print "Total scan lines generated: $scan_lines_gen\n";
print "Total bytes written: $bytes_written\n";

print OUTPUT "\n";
print OUTPUT "  END\n";
print OUTPUT "\n";

close(OUTPUT);

exit 0;