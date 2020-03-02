export dtw

using Spandex

struct Position
    x::Int64
    y::Int64
end

struct Step
    pos::Position
    weight::Float64
end

function dtw(a::Vector{T}, b::Vector{T}, distance) where {T}
    local m = length(a)
    local n = length(b)

    local d = Matrix{T}(undef, m, n)

    for i = 1:m
        for j = 1:n
            d[i, j] = distance(a[i], b[j])
        end
    end

    local path = astar(d, Position(1, 1), Position(m, n))

    local cost = 0.0
    for p in path
        cost += d[p.x, p.y]
    end

    return cost / length(path)
end

function astar(D::Matrix{T}, from::Position, to::Position) where {T}
    local m = size(D, 1)
    local n = size(D, 2)

    local pq = PriorityQueue{Step}((a, b) -> (a.weight < b.weight) ? a : b)

    push!(pq, Step(from, 0.0))

    local visited = Set{Position}()
    push!(visited, from)

    local found = false
    local path = Dict{Position,Position}()

    local routes = [(1, 0), (0, 1), (1, 1)]

    while !found && pq.size > 0
        local cur = pop!(pq)

        for route in routes
            local next = Position(cur.pos.x + route[1], cur.pos.y + route[2])

            if next.x > m || next.y > n
                continue
            end

            if next in visited
                continue
            end

            path[next] = cur.pos

            if to == next
                found = true
                break
            end

            push!(pq, Step(next, cur.weight + D[next.x, next.y]))

            push!(visited, next)
        end
    end

    if !found
        return []
    else
        local opt = Vector{Position}()
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
