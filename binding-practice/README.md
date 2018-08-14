# Binding practice
The goal of this project is to be able to call C functions from Haskell.

We will try binding into a c function `int add(int x, int y)` which adds x and y together (pure - no IO operation).

# Nix environment

Clone the [GraphQL-Demo repo from Matrix AI's Github](https://github.com/MatrixAI/GraphQL-Demo).

This contains the default nix file that we use for our Haskell projects. We use the same channel hash so all our applications will be compatible with each other.

Add the c2hs package `haskellPackages.c2hs` into `buildInputs` of the `shell.nix` file.

`shell.nix` should look like this:
```
{
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/8b1cf100cd8badad6e1b6d4650b904b88aa870db.tar.gz) {}
}:
  with pkgs;
  haskell.lib.buildStackProject {
    name = "graphql-demo";
    buildInputs = [];
    shellHook = ''
      echo 'Entering GraphQL Demo Environment'
      set -v

      alias stack='\stack --nix'

      set +v
    '';
  }
```

c2hs is a Haskell FFI preprocessing tools that is useful for preprocessing

`nix-shell` will bring in the `.nix` environment and give you a new shell to work with.

# Set up package.yaml
`package.yaml` is a file where to specifies all our Haskell build dependencies, which is read by stack when you do `stack build`.

By the time I was writing this I was still using Cabal. The changes I made to [the cabal file](/container-practices/binding-practices/binding-practice.cabal) can be found on [this tutorial](http://blog.ezyang.com/2010/06/setting-up-cabal-the-ffi-and-c2hs/).

Similar changes can be done to `package.yaml` by finding their corresponding attributes [on hpack's documentation](https://github.com/sol/hpack#top-level-fields). hpack is the format that defines package.yaml.

# C Code
It seems to be a convention to put all `.c` files in `src/cbits` and `.h` files in `src/include`. So..

Create `src/cbits/foo.c`
```C
// src/cbits/foo.c
int add(int x, inty) {
  return x + y
}
```

Create `src/include/foo.h`
```C
int add(int x, int y);
```

Now we have the C files that we want to bind into.

# Haskell Code
```Haskell
-- compiler pragma is needed to compile Haskell FFI
{-# LANGUAGE ForeignFunctionInterface #-}

module Lib where

import Foreign.C -- get the C types

-- add function
foreign import ccall "add" c_add :: CInt -> CInt -> CInt
add :: Int -> Int -> Int
add x y = fromIntegral $ c_add (fromIntegral x) (fromIntegral y)
```

The part that we are interested in is:
```haskell
foreign import ccall "add" c_add :: CInt -> CInt -> CInt
```
This line brings in the C function `"add"`, and change that into a Haskell function `c_add` that takes in two `CInt`s and returns a `CInt`.

However, we want to use `Int` rather than `CInt`. And to do that we create another function `add :: Int -> Int -> Int` that does the same thing. In fact I don't think the `fromIntegral` casting function is even necessary, since I remember both `CInt` and `Int` are Integrals and they can cast to one another interchangeably. I could be wrong though.

# After this
- In the actual practice I also included some examples of impure function calls, which would involve [IO monads](https://github.com/MatrixAI/Emergence/blob/master/language/haskell/2018:07:03:monadic-io-and-ffi.md).
- To pass complex data structures (such as c structs), the [`Storable`](http://hackage.haskell.org/package/base-4.11.1.0/docs/Foreign-Storable.html) typeclass is used.
