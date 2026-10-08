@echo off

SET BASEPATH=%~dp0

CALL julia --project=%BASEPATH% -e "using Pkg; Pkg.develop(PackageSpec(path=dirname(pwd()))); Pkg.instantiate()"
CALL julia --project=%BASEPATH% %BASEPATH%\make.jl