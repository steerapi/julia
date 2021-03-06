## native julia error handling ##

error(e::Exception) = throw(e)
error{E<:Exception}(::Type{E}) = throw(E())
error(s::ByteString) = throw(ErrorException(s))
error(s...) = error(print_to_string(print, s...))

## system error handling ##

errno() = ccall(:jl_errno, Int32, ())
strerror(e::Int) = ccall(:jl_strerror, Any, (Int32,), int32(e))::ByteString
strerror() = strerror(errno())
system_error(p::String, b::Bool) = b ? error(SystemError(p)) : nothing
system_error(s::Symbol, b::Bool) = system_error(string(s), b)

## assertion functions and macros ##

assert_test(b::Bool) = b
assert_test(b::AbstractArray{Bool}) = all(b)
assert(x) = assert(x,'?')
assert(x,labl) = assert_test(x) ? nothing : error("assertion failed: ", labl)

macro assert(ex)
    :(assert_test($ex) ? nothing : error("assertion failed: ", $string(ex)))
end
