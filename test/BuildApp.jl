using Base.Test
using ApplicationBuilder; using BuildApp;

builddir = mktempdir()
@assert isdir(builddir)

@testset "HelloWorld.app" begin
@test 0 == include("build_examples/hello.jl")
@test isdir("$builddir/HelloWorld.app")
@test success(`$builddir/HelloWorld.app/Contents/MacOS/hello`)

# There shouldn't be a Libraries dir since none specified.
@test !isdir("$builddir/HelloWorld.app/Contents/Libraries")

# Ensure all dependencies on Julia libs are internal, so the app is portable.
@testset "No external Dependencies" begin
@test !success(pipeline(
                `otool -l "$builddir/HelloWorld.app/Contents/MacOS/hello"`,
                `grep 'julia'`,  # Get all julia deps
                `grep -v '@rpath'`))  # make sure all are relative.
end
end


function testRunAndKillProgramSucceeds(cmd)
    out, _, p = readandwrite(cmd) # Make sure it runs correctly
    sleep(1)
    process_exited(p) && (println("Test Failed: failed to launch: \n", readstring(out)); return false)
    sleep(10)
    process_exited(p) && (println("Test Failed: Process died: \n", readstring(out)); return false)
    # Manually kill program after it's been running for a bit.
    kill(p); sleep(1)
    process_exited(p) || (println("Test Failed: Process failed to exit: \n", readstring(out)); return false)
    return true
end

@testset "HelloBlink.app" begin
@test 0 == include("build_examples/blink.jl")

@test isdir("$builddir/HelloBlink.app")
# Test that it copied the correct files
@test isdir("$builddir/HelloBlink.app/Contents/Libraries")
@test isfile("$builddir/HelloBlink.app/Contents/Resources/main.js")
# Test that it runs correctly
@test testRunAndKillProgramSucceeds(`$builddir/HelloBlink.app/Contents/MacOS/blink`)
end