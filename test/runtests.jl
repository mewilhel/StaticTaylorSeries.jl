using Test

# Skipping tests with intervals, since IntervalArithmetic.jl requires Julia v1.1+
if !(VERSION < v"1.1" && testfile == "intervals.jl")
    using TaylorSeries, StaticTaylorSeries, IntervalArithmetic

    function test_vs_Taylor1(x, y)
        flag = true
        for i in 0:2
            if x[i] !== y[i]
                flag = false
                break
            end
        end
        flag
    end

    @testset "Tests for STaylor1 expansions" begin

        @test STaylor1 <: AbstractSeries
        @test STaylor1{1,Float64} <: AbstractSeries{Float64}
        @test STaylor1([1.0, 2.0]) == STaylor1((1.0, 2.0))
        @test STaylor1(STaylor1((1.0, 2.0))) == STaylor1((1.0, 2.0))
        @test STaylor1(1.0, Val(2)) == STaylor1((1.0, 0.0, 0.0))

        @test +STaylor1([1.0, 2.0, 3.0]) == STaylor1([1.0, 2.0, 3.0])
        @test -STaylor1([1.0, 2.0, 3.0]) == -STaylor1([1.0, 2.0, 3.0])
        @test STaylor1([1.0, 2.0, 3.0]) + STaylor1([3.0, 2.0, 3.0]) == STaylor1([4.0, 4.0, 6.0])
        @test STaylor1([1.0, 2.0, 3.0]) - STaylor1([3.0, 2.0, 4.0]) == STaylor1([-2.0, 0.0, -1.0])
        @test STaylor1([1.0, 2.0, 3.0]) + 2.0 == STaylor1([3.0, 2.0, 3.0])
        @test STaylor1([1.0, 2.0, 3.0]) - 2.0 == STaylor1([-1.0, 2.0, 3.0])
        @test 2.0 + STaylor1([1.0, 2.0, 3.0]) == STaylor1([3.0, 2.0, 3.0])
        @test 2.0 - STaylor1([1.0, 2.0, 3.0]) == STaylor1([1.0, -2.0, -3.0])

        @test zero(STaylor1([1.0, 2.0, 3.0])) == STaylor1([0.0, 0.0, 0.0])
        @test one(STaylor1([1.0, 2.0, 3.0])) == STaylor1([1.0, 0.0, 0.0])

        @test isinf(STaylor1([Inf, 2.0, 3.0])) && ~isinf(STaylor1([0.0, 0.0, 0.0]))
        @test isnan(STaylor1([NaN, 2.0, 3.0])) && ~isnan(STaylor1([1.0, 0.0, 0.0]))
        @test iszero(STaylor1([0.0, 0.0, 0.0])) && ~iszero(STaylor1([0.0, 1.0, 0.0]))

        @test length(STaylor1([0.0, 0.0, 0.0])) == 3
        @test size(STaylor1([0.0, 0.0, 0.0])) == 3
        @test firstindex(STaylor1([0.0, 0.0, 0.0])) == 0
        @test lastindex(STaylor1([0.0, 0.0, 0.0])) == 2

        st1 = STaylor1([1.0, 2.0, 3.0])
        @test st1(2.0) == 41.0
        @test st1() == 1.00
        st2 = typeof(st1)[st1; st1]
        @test st2(2.0)[1] == st2(2.0)[2] == 41.0
        @test st2()[1] == st2()[2] == 1.0
        @test StaticTaylorSeries.evaluate(st1,2.0) == 41.0
        @test StaticTaylorSeries.evaluate(st1) == 1.00
        @test StaticTaylorSeries.evaluate(st2,2.0)[1] == StaticTaylorSeries.evaluate(st2,2.0)[2] == 41.0
        @test StaticTaylorSeries.evaluate(st2)[1] == StaticTaylorSeries.evaluate(st2)[2] == 1.0

        # check that STaylor1 and Taylor yeild same result
        t1 = STaylor1([1.1, 2.1, 3.1])
        t2 = Taylor1([1.1, 2.1, 3.1])
        for f in (exp, abs, log, sin, cos, sinh, cosh, mod2pi, sqrt)
            @test test_vs_Taylor1(f(t1), f(t2))
        end

        t1_mod = mod(t1, 2.0)
        t2_mod = mod(t2, 2.0)
        @test isapprox(t1_mod[0], t2_mod[0], atol=1E-10)
        @test isapprox(t1_mod[1], t2_mod[1], atol=1E-10)
        @test isapprox(t1_mod[2], t2_mod[2], atol=1E-10)

        t1_rem = rem(t1, 2.0)
        t2_rem = rem(t2, 2.0)
        @test isapprox(t1_rem[0], t2_rem[0], atol=1E-10)
        @test isapprox(t1_rem[1], t2_rem[1], atol=1E-10)
        @test isapprox(t1_rem[2], t2_rem[2], atol=1E-10)

        t1a = STaylor1([2.1, 2.1, 3.1])
        t2a = Taylor1([2.1, 2.1, 3.1])

        for test_tup in ((/, t1, t1a, t2, t2a), (*, t1, t1a, t2, t2a),
                         (/, t1, 1.3, t2, 1.3), (*, t1, 1.3, t2, 1.3),
                         (+, t1, 1.3, t2, 1.3), (-, t1, 1.3, t2, 1.3),
                         (*, 1.3, t1, 1.3, t2), (+, 1.3, t1, 1.3, t2),
                         (-, 1.3, t1, 1.3, t2),  (*, 1.3, t1, 1.3, t2),
                         (^, t1, 0, t2, 0), (^, t1, 1, t2, 1),
                         (^, t1, 2, t2, 2), (^, t1, 3, t2, 3),
                         (^, t1, 4, t2, 4),  (/, 1.3, t1, 1.3, t2),
                         (^, t1, -1, t2, -1), (^, t1,-2, t2, -2),
                         (^, t1, -3, t2, -3), (^, t1, 0.6, t2, 0.6),
                         (^, t1, 1/2, t2, 1/2))

            temp1 = test_tup[1](test_tup[2], test_tup[3])
            temp2 = test_tup[1](test_tup[4], test_tup[5])
            @test isapprox(temp1[0], temp2[0], atol=1E-10)
            @test isapprox(temp1[1], temp2[1], atol=1E-10)
            @test isapprox(temp1[2], temp2[2], atol=1E-10)
        end

        @test isapprox(StaticTaylorSeries.square(t1)[0], (t2^2)[0], atol=1E-10)
        @test isapprox(StaticTaylorSeries.square(t1)[1], (t2^2)[1], atol=1E-10)
        @test isapprox(StaticTaylorSeries.square(t1)[2], (t2^2)[2], atol=1E-10)

        a = STaylor1([0.0, 1.2, 2.3, 4.5, 0.0])
        @test findfirst(a) == 1
        @test findlast(a) == 3

        eval_staylor = StaticTaylorSeries.evaluate(a, Interval(1.0,2.0))
        @test isapprox(eval_staylor.lo, 7.99999, atol = 1E-4)
        @test isapprox(eval_staylor.hi, 47.6001, atol = 1E-4)

        a = STaylor1([5.0, 1.2, 2.3, 4.5, 0.0])
        @test isapprox(deg2rad(a)[0], 0.087266, atol=1E-5)
        @test isapprox(deg2rad(a)[2], 0.040142, atol=1E-5)
        @test isapprox(rad2deg(a)[0], 286.4788975, atol=1E-5)
        @test isapprox(rad2deg(a)[2], 131.7802928, atol=1E-5)
        @test real(a) == STaylor1([5.0, 1.2, 2.3, 4.5, 0.0])
        @test imag(a) == STaylor1([0.0, 0.0, 0.0, 0.0, 0.0])
        @test adjoint(a) == STaylor1([5.0, 1.2, 2.3, 4.5, 0.0])
        @test conj(a) == STaylor1([5.0, 1.2, 2.3, 4.5, 0.0])
        @test a == abs(a)
        @test a == abs(-a)

        @test convert(STaylor1{3,Float64}, STaylor1{3,Float64}((1.1, 2.2, 3.3))) == STaylor1{3,Float64}((1.1, 2.2, 3.3))
        @test convert(STaylor1{3,Float64}, 1) == STaylor1(1.0, Val(3))
        @test convert(STaylor1{3,Float64}, 1.2) == STaylor1(1.2, Val(3))

        #ta(a) = STaylor1(1.0, Val(15))
        @test promote(1.0, STaylor1(1.0, Val(15)))[1] == STaylor1(1.0, Val(16))
        @test promote(0, STaylor1(1.0, Val(15)))[1] == STaylor1(0.0, Val(16))
        @test eltype(promote(STaylor1(1, Val(15)),2)[2]) == Int
        @test eltype(promote(STaylor1(1.0, Val(15)), 1.1)[2]) == Float64
        @test eltype(promote(0, STaylor1(1.0, Val(15)))[1]) == Float64
    end
end
