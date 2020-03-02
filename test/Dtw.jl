using Test
using TimeMachine

@testset "dtw 1" begin
    local cost = dtw([1, 2, 4, 1, 2], [1, 2, 4, 1, 2], (a, b) -> abs(a - b))
    @test 0.0 == cost

    cost = dtw([2, 6, 5, 3, 2], [1, 2, 4, 1, 2], (a, b) -> abs(a - b))

    @test 1 == cost
end

@testset "dtw 2" begin
    local a = [1, 1, 1, 2, 4, 6, 5, 5, 5, 4, 4, 3, 1, 1, 1]
    local b = [1, 1, 2, 4, 6, 6, 6, 5, 4, 4, 4, 3, 3, 3, 1]
    local cost = dtw(a, b, (a, b) -> (a - b)^2)

    @test 0.0 == cost

    a[end] += 2
    cost = dtw(a, b, (a, b) -> (a - b)^2)
    @test 0.2 == cost

    a = collect(1:10)
    b = a .+ 1
    cost = dtw(a, b, (a, b) -> (a - b)^2)
    @test (2.0 / 11.0) == cost
end
