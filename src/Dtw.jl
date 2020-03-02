export dtw

using Spandex

function dtw(a::Vector{T}, b::Vector{T}, distance) where {T}
    local m = length(a)
    local n = length(b)

    local d = Matrix{T}(undef, m, n)

    for i = 1:m
        for j = 1:n
            d[i, j] = distance(a[i], b[j])
        end
    end

    local path = astar(d, (1, 1), (m, n))

    local cost = 0.0
    for p in path
        cost += d[p[1], p[2]]
    end

    return cost / length(path)
end

function astar(
    D::Matrix{T},
    from::Tuple{Int64,Int64},
    to::Tuple{Int64,Int64},
) where {T}
    local m = size(D, 1)
    local n = size(D, 2)

    local pq = PriorityQueue{Tuple{Int64,Int64}}(
        (a, b) -> (D[a[1], a[2]] < D[b[1], b[2]]) ? a : b,
    )

    push!(pq, from)

    local visited = Set{Tuple{Int64,Int64}}()
    push!(visited, from)

    local found = false
    local path = Dict{Tuple{Int64,Int64},Tuple{Int64,Int64}}()

    local routes = [(1, 0), (0, 1), (1, 1)]

    while !found && pq.size > 0
        local cur = pop!(pq)

        for route in routes
            local next = (cur[1] + route[1], cur[2] + route[2])

            if next[1] > m || next[2] > n
                continue
            end

            if next in visited
                continue
            end

            path[next] = cur

            if to == next
                found = true
                break
            end

            push!(pq, next)

            push!(visited, next)
        end
    end

    if !found
        return []
    else
        local opt = Vector{Tuple{Int64,Int64}}()
        local cur = to
        while from != cur
            push!(opt, cur)
            cur = path[cur]
        end
        push!(opt, from)

        reverse!(opt)

        return opt
    end
end
