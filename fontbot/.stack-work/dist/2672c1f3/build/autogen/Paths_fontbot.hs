module Paths_fontbot (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "C:\\Users\\Piotr\\Documents\\fontbot\\fontbot\\.stack-work\\install\\b6a8628b\\bin"
libdir     = "C:\\Users\\Piotr\\Documents\\fontbot\\fontbot\\.stack-work\\install\\b6a8628b\\lib\\x86_64-windows-ghc-7.10.3\\fontbot-0.1.0.0-5qm1VOxKmoN63Q901jcL3H"
datadir    = "C:\\Users\\Piotr\\Documents\\fontbot\\fontbot\\.stack-work\\install\\b6a8628b\\share\\x86_64-windows-ghc-7.10.3\\fontbot-0.1.0.0"
libexecdir = "C:\\Users\\Piotr\\Documents\\fontbot\\fontbot\\.stack-work\\install\\b6a8628b\\libexec"
sysconfdir = "C:\\Users\\Piotr\\Documents\\fontbot\\fontbot\\.stack-work\\install\\b6a8628b\\etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "fontbot_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "fontbot_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "fontbot_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "fontbot_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "fontbot_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
