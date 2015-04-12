# This script converts the data set from the `Text::Unidecode` Perl module into
# Rust code that creates a compile-time hash map. Empty strings are omitted from
# the map to save space, as `rust-unidecode` automatically transliterates
# unknown characters as empty strings.
#
# The Rust code is printed to standard output for convenience, so it will need
# to be piped into a file.
#
# Example usage:
#     perl generate_map.pl > ../src/data.rs

use strict;
use warnings;
use utf8;
use Text::Unidecode;

print("// File autogenerated with /scripts/generate_map.pl\n\n");
print("[\n");
for (my $i = 0; $i <= 0xffff; $i++) {
    # Verify that number is valid Unicode
    if (($i < 0 || $i > 0xD7FF) && ($i < 0xE000 || $i > 0x10FFFF)) {
        next;
    }

    my $k = "'\\u\{" . sprintf("%x", $i) . "\}'";

    my $v = "\"";
    my $ch = '';
    foreach $ch (split //, unidecode(chr($i))) {
        $v .= "\\u\{" . sprintf("%x", ord($ch)) . "\}";
    }
    $v .= "\"";

    # Skip empty strings to reduce size of hash table
    if (length $v > 2) {
        print("    ($k, $v),\n");
    }
}
print("]\n");
