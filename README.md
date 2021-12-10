# rc

This repository contains the PureDarwin build automation system. It's
essentially a complete rebuild of darwinbuild to use modern concepts
and build techniques. This project will be written primarily in Swift.

A CMake-based build script will be included to create a precompiled “rc-home”
binary artifact, which will be uploaded as part of creating a rc release and
used by GitHub Actions. The rc-home can be downloaded, extracted, and
run immediately from wherever it is on the file system.
