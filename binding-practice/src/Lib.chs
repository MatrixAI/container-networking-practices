{-# LANGUAGE ForeignFunctionInterface #-}
module Lib where

import Prelude hiding (sin)

import Foreign.C -- get the C types
import Foreign.Ptr (Ptr,nullPtr)

-- pure function
foreign import ccall "sin" c_sin :: CDouble -> CDouble
sin :: Double -> Double
sin d = realToFrac (c_sin (realToFrac d))

-- impure function
foreign import ccall "time" c_time :: Ptr a -> IO CTime
getTime :: IO CTime
getTime = c_time nullPtr


foreign import ccall "add" c_add :: CInt -> CInt -> CInt
add :: Int -> Int -> Int
add x y = fromIntegral $ c_add (fromIntegral x) (fromIntegral y)

foreign import ccall "get_pi" c_get_pi :: CDouble
getPi :: Double
getPi = realToFrac c_get_pi
