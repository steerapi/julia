## generic complex number definitions ##

abstract Complex{T<:Real} <: Number

iscomplex(x::Complex) = true
iscomplex(x::Number) = false

real_valued(z::Complex)    = (imag(z) == 0)
integer_valued(z::Complex) = (real_valued(z) && integer_valued(real(z)))

real(x::Real) = x
imag(x::Real) = convert(typeof(x), 0)

isfinite(z::Complex) = isfinite(real(z)) && isfinite(imag(z))
reim(z) = (real(z), imag(z))

function show(z::Complex)
    r, i = reim(z)
    if isnan(r) || isfinite(i)
        show(r)
        if signbit(i) == -1 && !isnan(i)
            i = -i
            print(" - ")
        else
            print(" + ")
        end
        show(i)
        if !(isa(i,Int) || isa(i,Rational) ||
             isa(i,Float) && isfinite(i))
            print("*")
        end
        print("im")
    else
        print("complex(",r,",",i,")")
    end
end

## packed complex float types ##

bitstype 128 Complex128 <: Complex{Float64}

function complex128(r::Float64, i::Float64)
    box(Complex128,
        or_int(shl_int(zext_int(Complex128,unbox64(i)),unbox32(64)),
               zext_int(Complex128,unbox64(r))))
end

complex128(r::Real, i::Real) = complex128(float64(r),float64(i))

real(c::Complex128) = boxf64(trunc64(unbox(Complex128,c)))
imag(c::Complex128) = boxf64(trunc64(ashr_int(unbox(Complex128,c), unbox32(64))))

pi(z::Complex128) = pi(Float64)
pi(::Type{Complex128}) = pi(Float64)

convert(::Type{Complex128}, x::Real) = complex128(x,zero(x))
convert(::Type{Complex128}, z::Complex) = complex128(real(z),imag(z))

promote_rule(::Type{Complex128}, ::Type{Float64}) = Complex128
promote_rule(::Type{Complex128}, ::Type{Float32}) = Complex128
promote_rule{S<:Real}(::Type{Complex128}, ::Type{S}) =
    (P = promote_type(Float64,S);
     is(P,Float64) ? Complex128 : ComplexPair{P})

function read(s, ::Type{Complex128})
    r = read(s,Float64)
    i = read(s,Float64)
    complex128(r,i)
end
function write(s, z::Complex128)
    write(s,real(z))
    write(s,imag(z))
end

sizeof(::Type{Complex128}) = 16

#float64(z::Complex) = convert(Complex128, z)

bitstype 64 Complex64 <: Complex{Float32}

function complex64(r::Float32, i::Float32)
    box(Complex64,
        or_int(shl_int(zext_int(Complex64,unbox32(i)),unbox32(32)),
               zext_int(Complex64,unbox32(r))))
end

complex64(r::Real, i::Real) = complex64(float32(r),float32(i))

real(c::Complex64) = boxf32(trunc32(unbox(Complex64,c)))
imag(c::Complex64) = boxf32(trunc32(ashr_int(unbox(Complex64,c), unbox32(32))))

pi(z::Complex64) = pi(Float32)
pi(::Type{Complex64}) = pi(Float32)

convert(::Type{Complex64}, x::Real) = complex64(x,zero(x))
convert(::Type{Complex64}, z::Complex) = complex64(real(z),imag(z))

promote_rule(::Type{Complex64}, ::Type{Float64}) = Complex128
promote_rule(::Type{Complex64}, ::Type{Float32}) = Complex64
promote_rule{S<:Real}(::Type{Complex64}, ::Type{S}) =
    (P = promote_type(Float32,S);
     is(P,Float64) ? Complex128 :
     is(P,Float32) ? Complex64  : ComplexPair{P})
promote_rule(::Type{Complex128}, ::Type{Complex64}) = Complex128

function read(s, ::Type{Complex64})
    r = read(s,Float32)
    i = read(s,Float32)
    complex64(r,i)
end
function write(s, z::Complex64)
    write(s,real(z))
    write(s,imag(z))
end

sizeof(::Type{Complex64})  =  8

#float32(z::Complex) = convert(Complex64, z)

complex(x::Float64, y::Float64) = complex128(x, y)
complex(x::Float32, y::Float32) = complex64(x, y)
complex(x::Float, y::Float) = complex(promote(x,y)...)
complex(x::Float, y::Real) = complex(promote(x,y)...)
complex(x::Real, y::Float) = complex(promote(x,y)...)
complex(x::Float) = complex(x, zero(x))


## complex with arbitrary component type ##

type ComplexPair{T<:Real} <: Complex{T}
    re::T
    im::T
end
ComplexPair(x::Real, y::Real) = ComplexPair(promote(x,y)...)
ComplexPair(x::Real) = ComplexPair(x, zero(x))

real(z::ComplexPair) = z.re
imag(z::ComplexPair) = z.im

convert{T<:Real}(::Type{ComplexPair{T}}, x::T) =
    ComplexPair(x, convert(T,0))
convert{T<:Real}(::Type{ComplexPair{T}}, x::Real) =
    ComplexPair(convert(T,x), convert(T,0))
convert{T<:Real}(::Type{ComplexPair{T}}, z::Complex) =
    ComplexPair(convert(T,real(z)),convert(T,imag(z)))

promote_rule{T<:Real}(::Type{ComplexPair{T}}, ::Type{T}) =
    ComplexPair{T}
promote_rule{T<:Real,S<:Real}(::Type{ComplexPair{T}}, ::Type{S}) =
    ComplexPair{promote_type(T,S)}
promote_rule{T<:Real,S<:Real}(::Type{ComplexPair{T}}, ::Type{ComplexPair{S}}) =
    ComplexPair{promote_type(T,S)}
promote_rule{T<:Real}(::Type{ComplexPair{T}}, ::Type{Complex128}) =
    (P = promote_type(Float64,T);
     is(P,Float64) ? Complex128 : ComplexPair{P})
promote_rule{T<:Real}(::Type{ComplexPair{T}}, ::Type{Complex64}) =
    (P = promote_type(Float32,T);
     is(P,Float64) ? Complex128 : is(P,Float32) ? Complex64  : ComplexPair{P})

complex(x, y) = ComplexPair(x, y)
complex(x) = ComplexPair(x)

pi{T}(z::ComplexPair{T}) = pi(T)
pi{T}(::Type{ComplexPair{T}}) = pi(T)


## singleton type for imaginary unit constant ##

type ImaginaryUnit <: Complex; end
const im = ImaginaryUnit()

convert{T<:Real}(::Type{ComplexPair{T}}, ::ImaginaryUnit) =
    ComplexPair(zero(T),one(T))
convert(::Type{Complex128}, ::ImaginaryUnit) = complex128(0,1)
convert(::Type{Complex64},  ::ImaginaryUnit) = complex64(0,1)

real(::ImaginaryUnit) = 0
imag(::ImaginaryUnit) = 1

promote_rule{T<:Complex}(::Type{ImaginaryUnit}, ::Type{T}) = T
promote_rule{T<:Real}(::Type{ImaginaryUnit}, ::Type{T}) = ComplexPair{T}
promote_rule(::Type{ImaginaryUnit}, ::Type{Float64}) = Complex128
promote_rule(::Type{ImaginaryUnit}, ::Type{Float32}) = Complex64

## We might want these rules, but it's iffy:
# *(x::Real, ::ImaginaryUnit) = complex(zero(x), x)
# *(::ImaginaryUnit, x::Real) = complex(zero(x), x)


## functions of complex numbers ##

==(z::Complex, w::Complex) = (real(z) == real(w) && imag(z) == imag(w))
==(z::Complex, x::Real) = (real(z)==x && imag(z)==0)
==(x::Real, z::Complex) = (real(z)==x && imag(z)==0)

isequal(z::Complex, w::Complex) =
    isequal(real(z),real(w)) && isequal(imag(z),imag(w))

hash(z::Complex) = bitmix(hash(real(z)),hash(imag(z)))

conj(z::Complex) = complex(real(z),-imag(z))
abs(z::Complex)  = hypot(real(z), imag(z))
abs2(z::Complex) = real(z)*real(z) + imag(z)*imag(z)
inv(z::Complex)  = conj(z)/abs2(z)

-(z::Complex) = complex(-real(z), -imag(z))
+(z::Complex, w::Complex) = complex(real(z) + real(w), imag(z) + imag(w))
-(z::Complex, w::Complex) = complex(real(z) - real(w), imag(z) - imag(w))
*(z::Complex, w::Complex) = complex(real(z) * real(w) - imag(z) * imag(w),
                                    real(z) * imag(w) + imag(z) * real(w))

/(z::Number, w::Complex) = z*inv(w)
/(z::Complex, x::Real) = complex(real(z)/x, imag(z)/x)

function /(a::Complex, b::Complex)
    are = real(a); aim = imag(a); bre = real(b); bim = imag(b)
    abr = abs(bre)
    abi = abs(bim)
    if abr <= abi
        r = bre / bim
        den = bim * (1 + r*r)
        complex((are*r + aim)/den, (aim*r - are)/den)
    else
        r = bim / bre
        den = bre * (1 + r*r)
        complex((are + aim*r)/den, (aim - are*r)/den)
    end
end

function /(a::Real, b::Complex)
    bre = real(b); bim = imag(b)
    abr = abs(bre)
    abi = abs(bim)
    if abr <= abi
        r = bre / bim
        den = bim * (1 + r*r)
        complex(a*r/den, -a/den)
    else
        r = bim / bre
        den = bre * (1 + r*r)
        complex(a/den, -a*r/den)
    end
end

function sqrt(z::Complex)
    rz = float(real(z))
    iz = float(imag(z))
    T = promote_type(typeof(rz),typeof(z))
    r = sqrt(0.5*(hypot(rz,iz)+abs(rz)))
    if r == 0
        return convert(T,complex(0.0, iz))
    end
    if rz >= 0
        return convert(T,complex(r, 0.5*iz/r))
    end
    return convert(T,complex(0.5*abs(iz)/r, iz >= 0 ? r : -r))
end

cis(theta::Real) = complex(cos(theta),sin(theta))
function cis(z::Complex)
    v = 1/exp(imag(z))
    complex(v*cos(real(z)), v*sin(real(z)))
end

arg(z::Complex) = atan2(imag(z), real(z))

function sin(z::Complex)
    u = exp(imag(z))
    v = 1/u
    rz = real(z)
    u = 0.5(u+v)
    v = u-v
    complex(u*sin(rz), v*cos(rz))
end

function cos(z::Complex)
    u = exp(imag(z))
    v = 1/u
    rz = real(z)
    u = 0.5(u+v)
    v = u-v
    complex(u*cos(rz), -v*sin(rz))
end

function log(z::Complex)
    ar = abs(real(z))
    ai = abs(imag(z))
    if ar < ai
        r = ar/ai
        re = log(ai) + 0.5*log1p(r*r)
    else
        r = ai/ar
        re = log(ar) + 0.5*log1p(r*r)
    end
    complex(re, atan2(imag(z), real(z)))
end

function exp(z::Complex)
    er = exp(real(z))
    complex(er*cos(imag(z)), er*sin(imag(z)))
end

function ^{T<:Complex}(z::T, p::T)
    realp = real(p)
    if imag(p) == 0
        if realp == 0
            return one(z)
        elseif realp == 1
            return z
        elseif realp == 2
            return z*z
        elseif realp == 0.5
            return sqrt(z)
        end
    end
    r = abs(z)
    rp = r^realp
    realz = real(z)
    zer = zero(r)
    if imag(p) == 0
        ip = itrunc(realp)
        if ip == realp
            # integer multiples of pi/2
            if imag(z) == 0 && realz < 0
                return complex(isodd(ip) ? -rp : rp, zer)
            elseif realz == 0 && imag(z) < 0
                if isodd(ip)
                    return complex(zer, isodd(div(ip-1,2)) ? rp : -rp)
                else
                    return complex(isodd(div(ip,2)) ? -rp : rp, zer)
                end
            elseif realz == 0 && imag(z) > 0
                if isodd(ip)
                    return complex(zer, isodd(div(ip-1,2)) ? -rp : rp)
                else
                    return complex(isodd(div(ip,2)) ? -rp : rp, zer)
                end
            end
        else
            dr = realp*2
            ip = itrunc(dr)
            # 1/2 multiples of pi
            if ip == dr && imag(z) == 0
                if realz < 0
                    return complex(zer, isodd(div(ip-1,2)) ? -rp : rp)
                elseif realz >= 0
                    return complex(rp, zer)
                end
            end
        end
    end
    theta = atan2(imag(z), realz)
    ntheta = realp*theta
    if imag(p) != 0
        rp = rp*exp(-imag(p)*theta)
        ntheta = ntheta + imag(p)*log(r)
    end
    complex(rp*cos(ntheta), rp*sin(ntheta))
end

function tan(z::Complex)
    u = exp(imag(z))
    v = 1/u
    u = 0.5(u+v)
    v = u-v
    sinre = sin(real(z))
    cosre = cos(real(z))
    d = cosre*cosre + v*v
    complex(sinre*cosre/d, u*v/d)
end

function asin(z::Complex)
    re = 1 - (real(z)*real(z) - imag(z)*imag(z))
    im = -2real(z)*imag(z)
    x = sqrt(complex(re,im))
    re = real(x) - imag(z)
    im = imag(x) + real(z)
    complex(atan2(im, re), -log(hypot(re, im)))
end

function acos(z::Complex)
    re = 1 - (real(z)*real(z) - imag(z)*imag(z))
    im = -2real(z)*imag(z)
    x = sqrt(complex(re,im))
    re = real(z) - imag(x)
    im = imag(z) + real(x)
    complex(atan2(im, re), -log(hypot(re, im)))
end

function atan(z::Complex)
    xsq = real(z)*real(z)
    ysq = imag(z)*imag(z)
    m1y = 1-imag(z)
    yp1 = 1+imag(z)
    m1ysq = m1y*m1y
    yp1sq = yp1*yp1
    complex(0.5(atan2(real(z),m1y) - atan2(-real(z),yp1)),
            0.25*log((yp1sq + xsq)/(xsq + m1ysq)))
end

function sinh(z::Complex)
    u = exp(real(z))
    v = 1/u
    u = 0.5(u+v)
    v = u-v
    complex(v*cos(imag(z)), u*sin(imag(z)))
end

function cosh(z::Complex)
    u = exp(real(z))
    v = 1/u
    u = 0.5(u+v)
    v = u-v
    complex(u*cos(imag(z)), v*sin(imag(z)))
end

function tanh(z::Complex)
    cosim = cos(imag(z))
    u = exp(real(z))
    v = 1/u
    u = 0.5(u+v)
    v = u-v
    d = cosim*cosim + v*v
    complex(u*v/d, sin(imag(z))*cosim/d)
end

asinh(z::Complex) = log(z + sqrt(z*z + 1))
acosh(z::Complex) = log(z + sqrt(z*z - 1))
atanh(z::Complex) = log(sqrt((1+z)/(1-z)))
