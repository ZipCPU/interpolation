# Digital Resampling and Interpolation

Here's a [wonderful
tutorial](https://github.com/ZipCPU/interpolation/raw/master/tutorial.pdf)
on how to do digital resampling and interpolation in general.

You'll also find, within the [rtl](rtl/) directory, examples of a nearest
[neighbour interpolator](rtl/nearest-neighbor/simpleinterp.v), a
[linear upsampling interpolator](rtl/lininterp/lininterp.v),
and a [quadratic upsampling interpolator](rtl/quadinterp/quadinterp.v).  
All three have been discussed on the [ZipCPU blog](http://zipcpu.com):
the [nearest neighbour interpolator
here](http://zipcpu.com/dsp/2017/06/06/simple-interpolator.html),
the [linear interpolator
here](http://zipcpu.com/dsp/2017/07/29/series-linear-interpolation.html),
and the [quadratic interpolator
here](http://zipcpu.com/dsp/2018/03/30/quadratic.html).

If time permits, I look forward to adding some higher order
interpolation solutions and/or splines to this repository.

# License

The [tutorial](tutorial.pdf) is offered here under the [Creative Commons,
Attribution-NoDerivations 4.0 International
license](https://creativecommons.org/licenses/by-nd/4.0/legalcode).

The Verilog source code and software (if any) are released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).

If these conditions are not sufficient for you, other licenses terms are
available for purchase.
