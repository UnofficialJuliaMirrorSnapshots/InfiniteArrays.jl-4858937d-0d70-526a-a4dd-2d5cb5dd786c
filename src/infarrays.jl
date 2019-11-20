Array{T}(::UndefInitializer, ::Tuple{Infinity}) where T = throw(ArgumentError("Cannot create infinite Array"))
Array{T}(::UndefInitializer, ::Tuple{Integer, Infinity}) where {T,N} = throw(ArgumentError("Cannot create infinite Array"))
Array{T}(::UndefInitializer, ::Tuple{Infinity, Integer}) where {T,N} = throw(ArgumentError("Cannot create infinite Array"))
Matrix{T}(::UndefInitializer, ::Tuple{Integer, Infinity}) where T = throw(ArgumentError("Cannot create infinite Array"))
Matrix{T}(::UndefInitializer, ::Tuple{Infinity, Integer}) where T = throw(ArgumentError("Cannot create infinite Array"))
Array{T}(::UndefInitializer, ::Tuple{Infinity, Infinity}) where {T,N} = throw(ArgumentError("Cannot create infinite Array"))
Matrix{T}(::UndefInitializer, ::Tuple{Infinity, Infinity}) where T = throw(ArgumentError("Cannot create infinite Array"))

Array{T}(::UndefInitializer, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))

Array{T}(::UndefInitializer, ::Infinity, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))
Array{T}(::UndefInitializer, ::Infinity, ::Integer) where T = throw(ArgumentError("Cannot create infinite Array"))
Array{T}(::UndefInitializer, ::Integer, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))

Matrix{T}(::UndefInitializer, ::Infinity, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))
Matrix{T}(::UndefInitializer, ::Infinity, ::Integer) where T = throw(ArgumentError("Cannot create infinite Array"))
Matrix{T}(::UndefInitializer, ::Integer, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))

Vector{T}(::UndefInitializer, ::Tuple{Infinity}) where T = throw(ArgumentError("Cannot create infinite Array"))
Vector{T}(::UndefInitializer, ::Infinity) where T = throw(ArgumentError("Cannot create infinite Array"))

similar(A::AbstractArray, ::Type{T}, axes::Tuple{OneToInf{Int}}) where T = cache(Zeros{T}(axes))
similar(A::AbstractArray, ::Type{T}, axes::Tuple{OneToInf{Int},OneToInf{Int}}) where T = cache(Zeros{T}(axes))
similar(A::AbstractArray, ::Type{T}, dims::Tuple{Infinity}) where T = cache(Zeros{T}(dims))
similar(A::AbstractArray, ::Type{T}, dims::Tuple{Infinity,Infinity}) where T = cache(Zeros{T}(dims))

similar(::Type{<:AbstractArray{T}}, axes::Tuple{OneToInf{Int}}) where T = cache(Zeros{T}(axes))
similar(::Type{<:AbstractArray{T}}, axes::Tuple{OneToInf{Int},OneToInf{Int}}) where T = cache(Zeros{T}(axes))
similar(::Type{<:AbstractArray{T}}, axes::Tuple{OneToInf{Int},OneTo{Int}}) where T = cache(Zeros{T}(axes))
similar(::Type{<:AbstractArray{T}}, axes::Tuple{OneTo{Int},OneToInf{Int}}) where T = cache(Zeros{T}(axes))
similar(::Type{<:AbstractArray{T}}, dims::Tuple{Infinity}) where T = cache(Zeros{T}(dims))
similar(::Type{<:AbstractArray{T}}, dims::Tuple{Infinity,Infinity}) where T = cache(Zeros{T}(dims))


zeros(::Type{T}, ::Tuple{Infinity}) where T = cache(Zeros{T}(∞))
zeros(::Type{T}, nm::Tuple{Integer, Infinity}) where T = cache(Zeros{T}(nm...))
zeros(::Type{T}, nm::Tuple{Infinity, Integer}) where T = cache(Zeros{T}(nm...))
zeros(::Type{T}, nm::Tuple{Infinity, Infinity}) where T = cache(Zeros{T}(nm...))

fill(x, ::Tuple{Infinity}) = cache(Fill(x,∞))
fill(x, nm::Tuple{Integer, Infinity}) = cache(Fill(x,nm...))
fill(x, nm::Tuple{Infinity, Integer}) = cache(Fill(x,nm...))
fill(x, nm::Tuple{Infinity, Infinity}) = cache(Fill(x,nm...))



# This gets called when infinit number of columns
print_matrix_row(io::IO,
        X::AbstractVecOrMat, A::Vector,
        i::Integer, cols::AbstractVector{<:Infinity}, sep::AbstractString) = nothing


print_matrix_vdots(io::IO, vdots::AbstractString,
        A::Vector, sep::AbstractString, M::Integer, ::NotANumber) = nothing


# Avoid infinite loops on maximum
Base.mapreduce_impl(f, op, A::AbstractArray, ifirst::Integer, ::Infinity) =
    throw(ArgumentError("Cannot call mapreduce on an infinite length $(typeof(A))"))

function show_delim_array(io::IO, itr::AbstractArray, op, delim, cl,
                          delim_one, i1, ::Infinity)
    print(io, op)
    l = 20
    if !show_circular(io, itr)
        recur_io = IOContext(io, :SHOWN_SET => itr)
        if !haskey(io, :compact)
          recur_io = IOContext(recur_io, :compact => true)
        end
        first = true
        i = i1
        if 20 >= i1
          while true
              if !isassigned(itr, i)
                  print(io, undef_ref_str)
              else
                  x = itr[i]
                  show(recur_io, x)
              end
              i += 1
              if i > l
                  print(io, delim)
                  print(io, ' ')
                  print(io, '…')
                  delim_one && first && print(io, delim)
                  break
              end
              first = false
              print(io, delim)
              print(io, ' ')
          end
        end
    end
    print(io, cl)
end


#####
# FillArrays
#####


# Lazy Broadacasting
for typ in (:Ones, :Zeros, :Fill)
    @eval begin
        BroadcastStyle(::Type{$typ{T,N,NTuple{N,<:OneToInf}}}) where {T,N} = LazyArrayStyle{N}()
        BroadcastStyle(::Type{$typ{T,2,<:Tuple{<:Any,<:OneToInf}}}) where {T} = LazyArrayStyle{2}()
        BroadcastStyle(::Type{$typ{T,2,<:Tuple{<:OneToInf,<:Any}}}) where {T} = LazyArrayStyle{2}()
    end
end

BroadcastStyle(::Type{<:Diagonal{T,<:AbstractFill{T,1,Tuple{OneToInf{I}}}}}) where {T,I} = LazyArrayStyle{2}()

#####
# Diagonal
#####


BroadcastStyle(::Type{<:Diagonal{<:Any,<:AbstractInfUnitRange}}) = LazyArrayStyle{2}()


#####
# Vcat length
#####

function getindex(f::Vcat{T,1}, k::Infinity) where T
    length(f) == ∞ || throw(BoundsError(f,k))
    ∞
end

_gettail(k, a::Number, b...) = k ≤ 1 ? tuple(a, b...) : _gettail(k - length(a), b...)
_gettail(k, a, b...) = k ≤ length(a) ? tuple(a[k:end], b...) : _gettail(k - length(a), b...)
_vcat(a) = a
_vcat(a, b, c...) = Vcat(a, b, c...)
_unsafe_getindex(::IndexLinear, A::Vcat, r::InfUnitRange) = _vcat(_gettail(first(r), A.args...)...)
