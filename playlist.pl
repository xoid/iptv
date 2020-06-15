#!/usr/bin/perl -w
use strict;

my @stopwords  = ('Ваша поддержка', 'Обновлён ', 'Группа ', 'Пожертвования', 'webhalpme.ru/iptv', 'Dmitry' );
my @firstwords = ('НТВ', 'Первый канал', 'СТС', 'Cartoon Networks', 'Discovery', 'ТНТ', 'Geo');

system "date > /tmp/check_url.log";

my ($channels, $name, $url);

while (<>)
{
   $_ =~ tr/\015//d; $_ =~ tr/\012//d; # \R\N
   #warn 'bla '.$_;
   if (m/^#EXTINF:.*,(.*)$/)
   {
        $name = undef;
        my $extinf = $1; #warn 'trolol '.$_ . $extinf;
        if (m/tvg-name="(.*?)"/   ) {   $name = $1   }
        if (! $name               ) {   $name = $extinf  }
        if (m/tvg-logo="(.*?)"/   ) {   $channels->{$name}->{logo} = $1   }
   }

   if (m/^[^#]/) # нет решетки в начале значит url
   {
       $url = $_;
       if ( check_url($url) )
       {
            push @{$channels->{$name}->{urls}}, $url;
            warn "pushed url $url to name $name\n";
       }
   }
}

print_channel('НТВ'); print_channel('НТВ HD');
print_channel('Первый канал'); print_channel('Первый канал HD');
print_channel('Мульт');
print_channel('СТС');
print_channel('Cartoon Network'); 
print_channel('Живая планета');
print_channel('Animal Planet');
print_channel('Animal Planet HD');
print_channel('BBC America');
print_channel('Discovery Channel');
print_channel('Discovery HD');
print_channel('Discovery Science');

warn  'KEYS '.sort keys %$channels;
foreach my $name (sort keys %{$channels})
{
    warn "=============================================print it\n";
    next if grep { $name eq $_ } @stopwords;
    warn "lets print name $name\n";
    print_channel($name);
}

exit 0;

sub print_channel
{
  my $name = shift;
  warn "print_channel: $name\n";
  my @urls;
  eval {
         @urls = @{$channels->{$name}->{urls}};
         @urls = do { my %seen; grep { !$seen{$_}++ } @urls }; # unique
       }; warn "empty url list" if $@;
  #warn 'URLS '.@urls;
  return unless @urls;
  print "<div class=channel>\n".$name; 
  my $logo = $channels->{$name}->{logo};
       print " <img src='$logo' width=32 height=32>" if $logo;
  print "<br>\n";
  foreach my $url (@urls)
  {
        print  "<a  href='play?url=$url' onclick='this.style.color=\"green\"; return play_url(this.innerHTML);'>$url</a><br>\n";
        #$url =~ s@.*:(.*)//@vlc://$1@;
        #print  "&nbsp; <a href='$url'> V </a><br>\n";
  }
  print "</div>\n";
}

sub check_url
{
    return 1;
    my $url = shift;
    warn "check_url: $url\n";
    return ! system("curl -r 0-0 -L -s -m 3 '$url' > /dev/null 2>&1");
}

