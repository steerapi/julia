type Rational{T<:Int} <: Real
    num::T
    den::T

    function Rational{T<:Int}(num::T, den::T)
        if num != 0 || den != 0
            g = gcd(den, num)
            num = div(num, g)
            den = div(den, g)
        end
        new(num, den)
    end

    Rational(n::Int, d::Int) = Rational(promote(n,d)...)
    Rational(n::Int) = new(n, one(n))
end

//(n::Int, d::Int) = Rational(n,d)
//(x::Rational, y::Int) = x.num // (x.den*y)
//(x::Int, y::Rational) = (x*y.den) // y.num

function show(x::Rational)
    show(num(x))
    print("//")
    show(den(x))
end

convert{T}(::Type{Rational{T}}, x::T) = Rational(x, convert(T,1))
convert{T}(::Type{Rational{T}}, x::Int) = Rational(convert(T,x), convert(T,1))
convert{T}(::Type{Rational{T}}, x::Rational) = Rational(convert(T,x.num),convert(T,x.den))
convert{T<:Float}(::Type{T}, x::Rational) = convert(T,x.num)/convert(T,x.den)
convert{T<:Int}(::Type{T}, x::Rational) = div(convert(T,x.num),convert(T,x.den))

function convert{T}(::Type{Rational{T}}, x::Float, tol::Real)
    if isnan(x); return zero(T)//zero(T); end
    if isinf(x); return sign(x)//zero(T); end
    y = x
    a = d = one(T)
    b = c = zero(T)
    while true
        f = convert(T,round(y)); y -= f
        a, b, c, d = f*a+c, f*b+d, a, b
        if y == 0 || abs(a/b-x) <= tol
            return a//b
        end
        y = 1/y
    end
end

convert{T}(rt::Type{Rational{T}}, x::Float) = convert(rt,x,eps(x))

promote_rule{T<:Int}(::Type{Rational{T}}, ::Type{T}) = Rational{T}
promote_rule{T,S<:Int}(::Type{Rational{T}}, ::Type{S}) = Rational{promote_type(T,S)}
promote_rule{T,S}(::Type{Rational{T}}, ::Type{Rational{S}}) = Rational{promote_type(T,S)}
promote_rule{T,S<:Float}(::Type{Rational{T}}, ::Type{S}) = promote_type(T,S)

num(x::Int) = x
den(x::Int) = one(x)
num(x::Rational) = x.num
den(x::Rational) = x.den
sign(x::Rational) = sign(x.num)
signbit(x::Rational) = signbit(x.num)
copysign(x::Rational, y::Real) = copysign(x.num,y) // x.den
copysign(x::Rational, y::Rational) = copysign(x.num,y.num) // x.den

-(x::Rational) = (-x.num) // x.den
+(x::Rational, y::Rational) = (x.num*y.den + x.den*y.num) // (x.den*y.den)
-(x::Rational, y::Rational) = (x.num*y.den - x.den*y.num) // (x.den*y.den)
*(x::Rational, y::Rational) = (x.num*y.num) // (x.den*y.den)
/(x::Rational, y::Rational) = (x.num*y.den) // (x.den*y.num)
/(x::Rational, z::Complex) = inv(z/x)

isnan(x::Rational) = x.den == 0 && x.num == 0
isinf(x::Rational) = x.den == 0 && x.num != 0
isfinite(x::Rational) = x.den != 0

isequal(x::Rational, y::Rational) = x.num == y.num && x.den == y.den
isequal(x::Rational, y::Int) = x.den == 1 && x.num == y
isequal(x::Number, y::Rational) = isequal(y, x)

==(x::Rational, y::Rational) = !isnan(x) && x.num == y.num && x.den == y.den
!=(x::Rational, y::Rational) =  isnan(x) || x.num != y.num || x.den != y.den
<=(x::Rational, y::Rational) = float(x) <= float(y)
< (x::Rational, y::Rational) = float(x) < float(y)
>=(x::Rational, y::Rational) = y <= x
> (x::Rational, y::Rational) = y < x

div(x::Rational, y::Rational) = div(x.num*y.den, x.den*y.num)
div(x::Real    , y::Rational) = div(x*y.den, y.num)
div(x::Rational, y::Real    ) = div(x.num, x.den*y)

fld(x::Rational, y::Rational) = fld(x.num*y.den, x.den*y.num)
fld(x::Real    , y::Rational) = fld(x*y.den, y.num)
fld(x::Rational, y::Real    ) = fld(x.num, x.den*y)

rational(x::Real) = rational(x, eps(x))
rational(x::Rational, tol::Real) = x
rational(x::Int, tol::Real) = x // one(x)
rational(x::Float32, tol::Real) = convert(Rational{Int32}, x, tol)
rational(x::Float64, tol::Real) = convert(Rational{Int64}, x, tol)
rational(z::Complex) = Complex(rational(real(z)), rational(imag(z)))
rational(z::Complex, tol::Real) =
    (tol /= sqrt(2); Complex(rational(real(z), tol), rational(imag(z), tol)))

int(x::Rational) = div(x.num, x.den)
float(x::Rational) = x.num/x.den