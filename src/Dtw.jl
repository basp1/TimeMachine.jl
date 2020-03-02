export dtw

using Spandex

struct Position
    x::Int64
    y::Int64
end

struct Step
    pos::Position
    weight::Float64
    iter::Int64
end

function dtw(
    a::Vector{T},
    b::Vector{T},
    distance,
    window_size::Number = 0,
) where {T}
    local m = length(a)
    local n = length(b)

    if typeof(window_size) != Int
        window_size = Int64(round(min(m, n) * window_size))
    end
    if 0 == window_size
        window_size = max(m, n)
    end

    local d = Matrix{T}(undef, m, n)
    for i = 1:m
        for j = max(1, i - window_size):min(n, i + window_size)
            d[i, j] = distance(a[i], b[j])
        end
    end

    local pos = find_best(d, Position(1, 1), Position(m, n), Int64(window_size))

    local cost = pos.weight / pos.iter
    return cost
end

function find_best(
    D::Matrix{T},
    from::Position,
    to::Position,
    window_size::Int64,
) where {T}
    local m = size(D, 1)
    local n = size(D, 2)

    local pq = PriorityQueue{Step}((a, b) -> (a.weight < b.weight) ? a : b)
    push!(pq, Step(from, D[from.x, from.y], 1))

    local visited = Set{Position}()
    push!(visited, from)

    local tg = Float64(n) / m
    local routes = [(1, 1), (1, 0), (0, 1)]

    local founds = Vector{Step}()
    while pq.size > 0
        local cur = pop!(pq)

        if to == cur.pos
            push!(founds, cur)
            continue
        end

        for route in routes
            local next = Position(cur.pos.x + route[1], cur.pos.y + route[2])
            if next.x > m || next.y > n
                continue
            end

            local dy = next.x * tg
            local dx = next.y / tg
            if abs(next.x - dx) > window_size || abs(next.y - dy) > window_size
                continue
            end

            if next in visited
                continue
            end

            push!(pq, Step(next, cur.weight + D[next.x, next.y], cur.iter + 1))
            push!(visited, next)
        end
    end

    return founds[argmin(map(a -> a.weight, founds))]
end
