export dtw

using Spandex

struct Position
    x::Int64
    y::Int64
end

struct Solution
    pos::Position
    iter::Int64
    cost::Float64
    weight::Float64
end

function dtw(
    a::Vector{T},
    b::Vector{T},
    distance,
    window_size::Number = -1,
) where {T}
    local m = length(a)
    local n = length(b)

    if typeof(window_size) != Int
        window_size = Int64(round(min(m, n) * window_size))
    end
    if window_size < 0
        window_size = max(m, n)
    end

    local d = Matrix{T}(undef, m, n)
    fill!(d, typemax(T))
    for i = 1:m
        for j = max(1, i - window_size):min(n, i + window_size)
            d[i, j] = distance(a[i], b[j])
        end
    end

    local D = copy(d)
    for i = 1:m
        for j = max(1, i - window_size):min(n, i + window_size)
            if 1 == i && 1 == j
                continue
            end

            local d1 = typemax(T)
            if i > 1
                d1 = D[i-1, j]
            end
            local d2 = typemax(T)
            if j > 1
                d2 = D[i, j-1]
            end
            local d3 = typemax(T)
            if i > 1 && j > 1
                d3 = D[i-1, j-1]
            end

            D[i, j] += min(d1, min(d2, d3))
        end
    end

    local solution =
        find_best(d, D, Position(1, 1), Position(m, n), Int64(window_size))

    return solution.cost / Float64(solution.iter)
end

function find_best(
    d::Matrix{T},
    D::Matrix{T},
    from::Position,
    to::Position,
    window_size::Int64,
) where {T}
    local m = size(D, 1)
    local n = size(D, 2)

    local pq = PriorityQueue{Solution}((a, b) -> (a.weight < b.weight) ? a : b)
    push!(pq, Solution(from, 1, d[from.x, from.y], D[from.x, from.y]))

    local visited = Dict{Position,Float64}()
    visited[from] = D[from.x, from.y]

    local tg = Float64(n) / m
    local routes = [(1, 1), (1, 0), (0, 1)]

    local found = missing
    while pq.size > 0
        local cur = pop!(pq)

        if to == cur.pos
            found = cur
            break
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

            local new_weight = cur.weight + D[next.x, next.y]
            if haskey(visited, next)
                if visited[next] < new_weight
                    continue
                end
            end
            visited[next] = new_weight

            push!(
                pq,
                Solution(
                    next,
                    cur.iter + 1,
                    cur.cost + d[next.x, next.y],
                    new_weight,
                ),
            )
        end
    end

    return found
end
