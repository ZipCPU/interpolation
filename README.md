# Digital Resampling and Interpolation

Here's a [wonderful
tutorial](https://github.com/ZipCPU/interpolation/raw/master/tutorial.pdf)
on how to do digital resampling and interpolation in general.

You'll also find, within the [rtl](rtl/) directory, examples of both a nearest
[neighbour interpolator](rtl/nearest-neighbor/simpleinterp.v) and a
[linear upsampling interpolator](rtl/lininterp/lininterp.v).  Both have
been discussed on the [ZipCPU blog](http://zipcpu.com): the [nearest neighbour
interpolator here](http://zipcpu.com/dsp/2017/06/06/simple-interpolator.html),
and the [linear interpolator
here](http://zipcpu.com/dsp/2017/07/29/series-linear-interpolation.html).

If time permits, I look forward to adding an improved quadratic interpolator
functionality to the current [quadratic interpolator](rtl/quadratic).  This
current interpolator is a straightforward quadratic-fit based interpolator.  As
such it's performance is, well, ... horrible.
It is useful, however, to get a feel for why this doesn't work.  For that
reason I've placed it here.  When you see the better alternative that I'll
add to the repository later, you'll understand what I mean.

Once I finish with the demonstrating the improved [quadratic
interpolator](rtl/quadratic), and if time then permits, I may yet present
some some other higher order interpolation solutions to this repository.
Splines anyone?


# License

The [tutorial](tutorial.pdf) is offered here under the [Creative Commons,
Attribution-NoDerivations 4.0 International
license](https://creativecommons.org/licenses/by-nd/4.0/legalcode).

The [Verilog source code](rtl/) and software (if any) are released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).  If these conditions
are not sufficient for you, other licenses terms are available for purchase.
