module TestAqua

using Aqua
using Patchwork
using Test

@testset "Aqua" begin
    Aqua.test_ambiguities(Patchwork, recursive = false)
    Aqua.test_all(Patchwork, ambiguities = false)
    return nothing
end

end
