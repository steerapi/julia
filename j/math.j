## non-type-specific math functions ##

clamp(x::Real, lo::Real, hi::Real) = (x > hi ? hi : (x < lo ? lo : x))

sec(z) = 1 ./cos(z)
csc(z) = 1 ./sin(z)
cot(z) = 1 ./tan(z)
asec(y) = acos(1 ./y)
acsc(y) = asin(1 ./y)
acot(y) = atan(1 ./y)
sech(z) = 1 ./cosh(z)
csch(z) = 1 ./sinh(z)
coth(z) = 1 ./tanh(z)
asech(y) = acosh(1 ./y)
acsch(y) = asinh(1 ./y)
acoth(y) = atanh(1 ./y)

sinc(x) = x==0 ? one(x)  : (pix = pi(x)*x; sin(pix)/pix)
cosc(x) = x==0 ? zero(x) : (pix = pi(x)*x; cos(pix)/x - sin(pix)/(pix*x))

log(b,x) = log(x)/log(b)

function hypot(x::Real, y::Real)
    x = abs(x)
    y = abs(y)
    if x > y
        r = y/x
        return x*sqrt(1+r*r)
    end
    if y == 0
        return sqrt(y)  # to give same type as other cases
    end
    r = x/y
    return y*sqrt(1+r*r)
end

square(x::Number) = x*x
