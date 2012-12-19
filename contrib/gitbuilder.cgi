#!/usr/bin/perl
# Imported from http://tracker.newdream.net/issues/1655
# Author: Sage Weil
#
# It's just a quick perl hack. What it really should do is make javascript
# and <div>s to fetch the results for each builder in parallel.
#

use CGI qw(:standard);

my $url = param('url');

# if you change this, update robots.txt as well

my @urls = (
	'http://downloads.kitenet.net/git-annex/OSX/autobuild/',
        'http://www.sgenomics.org/~jtang/gitbuilder-git-annex-x00-x86_64-apple-darwin10.8.0-binary/',
        'http://www.sgenomics.org/~jtang/gitbuilder-git-annex-x00-x86_64-apple-darwin10.8.0/',
);

my $base_url = 'http://www.sgenomics.org/~jtang/gitbuilder-git-annex';

print "Content-type: text/html\n\n";

sub summarize_gitbuilder {
        my ($url, $raw) = @_;
        my ($b) = $raw =~ /(<div id="most_recent">.*)/;
        my ($c) = split(/<\/div>/, $b);
        $c =~ s/Most Recent://;
        $c =~ s/<a href="#/<a href="$url#/g;
        return $c . '</div>';
}

print "<html>\n";
print "<head>\n";
print "<script src=\"http://code.jquery.com/jquery-latest.js\"></script>\n";
print "<title>Gitbuilders</title><link rel=\"stylesheet\" type=\"text/css\" href=\"gitbuilder.css\" />";
print "<META HTTP-EQUIV=\"REFRESH\" CONTENT=\"600\">\n";
print "</head>\n";
print "<body>";

my $script = '';

if ($url) {
        my $raw = `curl -s $url 2>&1`;
        my $summary = summarize_gitbuilder($url, $raw);
        print $summary;
} else {
        print "<table>";
        my $n = 1;
        for my $url (@urls) {
                print "<tr><td align=left id=\"most_recent\" 
nowrap=\"nowrap\"><a href=\"$url\">$url</a></td><td id=\"most_recent\"><div 
id=\"num$n\">...loading...</div></td></tr>\n";
                $script .= "\$\(\"#num$n\"\).load(\"$base_url/gitbuilder.cgi?url=$url\");\n";
                $n++;
        }
        print "</table>";
}

print " 
<script>
$script
</script>
";

print "</body></html>\n";
