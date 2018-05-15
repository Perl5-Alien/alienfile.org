## Alien::Base 0.020 and #native

By <b>Graham Ollis</b> on 15 July 2015

This week we rolled out the latest version of <a 
href="https://metacpan.org/pod/Alien::Base">Alien::Base</a> which 
includes a new feature and a bug fix.  The most important change in this 
version are the two new avenues of communication that we have adopted, 
so I will discuss that first.

The first is that we have established the <a 
href="https://chat.mibbit.com/?channel=%23native&server=irc.perl.org">#native</a> 
channel on irc.perl.org to discuss interactions with native interfaces.  
This includes <a href="https://metacpan.org/pod/Alien">Alien</a> in 
general, <a href="https://metacpan.org/pod/Alien::Base">Alien::Base</a> 
specifically, and we also intend it to be a place to discuss <a 
href="https://metacpan.org/pod/FFI::Platypus">FFI</a> (Foreign Function 
Interface or NativeCall), as there is a degree of overlap for the people 
involved.  You can now click on a big red button from the metacpan page 
for the project that will log you into IRC and allow you to start asking 
questions (or complain at us if that is what needs doing).

The second communication improvement is the creation of an Alien::Base 
FAQ (see <a 
href="https://metacpan.org/pod/Alien::Base::FAQ">Alien::Base::FAQ</a>).  
I promised this last year but only recently got around to writing it.  
It consists of a number of questions (and corresponding answers) that I 
personally had when I was trying to figure out how to develop my own <a 
href="https://metacpan.org/pod/Alien::Base">Alien::Base</a> based Alien 
distributions.  I’m hoping this guide will help those that are getting 
started now.

One thing that working on the FAQ reminded me of is that although it is 
relatively simple to create and maintain an <a 
href="https://metacpan.org/pod/Alien::Base">Alien::Base</a> based Alien 
distribution if your package uses autoconf and pkg-config, it is a 
little more challenging if your package does not use these tools.  
Things that are doable, but present their own set of challenges include 
CMake, autoconf-like, and vanilla makefiles.  I’ve done my best to 
illustrate the techniques to work with these technologies, usually only 
a few lines of code need to be added to your <tt>Build.PL</tt>.  I wrote 
<a href="https://metacpan.org/pod/Alien::Libbz2">Alien::Libbz2</a> while 
I was working on the FAQ to serve as a working example of a non-autoconf 
/ non-pkg-config package, and also to verify the techniques are 
correct.

For those who use Dist::Zilla, I used <a 
href="https://metacpan.org/pod/Dist::Zilla::Plugin::Alien">Dist::Zilla::Plugin::Alien</a> 
when writing <a 
href="https://metacpan.org/pod/Alien::Libbz2">Alien::Libbz2</a>, so it 
serves as a good example of how to bridge the worlds of Dist::Zilla and 
Alien.  While working on this, I worked with Zakariyya Mughal to drive 
development of the plugin itself.  The plugin is now up to date once 
again feature wise with <a 
href="https://metacpan.org/pod/Alien::Base">Alien::Base</a>.

Aside from the new IRC channel and the FAQ, we have always had a mailing 
list and use the project GitHub to track issues and pull requests.  With 
all of these ways to interact with the Alien::Base team you may be 
wondering what the best way to get your questions answered is.  As it 
turns out, the preferred way of contacting us is whatever is whichever 
of those you prefer!

<a href="https://groups.google.com/forum/#!forum/perl5-alien">https://groups.google.com/forum/#!forum/perl5-alien</a>

<a href="https://github.com/Perl5-Alien/Alien-Base/issues">https://github.com/Perl5-Alien/Alien-Base/issues</a>

Now I also mentioned a new feature.  New in version 0.020 is the 
inclusion of command helpers that can be used to compute build and 
install commands at build time.  These are used if the packages needs to 
be built from source.  To see why this is useful, consider packages that 
require the GNU version of make to build from source.  Normally when 
creating your Alien module, you’d include something like this in your 
Build.PL file:

```
use Alien::Base::ModuleBuild;
Alien::Base::ModuleBuild->new(
  dist_name => 'Alien::Foo',
  alien_build_commands => [
    'make',
  ],
  alien_install_commands => [
    'make install PREFIX=%s',
  ],
)->create_build_script;
```

The problem is that while make will invoke GNU make on Linux, it will 
typically fail on FreeBSD or OS X where the GNU version is usually 
either gmake, or just not provided.  The core module Config comes with a 
guess as to the correct name of GNU make, but I recommend not using it 
as it is frequently wrong.  Instead you can use <a 
href="https://metacpan.org/pod/Alien::gmake">Alien::gmake</a>, which is 
itself an alien module that will detect a locally installed GNU make, or 
build and install it for you.

```
use Alien::Base::ModuleBuild;
Alien::Base::ModuleBuild->new(
  dist_name => 'Alien::Foo',
  # this will make Alien::gmake a build prereq 
  # if our library needs to be built from source
  alien_bin_requires => { 'Alien::gmake' => 0 },
  alien_helper => { gmake => 'Alien::gmake->exe' },
  # %{gmake} gets replaced by the result of
  # Alien::gmake->exe
  alien_build_commands => [
    '%{gmake}',
  ],
  alien_install_commands => [
    '%{gmake} install PREFIX=%s',
  ],
)->create_build_script;
```

The helper is specified as Perl code in a string that gets evaluated 
during the build or install steps.  You can include arbitrary Perl here 
to compute the correct command or arguments as you need them.  
Unfortunately a code reference cannot be used, because of the 
limitations of Module::Build.

Because makefile compatibility is a persistent problem with some 
packages, <a href="https://metacpan.org/pod/Alien::gmake">Alien::gmake</a>
provides its own <tt>%{gmake}</tt> helper, which you can use so long as you 
require a recent enough
<a href="https://metacpan.org/pod/Alien::gmake">Alien::gmake</a>.

```
use Alien::Base::ModuleBuild;
Alien::Base::ModuleBuild->new(
  dist_name => 'Alien::Foo',
  # The built in %{gmake} helper was added to
  # Alien::gmake in version 0.09.
  alien_bin_requires => { 'Alien::gmake' => 0.09 },
  # no longer need to define our own %{gmake}
  alien_build_commands => [
    '%{gmake}',
  ],
  alien_install_commands => [
    '%{gmake} install PREFIX=%s',
  ],
)->create_build_script;
```

Prior to <a href="https://metacpan.org/pod/Alien::Base">Alien::Base</a> 
0.020 in order to include this sort of logic you would have to use <a 
href="https://metacpan.org/pod/Alien::gmake">Alien::gmake</a> in your 
<tt>Build.PL</tt>, which would make it a configure_requires requirement.  
This is undesirable, because you won’t need <a 
href="https://metacpan.org/pod/Alien::gmake">Alien::gmake</a> if you are 
using the system version of a library!  The <tt>alien_bin_requires</tt> 
are dynamic prerequisites that are added only if you are building from 
source.

Next week I intend on writing about <a 
href="https://metacpan.org/pod/Alien::Base">Alien::Base</a>, and this 
time I will focus system integrators, distribution packagers and 
destdir.  See you then.

<hr>

This article was originally posted to [blogs.perl.org]: 
[here](http://blogs.perl.org/users/graham_ollis/2015/07/alienbase-0020-and-native.html)