# Class Compiler

This is the compiler that we built in lecture.
I will keep it up to date as we move through the course.

Changes won't necessarily be purely additive, so 
you may want to look at the commit history 
if you want a point-in-time snapshot.

## Unofficial Install Guide

For [utop history](https://github.com/ocaml-community/utop/issues/478): `mkdir -r ~/.local/state`

## *Alternative* Use the class-configured devcontainer environment

[Motivation]: Provide a cross platform environment that avoids OS specific flags in parts of our compiler toolchain, such as `gcc -arch`.

This option is provided for those who want to follow along in their own environment, and do have access to the following standard development tools:

1. docker
2. git

Option 1 - Use locally with VSCode: 

1. Clone this repository 
2. Open this folder with VSCode, having the Dev Containers plugin installed. A popup directing you to open a *development container* will appear. Click on that popup.
3. Run `bash install-dependencies.sh` to automatically install all the OCaml dependencies 
4. As a first step, try running `dune runtest -f`

Option 2 - Leverage the Cloud via GitHub Codespaces:

1. Go to this repository on Github
2. Click the bright green button that says 'Code'
3. There are two tabs at the top - Local and Codespaces. Click on Codespaces.
4. Hit Create codespace on main, and your development environment will start booting up.
5. Run `bash install-dependencies.sh` to automatically install all the OCaml dependencies 
6. As a first step, try running `dune runtest -f`



## How to run

```sh
# to run the tests
dune runtest -f

# to run the interpreter...
# on a string
dune exec bin/interp.exe -- -e "(add1 5)"
# or on a file
dune exec bin/interp.exe examples/unary-nums.lisp 


# to run the compiler
# it puts the executable and assembly in directory "output/"
dune exec bin/compile.exe examples/unary-nums.lisp output/
```