export GroupConjClass

export
    acting_group,
    comm,
    comm!,
    complement_system, has_complement_system, set_complement_system,
    conjugacy_class,
    conjugacy_classes_maximal_subgroups,
    conjugacy_classes_subgroups,
    conjugacy_classes,
    conjugate_group,
    core,
    coset_decomposition,
    cperm,
    cycle_structure,
    degree,
    describe,
    div_left,
    div_left!,
    div_right,
    div_right!,
    elements,
    has_exponent, set_exponent,
    fitting_subgroup, has_fitting_subgroup, set_fitting_subgroup,
    frattini_subgroup, has_frattini_subgroup, set_frattini_subgroup,
    gen,
    gens, has_gens,
    hall_subgroup,
    hall_subgroup_reps,
    hall_system, has_hall_system, set_hall_system,
    inv!,
    is_almostsimple, has_is_almostsimple, set_is_almostsimple,
    is_conjugate,
    is_conjugate_subgroup,
    isfinite, has_is_finite, set_is_finite,
    is_finitelygenerated, has_is_finitelygenerated, set_is_finitelygenerated,
    is_finiteorder,
    is_perfect, has_is_perfect, set_is_perfect,
    is_pgroup, has_is_pgroup, set_is_pgroup,
    is_pgroup_with_prime,
    is_quasisimple, has_is_quasisimple, set_is_quasisimple,
    is_simple, has_is_simple, set_is_simple,
    is_sporadic_simple, has_is_sporadic_simple, set_is_sporadic_simple,
    low_index_subgroup_reps,
    map_word,
    maximal_subgroup_reps,
    moved_points, has_moved_points, set_moved_points,
    mul,
    mul!,
    nilpotency_class, has_nilpotency_class, set_nilpotency_class,
    ngens,
    normal_closure,
    normalizer,
    number_conjugacy_classes, has_number_conjugacy_classes, set_number_conjugacy_classes,
    number_moved_points, has_number_moved_points, set_number_moved_points,
    one!,
    order, has_order, set_order,
    pcore,
    perm,
    prime_of_pgroup, has_prime_of_pgroup, set_prime_of_pgroup,
    radical_subgroup, has_radical_subgroup, set_radical_subgroup,
    rand_pseudo,
    relators,
    representative_action,
    right_coset,
    right_cosets ,
    right_transversal,
    short_right_transversal,
    socle, has_socle, set_socle,
    subgroup_reps,
    sylow_subgroup,
    sylow_system, has_sylow_system, set_sylow_system

@alias is_finiteorder isfiniteorder

# TODO: as soon as GAP packages like `polycyclic` or `rcwa` are loaded,
# the custom group types and isos they define should be added to the arrays
# _gap_group_types resp. _iso_function


group_element(G::T, x::GapObj) where T <: GAPGroup = BasicGAPGroupElem{T}(G, x)


#TODO: document `check_parent`!
# If `check_parent(a, b)` yields `false` then `a` and `b` do not fit
# together.
# A `true` result does *not* imply that the objects will fit together,
# since we check only the Julia side of the data.
#
# The current situation is that GAP knows whether an operation for two
# group elements or for a group and a group element makes sense;
# for example, think about an element and a subgroup of some f.p. group.
#
# The Oscar objects may contain additional information:
# Oscar permutation groups have a degree, and conjugating a permutation group
# by an element of another permutation group shall be allowed only if
# both have the same degree, in order to assign this degree to the result.
# Analogously, Oscar matrix groups have `deg` and `ring`.

check_parent(g::GAPGroupElem, h::GAPGroupElem) = (parent(g) === parent(h))
#TODO: Insert such checks in the code, check for failures!

# default: compare only types
check_parent(G::T, g::GAPGroupElem) where T <: GAPGroup = (T === typeof(g.parent))

# `PermGroup`: compare types and degrees
check_parent(G::PermGroup, g::PermGroupElem) = (degree(G) == degree(parent(g)))

# `MatrixGroup`: compare types, dimensions, and coefficient rings
# (This cannot be defined here because `MatrixGroup` is not yet defined.)


function elements(G::T) where T <: GAPGroup
  els = Vector{GapObj}(GAP.Globals.Elements(G.X)::GapObj)
  elems = Vector{elem_type(G)}(undef, length(els))
  for i in 1:length(els)
    elems[i] = group_element(G, els[i])
  end
  return elems
end

function parent(x::GAPGroupElem)
  return x.parent
end

# coercion embeds a group element into a different parent
function (G::GAPGroup)(x::BasicGAPGroupElem{T}) where T<:GAPGroup
   x.X in G.X && return group_element(G, x.X)
   throw(ArgumentError("the element does not embed in the group"))
end

"""
    isfinite(G::GAPGroup) -> Bool

Return `true` if `G` is finite, and `false` otherwise.

# Examples
```jldoctest
julia> isfinite(symmetric_group(5))
true

julia> isfinite(free_group(2))
false

```
"""
@gapattribute isfinite(G::GAPGroup) = GAP.Globals.IsFinite(G.X)::Bool

Base.isfinite(G::PcGroup) = true

"""
    is_finiteorder(g::GAPGroupElem) -> Bool

Return `true` if `g` has finite order, and `false` otherwise.

# Examples
```jldoctest
julia> is_finiteorder(gen(symmetric_group(5), 1))
true

julia> is_finiteorder(gen(free_group(2), 1))
false

```
"""
is_finiteorder(x::GAPGroupElem) = GAPWrap.IsInt(GAPWrap.Order(x.X))

@deprecate is_finite_order(x::GAPGroupElem) is_finiteorder(x)

"""
    order(::Type{T} = fmpz, x::Union{GAPGroupElem, GAPGroup}) where T <: IntegerUnion

Return the order of `x`, as an instance of `T`.

For a group element `x` in the group `G`, the order of `x` is the smallest
positive integer `n` such that `x^n` is the identity of `G`.
For a group `x`, the order of `x` is the number of elements in `x`.

An exception is thrown if the order of `x` is infinite,
use [`isfinite`](@ref) in order to check for finiteness.
"""
function order(::Type{T}, x::Union{GAPGroupElem, GAPGroup}) where T <: IntegerUnion
   ord = GAPWrap.Order(x.X)
   if ord === GAP.Globals.infinity
      throw(GroupsCore.InfiniteOrder(x))
   end
   return T(ord)
end

order(x::Union{GAPGroupElem, GAPGroup}) = order(fmpz, x)

@gapwrap has_order(G::GAPGroup) = GAP.Globals.HasSize(G.X)
@gapwrap set_order(G::GAPGroup, val::T) where T<:IntegerUnion = GAP.Globals.SetSize(G.X, GapObj(val))


@gapattribute is_trivial(x::GAPGroup) = GAP.Globals.IsTrivial(x.X)::Bool


@doc Markdown.doc"""
    exponent(::Type{T} = fmpz, G::GAPGroup) where T <: IntegerUnion

Return the exponent of `G`, as an instance of `T`,
i.e., the smallest positive integer $e$ such that
$g^e$ is the identity of `G` for every $g$ in `G`.
"""
@gapattribute exponent(x::GAPGroup) = fmpz(GAP.Globals.Exponent(x.X))

Base.exponent(::Type{T}, G::GAPGroup) where T <: IntegerUnion = T(GAP.Globals.Exponent(G.X))

"""
    rand(rng::Random.AbstractRNG = Random.GLOBAL_RNG, G::Group)

Return a random element of `G`, using the random number generator `rng`.
"""
Base.rand(G::GAPGroup) = Base.rand(Random.GLOBAL_RNG, G)

function Base.rand(rng::Random.AbstractRNG, G::GAPGroup)
   s = GAP.Globals.Random(GAP.wrap_rng(rng), G.X)
   return group_element(G, s)
end

function Base.rand(rng::Random.AbstractRNG, rs::Random.SamplerTrivial{Gr}) where Gr<:Oscar.GAPGroup
   return rand(rng, rs[])
end

"""
    rand_pseudo(G::Group)

Return a pseudo random element of `G`.  This works faster than `rand`,
but the returned elements are not necessarily uniformly distributed.

It is sometimes necessary to work with finite groups that we cannot
effectively enumerate, e.g. matrix groups over finite fields. We may not even
know the size of these groups. Yet many algorithms need to sample elements
from the group "as randomly as possible", whatever that means; but also they
need this *fast*.

The function `rand_pseudo` returns elements that are cheap to compute and
somehow random, but makes no guarantees about their distribution.

For finitely presented groups, it returns random words of bounded length.

For finite permutation and matrix groups, it uses a variant of the product
replacement algorithm. For most inputs, the resulting stream of elements
relatively quickly converges to a uniform distribution.

"""
function rand_pseudo(G::GAPGroup; radius::Int = 10)
  return group_element(G, GAP.Globals.PseudoRandom(G.X; radius = radius))
end

function _common_parent_group(x::T, y::T) where T <: GAPGroup
   # A typical situation should be that the two groups are identical,
   # but GAP's `IsSubset` check is not as cheap as one wants;
   # there is an `IsSubset` method that checks for identity,
   # but it is not always the first choice.
   if x.X === y.X
     return x
   elseif GAPWrap.IsSubset(x.X, y.X)
     return x
   elseif GAPWrap.IsSubset(y.X, x.X)
     return y
   else
     error("Not yet implemented")
   end
end

#We need a lattice of groups to implement this properly
function _prod(x::T, y::T) where T <: GAPGroupElem
  G = _common_parent_group(parent(x), parent(y))
  return group_element(G, x.X*y.X)
end

Base.:*(x::GAPGroupElem, y::GAPGroupElem) = _prod(x, y)

==(x::GAPGroup, y::GAPGroup) = x.X == y.X

==(x::T, y::T) where T <: BasicGAPGroupElem = x.X == y.X

"""
    one(G::GAPGroup) -> elem_type(G)

Return the identity of the group `G`.
"""
Base.one(x::GAPGroup) = group_element(x, GAP.Globals.Identity(x.X))

"""
    one(x::GAPGroupElem{T}) -> GAPGroupElem{T}

Return the identity of the parent group of `x`.
"""
Base.one(x::GAPGroupElem) = one(parent(x))
one!(x::GAPGroupElem) = one(parent(x))

Base.show(io::IO, x::GAPGroupElem) = print(io, String(GAP.Globals.StringViewObj(x.X)))
Base.show(io::IO, x::GAPGroup) = print(io, String(GAP.Globals.StringViewObj(x.X)))

Base.isone(x::GAPGroupElem) = GAPWrap.IsOne(x.X)

Base.inv(x::GAPGroupElem) = group_element(parent(x), GAP.Globals.Inverse(x.X))

inv!(out::GAPGroupElem, x::GAPGroupElem) = inv(x)  #if needed later

Base.:^(x::GAPGroupElem, y::Int) = group_element(parent(x), x.X ^ y)

Base.:^(x::GAPGroupElem, y::fmpz) = Hecke._generic_power(x, y) # TODO: perhaps  let GAP handle this; also handle arbitrary Integer subtypes?

Base.:/(x::GAPGroupElem, y::GAPGroupElem) = x*y^-1

mul(x::GAPGroupElem, y::GAPGroupElem) = x*y
mul!(out::GAPGroupElem, x::GAPGroupElem, y::GAPGroupElem) = x*y

div_right(x::GAPGroupElem, y::GAPGroupElem) = x*inv(y)
div_left(x::GAPGroupElem, y::GAPGroupElem) = inv(y)*x
div_right!(out::GAPGroupElem, x::GAPGroupElem, y::GAPGroupElem) = x*inv(y)
div_left!(out::GAPGroupElem, x::GAPGroupElem, y::GAPGroupElem) = inv(y)*x

Base.conj(x::GAPGroupElem, y::GAPGroupElem) = x^y
Base.conj!(out::GAPGroupElem, x::GAPGroupElem, y::GAPGroupElem) = x^y

"""
    comm(x::GAPGroupElem, y::GAPGroupElem)

Return the commutator of `x` and `y`,
which is defined as `x^-1*y^-1*x*y`,
and usually denoted as `[x,y]` in the literature.
"""
comm(x::GAPGroupElem, y::GAPGroupElem) = x^-1*x^y
comm!(out::GAPGroupElem, x::GAPGroupElem, y::GAPGroupElem) = x^-1*x^y

Base.IteratorSize(::Type{<:GAPGroup}) = Base.SizeUnknown()
Base.IteratorSize(::Type{PermGroup}) = Base.HasLength()

function Base.iterate(G::GAPGroup)
  L=GAP.Globals.Iterator(G.X)
  i = GAPWrap.NextIterator(L)
  return group_element(G, i), L
end

function Base.iterate(G::GAPGroup, state)
  if GAPWrap.IsDoneIterator(state)
    return nothing
  end
  i = GAPWrap.NextIterator(state)
  return group_element(G, i), state
end

# need this function just for the iterator
Base.length(x::GAPGroup)::Int = order(x)

"""
    Base.in(g::GAPGroupElem, G::GAPGroup)

Return whether `g` is an element of `G`.
The parent of `g` need not be equal to `G`.
"""
Base.in(g::GAPGroupElem, G::GAPGroup) = g.X in G.X

"""
    gens(G::Group)

Return a vector of generators of `G`.
To get the `i`-th generator,
use `G[i]` or `gen(G,i)` (see [`gen`](@ref)) instead of `gens(G)[i]`,
as that is more efficient.

# Examples
```jldoctest
julia> g = symmetric_group(5);  gens(g)
2-element Vector{PermGroupElem}:
 (1,2,3,4,5)
 (1,2)

julia> g[2]
(1,2)

```

!!! note
    The output of `gens(G)` is not, in general, the minimal list of generators for `G`.
"""
function gens(G::GAPGroup)
   L = GAP.Globals.GeneratorsOfGroup(G.X)
   res = Vector{elem_type(G)}(undef, length(L))
   for i = 1:length(res)
     res[i] = group_element(G, L[i])
   end
   return res
end

"""
    has_gens(G::Group)

Return whether generators for the group `G` are known.

# Examples
```jldoctest
julia> F = free_group(2)
<free group on the generators [ f1, f2 ]>

julia> has_gens(F)
true

julia> H = derived_subgroup(F)[1]
Group(<free, no generators known>)

julia> has_gens(H)
false
```
"""
has_gens(G::GAPGroup) = GAP.Globals.HasGeneratorsOfGroup(G.X)::Bool

"""
    gen(G::GAPGroup, i::Int)

Return the `i`-th element of the vector `gens(G)`.
This is equivalent to `G[i]`, and returns `gens(G)[i]`
but may be more efficient than the latter.

An exception is thrown if `i` is larger than the length of `gens(G)`.
"""
function gen(G::GAPGroup, i::Int)
   L = GAP.Globals.GeneratorsOfGroup(G.X)
   @assert length(L) >= i "The number of generators is lower than the given index"
   return group_element(G, L[i])
end
Base.getindex(G::GAPGroup, i::Int) = gen(G, i)

"""
    ngens(G::GAPGroup) -> Int

Return the length of the vector [`gens`](@ref)`(G)`.

!!! warning "WARNING:"
    this is *NOT*, in general, the minimum number of generators for G.
"""
ngens(G::GAPGroup) = length(GAP.Globals.GeneratorsOfGroup(G.X))


################################################################################
#
#   Conjugacy Classes
#
################################################################################

"""
    GroupConjClass

It could be either the conjugacy class of an element or of a subgroup in a group G. It is displayed as
```
     cc = x ^ G
```
where G is a group and x = `representative`(`cc`) is either an element or a subgroup of G.
"""
struct GroupConjClass{T<:GAPGroup, S<:Union{GAPGroupElem,GAPGroup}}
   X::T
   repr::S
   CC::GapObj

   function GroupConjClass(X::T, repr::S, CC::GapObj) where {T<:GAPGroup, S<:Union{GAPGroupElem,GAPGroup}}
     return new{T, S}(X, repr, CC)
   end
end

Base.eltype(::Type{GroupConjClass{T,S}}) where {T,S} = S
Base.hash(x::GroupConjClass, h::UInt) = h # FIXME

function Base.show(io::IO, x::GroupConjClass)
  print(io, String(GAP.Globals.StringViewObj(x.repr.X)),
            " ^ ",
            String(GAP.Globals.StringViewObj(x.X.X)))
end

==(a::GroupConjClass{T, S}, b::GroupConjClass{T, S}) where S where T = a.CC == b.CC

Base.length(C::GroupConjClass) = fmpz(GAPWrap.Size(C.CC)) # TODO: allow specifying return type, default fmpz

"""
    representative(C::GroupConjClass)

Return a representative of the conjugacy class `C`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> C = conjugacy_class(G, G([2, 1, 3, 4]))
(1,2) ^ Sym( [ 1 .. 4 ] )

julia> representative(C)
(1,2)

```
"""
representative(C::GroupConjClass) = C.repr

"""
    acting_group(C::GroupConjClass)

Return the acting group of the conjugacy class `C`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> C = conjugacy_class(G, G([2, 1, 3, 4]))
(1,2) ^ Sym( [ 1 .. 4 ] )

julia> acting_group(C) === G
true

```
"""
acting_group(C::GroupConjClass) = C.X

# START elements conjugation

"""
    conjugacy_class(G::Group, g::GAPGroupElem) -> GroupConjClass

Return the conjugacy class `cc` of `g` in `G`, where `g` = `representative`(`cc`).

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> C = conjugacy_class(G, G([2, 1, 3, 4]))
(1,2) ^ Sym( [ 1 .. 4 ] )

```
"""
function conjugacy_class(G::GAPGroup, g::GAPGroupElem)
   return GroupConjClass(G, g, GAP.Globals.ConjugacyClass(G.X,g.X)::GapObj)
end

function Base.rand(C::GroupConjClass{S,T}) where S where T<:GAPGroupElem
   return Base.rand(Random.GLOBAL_RNG, C)
end

function Base.rand(rng::Random.AbstractRNG, C::GroupConjClass{S,T}) where S where T<:GAPGroupElem
   return group_element(C.X, GAP.Globals.Random(GAP.wrap_rng(rng), C.CC)::GapObj)
end

@deprecate elements(C::GroupConjClass) collect(C)

"""
    number_conjugacy_classes(G::GAPGroup)

Return the number of conjugacy classes of elements in `G`.
"""
@gapattribute number_conjugacy_classes(G::GAPGroup) = fmpz(GAP.Globals.NrConjugacyClasses(G.X)::GapInt) # TODO: allow specifying return type, default fmpz

"""
    conjugacy_classes(G::Group)

Return the vector of all conjugacy classes of elements in `G`.
It is guaranteed that the class of the identity is in the first position.
"""
function conjugacy_classes(G::GAPGroup)
   L=Vector{GapObj}(GAP.Globals.ConjugacyClasses(G.X)::GapObj)
   return [GroupConjClass(G, group_element(G,GAP.Globals.Representative(cc)::GapObj),cc) for cc in L]
end

Base.:^(x::T, y::T) where T <: GAPGroupElem = group_element(_common_parent_group(parent(x), parent(y)), x.X ^ y.X)

@doc Markdown.doc"""
    is_conjugate(G::GAPGroup, x::GAPGroupElem, y::GAPGroupElem)

Return whether `x` and `y` are conjugate elements in `G`,
i.e., there is an element $z$ in `G` such that `x^`$z$ equals `y`.
"""
is_conjugate(G::GAPGroup, x::GAPGroupElem, y::GAPGroupElem) = GAPWrap.IsConjugate(G.X,x.X,y.X)

"""
    representative_action(G::Group, x::GAPGroupElem, y::GAPGroupElem)

If `x` and `y` are conjugate in `G`,
return `(true, z)`, where `x^z == y` holds;
otherwise, return `(false, nothing)`.
"""
function representative_action(G::GAPGroup, x::GAPGroupElem, y::GAPGroupElem)
   conj = GAP.Globals.RepresentativeAction(G.X, x.X, y.X)::GapObj
   if conj != GAP.Globals.fail
      return true, group_element(G, conj)
   else
      return false, nothing
   end
end
# END elements conjugation

# START subgroups conjugation
"""
    conjugacy_class(G::T, H::T) where T<:Group -> GroupConjClass

Return the subgroup conjugacy class `cc` of `H` in `G`, where `H` = `representative`(`cc`).
"""
function conjugacy_class(G::T, g::T) where T<:GAPGroup
   return GroupConjClass(G, g, GAP.Globals.ConjugacyClassSubgroups(G.X,g.X)::GapObj)
end

function Base.rand(C::GroupConjClass{S,T}) where S where T<:GAPGroup
   return Base.rand(Random.GLOBAL_RNG, C)
end

function Base.rand(rng::Random.AbstractRNG, C::GroupConjClass{S,T}) where S where T<:GAPGroup
   return _oscar_group(GAP.Globals.Random(GAP.wrap_rng(rng), C.CC), C.X)
end

"""
    conjugacy_classes_subgroups(G::Group)

Return the vector of all conjugacy classes of subgroups of G.

# Examples
```jldoctest
julia> G = symmetric_group(3)
Sym( [ 1 .. 3 ] )

julia> conjugacy_classes_subgroups(G)
4-element Vector{GroupConjClass{PermGroup, PermGroup}}:
 Group(()) ^ Sym( [ 1 .. 3 ] )
 Group([ (2,3) ]) ^ Sym( [ 1 .. 3 ] )
 Group([ (1,2,3) ]) ^ Sym( [ 1 .. 3 ] )
 Group([ (1,2,3), (2,3) ]) ^ Sym( [ 1 .. 3 ] )

```
"""
function conjugacy_classes_subgroups(G::GAPGroup)
  L = Vector{GapObj}(GAP.Globals.ConjugacyClassesSubgroups(G.X)::GapObj)
  return [GroupConjClass(G, _as_subgroup_bare(G, GAP.Globals.Representative(cc)), cc) for cc in L]
end

"""
    subgroup_reps(G::GAPGroup; order::fmpz = fmpz(-1))

Return a vector of representatives (under conjugation) for all subgroups of `G`.
If given, only subgroups of a certain order are returned.

# Examples
```jldoctest
julia> G = symmetric_group(3);

julia> subgroup_reps(G)
4-element Vector{PermGroup}:
 Group(())
 Group([ (2,3) ])
 Group([ (1,2,3) ])
 Group([ (1,2,3), (2,3) ])

julia> subgroup_reps(G, order = fmpz(2))
1-element Vector{PermGroup}:
 Group([ (2,3) ])

```
"""
function subgroup_reps(G::GAPGroup; order::fmpz = fmpz(-1))
  C = GAP.Globals.ConjugacyClassesSubgroups(G.X)
  C = map(GAP.Globals.Representative, C)
  if order != -1
    C = [x for x = C if GAP.Globals.Order(x) == order]
  end
  return [Oscar._as_subgroup(G, x)[1] for x = C]
end

"""
    conjugacy_classes_maximal_subgroups(G::Group)

Return the vector of all conjugacy classes of maximal subgroups of G.

# Examples
```jldoctest
julia> G = symmetric_group(3);

julia> conjugacy_classes_maximal_subgroups(G)
2-element Vector{GroupConjClass{PermGroup, PermGroup}}:
 Group([ (1,2,3) ]) ^ Sym( [ 1 .. 3 ] )
 Group([ (2,3) ]) ^ Sym( [ 1 .. 3 ] )

```
"""
function conjugacy_classes_maximal_subgroups(G::GAPGroup)
  L = Vector{GapObj}(GAP.Globals.ConjugacyClassesMaximalSubgroups(G.X)::GapObj)
  return [GroupConjClass(G, _as_subgroup_bare(G, GAP.Globals.Representative(cc)), cc) for cc in L]
end

"""
    maximal_subgroup_reps(G::GAPGroup)

Return a vector of representatives (under conjugation) for all maximal
subgroups of `G`.

# Examples
```jldoctest
julia> maximal_subgroup_reps(symmetric_group(4))
3-element Vector{PermGroup}:
 Group([ (2,4,3), (1,4)(2,3), (1,3)(2,4) ])
 Group([ (3,4), (1,4)(2,3), (1,3)(2,4) ])
 Group([ (3,4), (2,4,3) ])

```
"""
function maximal_subgroup_reps(G::GAPGroup)
  return Oscar._as_subgroups(G, GAP.Globals.MaximalSubgroupClassReps(G.X))
end

"""
    low_index_subgroup_reps(G::GAPGroup, n::Int)

Return a vector of representatives (under conjugation) for all subgroups
of index at most `n` in `G`.

# Examples
```jldoctest
julia> G = symmetric_group(5);

julia> low_index_subgroup_reps(G, 5)
3-element Vector{PermGroup}:
 Sym( [ 1 .. 5 ] )
 Alt( [ 1 .. 5 ] )
 Sym( [ 1 .. 4 ] )

```
"""
function low_index_subgroup_reps(G::PermGroup, n::Int)
  ll = GAP.Globals.LowIndexSubgroups(G.X, n)
  return [Oscar._as_subgroup(G, x)[1] for x = ll]
end

"""
    conjugate_group(G::T, x::GAPGroupElem) where T <: GAPGroup

Return the group `G^x` that consists of the elements `g^x`, for `g` in `G`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> H = sylow_subgroup(G, 3)[1]
Group([ (1,2,3) ])

julia> conjugate_group(H, gen(G, 1))
Group([ (2,3,4) ])

```
"""
function conjugate_group(G::T, x::GAPGroupElem) where T <: GAPGroup
  check_parent(G, x) || error("G and x are not compatible")
  return _oscar_group(GAP.Globals.ConjugateSubgroup(G.X, x.X), G)
end

Base.:^(H::GAPGroup, y::GAPGroupElem) = conjugate_group(H, y)

# This function was never exported but may have been used somewhere.
# (The name is confusing because it is not clear *of which group* the result
# shall be a subgroup.)
@deprecate conjugate_subgroup(G::GAPGroup, x::GAPGroupElem) conjugate_group(G, x)

"""
    is_conjugate(G::GAPGroup, H::GAPGroup, K::GAPGroup)

Return whether `H` and `K` are conjugate subgroups in `G`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> H = sub(G, [G([2, 1, 3, 4])])[1]
Group([ (1,2) ])

julia> K = sub(G, [G([1, 2, 4, 3])])[1]
Group([ (3,4) ])

julia> is_conjugate(G, H, K)
true

julia> K = sub(G, [G([2, 1, 4, 3])])[1]
Group([ (1,2)(3,4) ])

julia> is_conjugate(G, H, K)
false

```
"""
is_conjugate(G::GAPGroup, H::GAPGroup, K::GAPGroup) = GAPWrap.IsConjugate(G.X,H.X,K.X)

"""
    representative_action(G::Group, H::Group, K::Group)

If `H` and `K` are conjugate subgroups in `G`, return `true, z`
where `H^z = K`; otherwise, return `false, nothing`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> H = sub(G, [G([2, 1, 3, 4])])[1]
Group([ (1,2) ])

julia> K = sub(G, [G([1, 2, 4, 3])])[1]
Group([ (3,4) ])

julia> representative_action(G, H, K)
(true, (1,3)(2,4))

julia> K = sub(G, [G([2, 1, 4, 3])])[1]
Group([ (1,2)(3,4) ])

julia> representative_action(G, H, K)
(false, nothing)

```
"""
function representative_action(G::GAPGroup, H::GAPGroup, K::GAPGroup)
   conj = GAP.Globals.RepresentativeAction(G.X, H.X, K.X)::GapObj
   if conj != GAP.Globals.fail
      return true, group_element(G, conj)
   else
      return false, nothing
   end
end

"""
    is_conjugate_subgroup(G::T, U::T, V::T) where T <: GAPGroup

Return whether a conjugate of `V` by some element in `G` is a subgroup of `U`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> U = derived_subgroup(G)[1]
Alt( [ 1 .. 4 ] )

julia> V = sub(G, [G([2,1,3,4])])[1]
Group([ (1,2) ])

julia> is_conjugate_subgroup(G, U, V)
(false, ())

julia> V = sub(G, [G([2, 1, 4, 3])])[1]
Group([ (1,2)(3,4) ])

julia> is_conjugate_subgroup(G, U, V)
(true, ())

```
"""
function is_conjugate_subgroup(G::T, U::T, V::T) where T <: GAPGroup
  if order(V) == 1
    return true, one(U)
  end
  local sigma
  while true
    sigma = rand(V)
    if order(sigma) > 1
      break
    end
  end
  s = short_right_transversal(G, U, sigma)
  for t = s
    if is_subgroup(U, V^inv(t))[1]
      return true, inv(t)
    end
  end
  return false, one(U)
end

@doc Markdown.doc"""
    short_right_transversal(G::PermGroup, H::PermGroup, s::PermGroupElem)

Return an array of representatives `g` for all those right cosets of `H` in `G`
such that `H^g` contains the element `s`.

# Examples
```jldoctest
julia> G = symmetric_group(4);

julia> H = sylow_subgroup(G, 3)[1]
Group([ (1,2,3) ])

julia> short_right_transversal(G, H, G([2, 1, 3, 4]))
PermGroupElem[]

julia> short_right_transversal(G, H, G([2, 3, 1, 4]))
2-element Vector{PermGroupElem}:
 ()
 (2,3)

```
"""
function short_right_transversal(G::PermGroup, H::PermGroup, s::PermGroupElem)
  C = conjugacy_classes(H)
  cs = cycle_structure(s)
  can = PermGroupElem[]
  for c in C
    r = representative(c)
    if cs == cycle_structure(r)
      push!(can, r)
    end
  end

  R = PermGroupElem[]
  for c in can
    success, d = representative_action(G, c, s)
    if success
      push!(R, d)
      @assert c^R[end] == s
    end
  end

  S = PermGroupElem[]
  C = centralizer(G, s)[1]
  for r in R
    CH = centralizer(H^r, s)[1]
    for t = right_transversal(C, CH)
      push!(S, r*t)
    end
  end

  return S
end

# END subgroups conjugation


# START iterator
Base.IteratorSize(::Type{<:GroupConjClass}) = Base.SizeUnknown()

Base.iterate(cc::GroupConjClass) = iterate(cc, GAP.Globals.Iterator(cc.CC)::GapObj)

function Base.iterate(cc::GroupConjClass{S,T}, state::GapObj) where {S,T}
  if GAPWrap.IsDoneIterator(state)
    return nothing
  end
  i = GAPWrap.NextIterator(state)
  if T <: GAPGroupElem
     return group_element(cc.X, i), state
  else
     return _as_subgroup(cc.X, i)[1], state
  end
end

################################################################################
#
# Normal Structure
#
################################################################################

"""
    normalizer(G::Group, H::Group)

Return `N, f`, where `N` is the normalizer of `H` in `G`,
i.e., the largest subgroup of `G` in which `H` is normal,
and `f` is the embedding morphism of `N` into `G`.
"""
normalizer(G::T, H::T) where T<:GAPGroup = _as_subgroup(G, GAP.Globals.Normalizer(G.X,H.X))

"""
    normalizer(G::Group, x::GAPGroupElem)

Return `N, f`, where `N` is the normalizer of the cyclic subgroup generated
by `x` in `G` and `f` is the embedding morphism of `N` into `G`.
"""
normalizer(G::GAPGroup, x::GAPGroupElem) = _as_subgroup(G, GAP.Globals.Normalizer(G.X,x.X))

"""
    core(G::Group, H::Group)

Return `C, f`, where `C` is the normal core of `H` in `G`,
that is, the largest normal subgroup of `G` that is contained in `H`,
and `f` is the embedding morphism of `C` into `G`.
"""
core(G::T, H::T) where T<:GAPGroup = _as_subgroup(G, GAP.Globals.Core(G.X,H.X))

"""
    normal_closure(G::Group, H::Group)

Return `N, f`, where `N` is the normal closure of `H` in `G`,
that is, the smallest normal subgroup of `G` that contains `H`,
and `f` is the embedding morphism of `N` into `G`.

Note that `H` must be a subgroup of `G`.
"""
normal_closure(G::T, H::T) where T<:GAPGroup = _as_subgroup(G, GAP.Globals.NormalClosure(G.X,H.X))

# Note:
# GAP admits `NormalClosure` also when `H` is not a subgroup of `G`,
# and in this case the result is not contained in `G`.
# (We should test whether `H` is a subgroup of `G`,
# but then the user should have the possibility to omit this check.)

"""
    pcore(G::Group, p::IntegerUnion)

Return `C, f`, where `C` is the `p`-core
(i.e. the largest normal `p`-subgroup) of `G`
and `f` is the embedding morphism of `C` into `G`.
"""
function pcore(G::GAPGroup, p::IntegerUnion)
   is_prime(p) || throw(ArgumentError("p is not a prime"))
   return _as_subgroup(G, GAP.Globals.PCore(G.X,GAP.Obj(p)))
end



################################################################################
#
# Specific Subgroups
#
################################################################################

# commutator_subgroup(G::T, H::T) where T<:GAPGroup = T(GAP.Globals.CommutatorSubgroup(G.X,H.X))
# In the literature, the name commutator subgroup is often used as a synonym
# of derived subgroup.
# GAP defines `CommutatorSubgroup( G, H )` for arbitrary groups `G`, `H` in
# the same family; thus the result is in general not contained in `G` or `H`,
# and we do not know into which group the result should be embedded.
# Is this function useful at all?
# (The name `Commutator*Subgroup*` is irritating, isn't it?)

"""
    fitting_subgroup(G::GAPGroup)

Return the Fitting subgroup of `G`, i.e.,
the largest nilpotent normal subgroup of `G`.
"""
@gapattribute fitting_subgroup(G::GAPGroup) = _as_subgroup(G, GAP.Globals.FittingSubgroup(G.X))

"""
    frattini_subgroup(G::GAPGroup)

Return the Frattini subgroup of `G`, i.e.,
the intersection of all maximal subgroups of `G`.
"""
@gapattribute frattini_subgroup(G::GAPGroup) = _as_subgroup(G, GAP.Globals.FrattiniSubgroup(G.X))

"""
    radical_subgroup(G::GAPGroup)

Return the solvable radical of `G`, i.e.,
the largest solvable normal subgroup of `G`.
"""
@gapattribute radical_subgroup(G::GAPGroup) = _as_subgroup(G, GAP.Globals.RadicalGroup(G.X))
#T wrong name, already in GAP!

"""
    socle(G::GAPGroup)

Return the socle of `G`, i.e.,
the subgroup generated by all minimal normal subgroups of `G`,
see [`minimal_normal_subgroups`](@ref).
"""
@gapattribute socle(G::GAPGroup) = _as_subgroup(G, GAP.Globals.Socle(G.X))


################################################################################
#
# Sylow & Hall Subgroups
#
################################################################################

"""
    sylow_subgroup(G::Group, p::IntegerUnion)

Return a Sylow `p`-subgroup of the finite group `G`, for a prime `p`.
This is a subgroup of `p`-power order in `G`
whose index in `G` is coprime to `p`.

# Examples
```jldoctest
julia> g = symmetric_group(4); order(g)
24

julia> s = sylow_subgroup(g, 2); order(s[1])
8

julia> s = sylow_subgroup(g, 3); order(s[1])
3

```
"""
function sylow_subgroup(G::GAPGroup, p::IntegerUnion)
   is_prime(p) || throw(ArgumentError("p is not a prime"))
   return _as_subgroup(G,GAP.Globals.SylowSubgroup(G.X,GAP.Obj(p)))
end

# no longer documented, better use `hall_subgroup_reps`
function hall_subgroup(G::GAPGroup, P::AbstractVector{<:IntegerUnion})
   P = unique(P)
   all(is_prime, P) || throw(ArgumentError("The integers must be prime"))
   is_solvable(G) || throw(ArgumentError("The group is not solvable"))
   return _as_subgroup(G,GAP.Globals.HallSubgroup(G.X,GAP.Obj(P, recursive=true)))
end

"""
    hall_subgroup_reps(G::Group, P::AbstractVector{<:IntegerUnion})

Return a vector that contains representatives of conjugacy classes of
Hall `P`-subgroups of the finite group `G`, for a vector `P` of primes.
A Hall `P`-subgroup of `G` is a subgroup the order of which is only divisible
by primes in `P` and whose index in `G` is coprime to all primes in `P`.

For solvable `G`, Hall `P`-subgroups exist and are unique up to conjugacy.
For nonsolvable `G`, Hall `P`-subgroups may not exist or may not be unique
up to conjugacy.

# Examples
```jldoctest
julia> g = dihedral_group(30);

julia> h = hall_subgroup_reps(g, [2, 3]);

julia> (length(h), order(h[1]))
(1, 6)

julia> g = GL(3, 2)
GL(3,2)

julia> h = hall_subgroup_reps(g, [2, 3]);

julia> (length(h), order(h[1]))
(2, 24)

julia> h = hall_subgroup_reps(g, [2, 7]); length(h)
0

```
"""
function hall_subgroup_reps(G::GAPGroup, P::AbstractVector{<:IntegerUnion})
   P = unique(P)
   all(is_prime, P) || throw(ArgumentError("The integers must be prime"))
   res_gap = GAP.Globals.HallSubgroup(G.X, GAP.Obj(P))::GapObj
   if res_gap == GAP.Globals.fail
     return typeof(G)[]
   elseif GAPWrap.IsList(res_gap)
     return _as_subgroups(G, res_gap)
   else
     return [_as_subgroup_bare(G, res_gap)]
   end
end

hall_subgroups_representatives(G::GAPGroup, P::AbstractVector{<:IntegerUnion}) = hall_subgroup_reps(G,P)
# use @alias?

@doc Markdown.doc"""
    sylow_system(G::Group)

Return a vector of Sylow $p$-subgroups of the finite group `G`,
where $p$ runs over the prime factors of the order of `G`,
such that every two such subgroups commute with each other (as subgroups).

Sylow systems exist only for solvable groups,
an exception is thrown if `G` is not solvable.
"""
@gapattribute function sylow_system(G::GAPGroup)
   if !is_solvable(G) throw(ArgumentError("The group is not solvable")) end
   return _as_subgroups(G, GAP.Globals.SylowSystem(G.X))
end

@doc Markdown.doc"""
    complement_system(G::Group)

Return a vector of $p'$-Hall subgroups of the finite group `G`,
where $p$ runs over the prime factors of the order of `G`.

Complement systems exist only for solvable groups,
an exception is thrown if `G` is not solvable.
"""
@gapattribute function complement_system(G::GAPGroup)
   if !is_solvable(G) throw(ArgumentError("The group is not solvable")) end
   return _as_subgroups(G, GAP.Globals.ComplementSystem(G.X))
end

@doc Markdown.doc"""
    hall_system(G::Group)

Return a vector of $P$-Hall subgroups of the finite group `G`,
where $P$ runs over the subsets of prime factors of the order of `G`.

Hall systems exist only for solvable groups,
an exception is thrown if `G` is not solvable.
"""
@gapattribute function hall_system(G::GAPGroup)
   if !is_solvable(G) throw(ArgumentError("The group is not solvable")) end
   return _as_subgroups(G, GAP.Globals.HallSystem(G.X))
end


################################################################################
#
# Some Properties
#
################################################################################

"""
    is_perfect(G::GAPGroup)

Return whether `G` is a perfect group, i.e., equal to its derived subgroup.

# Examples
```jldoctest
julia> is_perfect(special_linear_group(2, 5))
true

julia> is_perfect(symmetric_group(5))
false

```
"""
@gapattribute is_perfect(G::GAPGroup) = GAP.Globals.IsPerfectGroup(G.X)::Bool

"""
    is_simple(G::GAPGroup)

Return whether `G` is a simple group, i.e.,
`G` is not trivial and has no non-trivial normal subgroups.

# Examples
```jldoctest
julia> is_simple(alternating_group(5))
true

julia> is_simple(symmetric_group(5))
false

```
"""
@gapattribute is_simple(G::GAPGroup) = GAP.Globals.IsSimpleGroup(G.X)::Bool

@doc Markdown.doc"""
    is_almostsimple(G::GAPGroup)

Return whether `G` is an almost simple group,
i.e., `G` is isomorphic to a group $H$ with the property
$S \leq H \leq Aut(S)$, for some non-abelian simple group $S$.

# Examples
```jldoctest
julia> is_almostsimple(symmetric_group(5))
true

julia> is_almostsimple(special_linear_group(2, 5))
false

```
"""
@gapattribute is_almostsimple(G::GAPGroup) = GAP.Globals.IsAlmostSimpleGroup(G.X)::Bool

@doc Markdown.doc"""
    is_quasisimple(G::GAPGroup)

Return whether `G` is a quasisimple group,
i.e., `G` is perfect such that the factor group modulo its centre is
a non-abelian simple group.

# Examples
```jldoctest
julia> is_quasisimple(special_linear_group(2, 5))
true

julia> is_quasisimple(symmetric_group(5))
false

```
"""
@gapattribute is_quasisimple(G::GAPGroup) = GAP.Globals.IsQuasisimpleGroup(G.X)::Bool

@doc Markdown.doc"""
    is_sporadic_simple(G::GAPGroup)

Return whether `G` is a sporadic simple group.

# Examples
```jldoctest
julia> is_sporadic_simple(mathieu_group(11))
true

julia> is_sporadic_simple(mathieu_group(10))
false

```
"""
@gapattribute is_sporadic_simple(G::GAPGroup) = GAP.Globals.IsSporadicSimpleGroup(G.X)::Bool

"""
    is_pgroup(G)

Return `true` if `G` is a ``p``-group for some prime ``p``, that is, if the
order of every element in `G` is a power of ``p``.

Note that a finite group is a ``p``-group if and only if its order is a prime
power. In particular, the trivial group is a ``p``-group for every prime.

# Examples
```jldoctest
julia> is_pgroup(symmetric_group(1))
true

julia> is_pgroup(symmetric_group(2))
true

julia> is_pgroup(symmetric_group(3))
false

```
"""
@gapattribute is_pgroup(G::GAPGroup) = GAP.Globals.IsPGroup(G.X)::Bool


"""
    is_pgroup_with_prime(G)

Return `(true, nothing)` if `G` is the trivial group,
`(true, p)` if the order of every element in `G` is a power of a prime `p`,
and `(false, nothing)` otherwise.

For finite groups `G`, the first return value is `true` if and only if
the order of `G` is a prime power.

# Examples
```jldoctest
julia> is_pgroup_with_prime(symmetric_group(1))
(true, nothing)

julia> is_pgroup_with_prime(symmetric_group(2))
(true, 2)

julia> is_pgroup_with_prime(symmetric_group(3))
(false, nothing)

```
"""
function is_pgroup_with_prime(G::GAPGroup)
  is_trivial(G) && return true, nothing
  if is_pgroup(G)
    p = GAP.Globals.PrimePGroup(G.X)::GapInt
    return true, fmpz(p)  # TODO: allow specifying the type used for the prime
  end
  return false, nothing
end


# helper for prime_of_pgroup: this helper is efficient thanks to
# @gapattribute, but we also want prime_of_pgroup to accept an optional
# type argument; so we cannot use @gapattribute directly. Instead we set
# up this auxiliary _prime_of_pgroup which then is called by the real
# prime_of_pgroup.
# TODO: enhance @gapattribute so this is not necessary
@gapattribute function _prime_of_pgroup(G::GAPGroup)
  if is_trivial(G) || !is_pgroup(G)
    error("only supported for non-trivial p-groups")
  end
  return GAP.Globals.PrimePGroup(G.X)::GapInt
end


"""
    prime_of_pgroup(::Type{T} = fmpz, G::GAPGroup) where T <: IntegerUnion

Return the prime ``p`` if `G` is a non-trivial ``p``-group.

An exception is thrown if `G` is not a ``p``-group or
is a trivial group.

# Examples
```jldoctest
julia> prime_of_pgroup(quaternion_group(8))
2

julia> prime_of_pgroup(UInt16, quaternion_group(8))
0x0002

julia> prime_of_pgroup(symmetric_group(1))
ERROR: only supported for non-trivial p-groups

julia> prime_of_pgroup(symmetric_group(3))
ERROR: only supported for non-trivial p-groups

```
"""
function prime_of_pgroup(::Type{T}, G::GAPGroup) where T <: IntegerUnion
  return T(_prime_of_pgroup(G))
end

# set default value for first argument T to fmpz
prime_of_pgroup(G::GAPGroup) = prime_of_pgroup(fmpz, G)

"""
    has_prime_of_pgroup(G::GAPGroup)

Return `true` if the value for `prime_of_pgroup(G)` has already been computed.
"""
has_prime_of_pgroup(G::GAPGroup) = has__prime_of_pgroup(G)

"""
    set_prime_of_pgroup(G::GAPGroup, p::IntegerUnion)

Set the value for `prime_of_pgroup(G)` to `p` if it has't been set already.
"""
function set_prime_of_pgroup(G::GAPGroup, p::IntegerUnion)
  set__prime_of_pgroup(G, GAP.Obj(p))
end


"""
    is_finitelygenerated(G)

Return whether `G` is a finitely generated group.

# Examples
```jldoctest
julia> F = free_group(2)
<free group on the generators [ f1, f2 ]>

julia> is_finitelygenerated(F)
true

julia> H = derived_subgroup(F)[1]
Group(<free, no generators known>)

julia> is_finitelygenerated(H)
false
```
"""
@gapattribute is_finitelygenerated(G::GAPGroup) = GAP.Globals.IsFinitelyGeneratedGroup(G.X)::Bool


@doc Markdown.doc"""
    relators(G::FPGroup)

Return a vector of relators for the finitely presented group, i.e.,
elements $[x_1, x_2, \ldots, x_n]$ in $F =$ `free_group(ngens(G))` such that
`G` is isomorphic with $F/[x_1, x_2, \ldots, x_n]$.
"""
function relators(G::FPGroup)
   L=GAP.Globals.RelatorsOfFpGroup(G.X)
   F=free_group(G)
   return [group_element(F,L[i]) for i in 1:length(L)]
end


@doc Markdown.doc"""
    map_word(g::FPGroupElem, genimgs::Vector; genimgs_inv::Vector = Vector(undef, length(genimgs)), init = nothing)
    map_word(v::Vector{Union{Int, Pair{Int, Int}}}, genimgs::Vector; genimgs_inv::Vector = Vector(undef, length(genimgs)), init = nothing)

Return the product $R_1 R_2 \cdots R_n$
that is described by `g` or `v`, respectively.

If `g` is an element of a free group $G$, say, then the rank of $G$ must be
equal to the length of `genimgs`, `g` is a product of the form
$g_{i_1}^{e_i} g_{i_2}^{e_2} \cdots g_{i_n}^{e_n}$
where $g_i$ is the $i$-th generator of $G$ and the $e_i$ are nonzero integers,
and $R_j = $`imgs[`$i_j$`]`$^{e_j}$.

If `g` is an element of a finitely presented group then the result is
defined as `map_word` applied to a representing element of the underlying
free group.

If the first argument is a vector `v` of integers $k_i$ or pairs `k_i => e_i`,
respectively,
then the absolute values of the $k_i$ must be at most the length of `genimgs`,
and $R_j = $`imgs[`$|k_i|$`]`$^{\epsilon_i}$
where $\epsilon_i$ is the `sign` of $k_i$ (times $e_i$).

If a vector `genimgs_inv` is given then its assigned entries are expected
to be the inverses of the corresponding entries in `genimgs`,
and the function will use (and set) these entries in order to avoid
calling `inv` (more than once) for entries of `genimgs`.

If `v` has length zero then `init` is returned if also `genimgs` has length
zero, otherwise `one(genimgs[1])` is returned.
In all other cases, `init` is ignored.

# Examples
```jldoctest
julia> F = free_group(2);  F1 = gen(F, 1);  F2 = gen(F, 2);

julia> imgs = gens(symmetric_group(4))
2-element Vector{PermGroupElem}:
 (1,2,3,4)
 (1,2)

julia> map_word(F1^2, imgs)
(1,3)(2,4)

julia> map_word(F2, imgs)
(1,2)

julia> map_word(one(F), imgs)
()

julia> invs = Vector(undef, 2);

julia> map_word(F1^-2*F2, imgs, genimgs_inv = invs)
(1,3,2,4)

julia> invs
2-element Vector{Any}:
    (1,4,3,2)
 #undef

```
"""
function map_word(g::FPGroupElem, genimgs::Vector; genimgs_inv::Vector = Vector(undef, length(genimgs)), init = nothing)
  G = parent(g)
  Ggens = gens(G)
  if length(Ggens) == 0
    return init
  end
  gX = g.X
  if ! GAP.Globals.IsAssocWord(gX)
    # element of a f.p. group
    gX = GAP.Globals.UnderlyingElement(gX)
  end
  @assert length(GAP.getbangproperty(GAP.Globals.FamilyObj(gX), :names)) == length(genimgs)
  @assert GAP.Globals.IsAssocWord(gX)
  if GAP.Globals.IsLetterAssocWordRep(gX)
    # `GAP.Globals.ExtRepOfObj` would create a syllable representation,
    # which is unnecessary.
    ll = Vector{Int}(GAP.Globals.LetterRepAssocWord(gX)::GAP.GapObj)
  elseif GAP.Globals.IsSyllableAssocWordRep(gX)
    # Here we take the available syllable representation.
    l = GAP.Globals.ExtRepOfObj(gX)::GAP.GapObj
    ll = Pair{Int, Int}[l[i] => l[i+1] for i in 1:2:length(l)]
  else
    error("do not know the type of the element $gX")
  end
  return map_word(ll, genimgs, genimgs_inv = genimgs_inv, init = init)
end

function map_word(v::Union{Vector{Int}, Vector{Pair{Int, Int}}, Vector{Any}}, genimgs::Vector; genimgs_inv::Vector = Vector(undef, length(genimgs)), init = nothing)
  length(genimgs) == 0 && (@assert length(v) == 0; return init)
  length(v) == 0 && return one(genimgs[1])
  return prod(i -> _map_word_syllable(i, genimgs, genimgs_inv), v)
end

function _map_word_syllable(vi::Int, genimgs::Vector, genimgs_inv::Vector)
  vi > 0 && (@assert vi <= length(genimgs); return genimgs[vi])
  vi = -vi
  @assert vi <= length(genimgs)
  isassigned(genimgs_inv, vi) && return genimgs_inv[vi]
  res = inv(genimgs[vi])
  genimgs_inv[vi] = res
  return res
end

function _map_word_syllable(vi::Pair{Int, Int}, genimgs::Vector, genimgs_inv::Vector)
  x = vi[1]
  @assert (x > 0 && x <= length(genimgs))
  e = vi[2]
  e > 1 && return genimgs[x]^e
  e == 1 && return genimgs[x]
  isassigned(genimgs_inv, x) && return genimgs_inv[x]^-e
  res = inv(genimgs[x])
  genimgs_inv[x] = res
  e == -1 && return res
  return res^-e
end


@doc Markdown.doc"""
    nilpotency_class(G::GAPGroup) -> Int

Return the nilpotency class of `G`, i.e.,
the smallest integer $n$ such that `G` has a central series of length $n$.

An exception is thrown if `G` is not nilpotent.
"""
@gapattribute function nilpotency_class(G::GAPGroup)
   @assert is_nilpotent(G) "The group is not nilpotent."
   return GAP.Globals.NilpotencyClassOfGroup(G.X)::Int
end


function describe(G::GrpAbFinGen)
   l = elementary_divisors(G)
   length(l) == 0 && return "0"   # trivial group
   l_tor = filter(x -> x != 0, l)
   free = length(l) - length(l_tor)
   res = length(l_tor) == 0 ? "" : "Z/" * join([string(x) for x in l_tor], " + Z/")
   return free == 0 ? res : ( res == "" ? ( free == 1 ? "Z" : "Z^$free" ) : ( free == 1 ? "$res + Z" : "$res + Z^$free" ) )
end

@doc Markdown.doc"""
    describe(G::GAPGroup)

Return a string that describes some aspects of the structure of `G`.

For finite groups, the function works well if `G` is an abelian group or a
finite simple group or a group in one of the following series: symmetric,
dihedral, quasidihedral, generalized quaternion, general linear, special
linear.

For other finite groups, the function tries to decompose `G` as a direct
product or a semidirect product, and if this is not possible as a
non-splitting extension of a normal subgroup $N$ with the factor group
`G`$/N$, where $N$ is the center or the derived subgroup or the Frattini
subgroup of `G`.

For infinite groups, if the group is known to be finitely generated and
abelian or free, a reasonable description is printed.

For general infinite groups, or groups for which finiteness is not (yet) known,
not much if anything can be done. In particular we avoid potentially expensive
checks such as computing the size of the group or whether it is abelian.
While we do attempt a few limited fast checks for finiteness and
commutativity, these will not detect all finite or commutative groups.

Thus calling `describe` again on the same group after additional information
about it becomes known to Oscar may yield different outputs.

!!! note
    - for finitely presented groups, even deciding if the group is trivial
      is impossible in general; the same holds for most other properties,
      like whether the group is finite, abelian, etc.,
    - there is in general no "nice" decomposition of `G`,
    - there may be several decompositions of `G`,
    - nonisomorphic groups may yield the same `describe` result,
    - isomorphic groups may yield different `describe` results,
    - the computations can take a long time (for example in the case of
      large $p$-groups), and the results are still often not very helpful.

The following notation is used in the returned string.

| Description | Syntax |
| ----------- | ----------- |
| trivial group | 1 |
| finite cyclic group | C<size> |
| infinite cyclic group | Z |
| alternating group | A<degree> |
| symmetric group | S<degree> |
| dihedral group | D<size> |
| quaternion group | Q<size> |
| quasidihedral group | QD<size> |
| projective special linear group | PSL(<n>,<q>) |
| special linear group | SL(<n>,<q>) |
| general linear group | GL(<n>,<q>) |
| proj. special unitary group | PSU(<n>,<q>) |
| orthogonal group, type B | O(2<n>+1,<q>) |
| orthogonal group, type D | O+(2<n>,<q>) |
| orthogonal group, type 2D | O-(2<n>,<q>) |
| proj. special symplectic group | PSp(2<n>,<q>) |
| Suzuki group (type 2B) | Sz(<q>) |
| Ree group (type 2F or 2G) | Ree(<q>) |
| Lie group of exceptional type | E(6,<q>), E(7,<q>), E(8,<q>), 2E(6,<q>), F(4,<q>), G(2,<q>) |
| Steinberg triality group | 3D(4,<q>) |
| sporadic simple group | M11, M12, M22, M23, M24, J1, J2, J3, J4, Co1, Co2, Co3, Fi22, Fi23, Fi24', Suz, HS, McL, He, HN, Th, B, M, ON, Ly, Ru |
| Tits group | 2F(4,2)' |
| the indicated group from the library of perfect groups | PerfectGroup(<size>,<id>) |
| direct product | A x B |
| semidirect product | N : H |
| non-split extension | Z(G) . G/Z(G) = G' . G/G', Phi(G) . G/Phi(G) |

# Examples
```jldoctest
julia> g = symmetric_group(6);

julia> describe(g)
"S6"

julia> describe(sylow_subgroup(g,2)[1])
"C2 x D8"

julia> describe(sylow_subgroup(g, 3)[1])
"C3 x C3"

julia> describe(free_group(3))
"a free group of rank 3"

```
"""
function describe(G::GAPGroup)
   is_finitelygenerated(G) || return "a non-finitely generated group"

   # handle groups whose finiteness is known
   if has_is_finite(G)
      # finite groups: pass them to GAP
      if isfinite(G)
         return String(GAP.Globals.StructureDescription(G.X)::GapObj)
      end

      # infinite groups known to be abelian can still be dealt with by GAP
      if has_is_abelian(G) && is_abelian(G)
         return String(GAP.Globals.StructureDescription(G.X)::GapObj)
      end

      return "an infinite group"
   end

   return "a group"
end

function describe(G::FPGroup)
   # despite the name, there are non-finitely generated (and hence non-finitely presented)
   # FPGroup instances
   is_finitelygenerated(G) || return "a non-finitely generated group"

   if GAP.Globals.IsFreeGroup(G.X)::Bool
      r = GAP.Globals.RankOfFreeGroup(G.X)::GapInt
      r >= 2 && return "a free group of rank $(r)"
      r == 1 && return "Z"
      r == 0 && return "1"
   end

   # check for free groups in disguise
   isempty(relators(G)) && return describe(free_group(G))

   # attempt to simplify presentation
   H = simplified_fp_group(G)[1]
   ngens(H) < ngens(G) && return describe(H)

   # abelian groups can be dealt with by GAP
   extra = ""
   if !has_is_abelian(G)
      if is_obviouslyabelian(G)
         set_is_abelian(G, true) # TODO: Claus won't like this...
         return String(GAP.Globals.StructureDescription(G.X)::GapObj)
      end
   elseif is_abelian(G)
      return String(GAP.Globals.StructureDescription(G.X)::GapObj)
   else
      extra *= " non-abelian"
   end

   if !has_is_finite(G)
      # try to obtain an isomorphic permutation group, but don't try too hard
      iso = GAP.Globals.IsomorphismPermGroupOrFailFpGroup(G.X, 100000)::GapObj
      iso != GAP.Globals.fail && return describe(PermGroup(GAP.Globals.Range(iso)))
   elseif isfinite(G)
      return describe(PermGroup(G))
   else
      extra *= " infinite"
   end

   return "a finitely presented$(extra) group"

end

function is_obviouslyabelian(G::FPGroup)
    rels = relators(G)
    fgens = gens(free_group(G))
    signs = [(e1,e2,e3) for e1 in (-1,1) for e2 in (-1,1) for e3 in (-1,1)]
    for i in 1:length(fgens)
        a = fgens[i]
        for j in i+1:length(fgens)
            b = fgens[j]
            any(t -> comm(a^t[1],b^t[2])^t[3] in rels, signs) || return false
        end
    end
    return true
end
