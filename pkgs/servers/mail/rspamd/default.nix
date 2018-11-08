{ stdenv, lib, fetchFromGitHub, cmake, perl
, file, glib, libevent, luajit, openssl, pcre, pkgconfig, sqlite, ragel, icu
, hyperscan, libfann, gd, jemalloc, openblas
, withFann ? true
, withGd ? false
, withBlas ? true
, withHyperscan ? stdenv.isx86_64
}:

assert withHyperscan -> stdenv.isx86_64;

let libmagic = file;  # libmagic provided by file package ATM
in

stdenv.mkDerivation rec {
  name = "rspamd-${version}";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "vstakhov";
    repo = "rspamd";
    rev = version;
    sha256 = "1cgnychv8yz7a6mjg3b12nzs4gl0xqg9agl7m6faihnh7gqx4xld";
  };

  nativeBuildInputs = [ cmake pkgconfig perl ];
  buildInputs = [ glib libevent libmagic luajit openssl pcre sqlite ragel icu jemalloc ]
    ++ lib.optional withFann libfann
    ++ lib.optional withGd gd
    ++ lib.optional withHyperscan hyperscan
    ++ lib.optional withBlas openblas;

  cmakeFlags = [
    "-DDEBIAN_BUILD=ON"
    "-DRUNDIR=/var/run/rspamd"
    "-DDBDIR=/var/lib/rspamd"
    "-DLOGDIR=/var/log/rspamd"
    "-DLOCAL_CONFDIR=/etc/rspamd"
    "-DENABLE_JEMALLOC=ON"
  ] ++ lib.optional withFann "-DENABLE_FANN=ON"
    ++ lib.optional withHyperscan "-DENABLE_HYPERSCAN=ON"
    ++ lib.optional withGd "-DENABLE_GD=ON";

  meta = with stdenv.lib; {
    homepage = https://github.com/vstakhov/rspamd;
    license = licenses.asl20;
    description = "Advanced spam filtering system";
    maintainers = with maintainers; [ avnik fpletz ];
    platforms = with platforms; linux;
  };
}
