# rc

This repository contains the PureDarwin build automation system. It's
essentially a simpler version of darwinbuild that uses modern concepts
and best practices. This project will be written primarily in Swift.

A script will be provided to create a precompiled “rc-home”
binary artifact, which will be uploaded as part of creating a rc
release and used by GitHub Actions. Programs in the rc-home can be
downloaded, extracted, and run; no installation is required.
