using ApplicationBuilder; using BuildApp

# Allow this file to be called either as a standalone file to build the above
# example, or from runtests.jl using a provided builddir.
isdefined(:builddir) || (builddir=mktempdir())

libUIPkg = Pkg.dir("Libui")

@assert libUIPkg != nothing "LibUI is not installed!"

using Libui

BuildApp.build_app_bundle(joinpath(@__DIR__, "..", "..", "examples", "libui.jl");
    verbose = true,
    resources = [],
    libraries = [ Libui.libui ],
    appname="HelloLibui", builddir=builddir)
