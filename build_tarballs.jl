# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "LibPQ"
version = v"18.1.0"
tzcode_version = "2025a"

# Collection of sources required to build LibPQ
sources = [
    ArchiveSource(
        "https://ftp.postgresql.org/pub/source/v18.1/postgresql-18.1.tar.gz",
        "b0f18c2d6973d2aa023cfc77feda787d7bbe9c31a3977d0f04ac29885fb98ec4",
        unpack_target="postgres",
    ),
    ArchiveSource(
        "https://data.iana.org/time-zones/releases/tzcode$tzcode_version.tar.gz",
        "119679d59f76481eb5e03d3d2a47d7870d592f3999549af189dbd31f2ebf5061",
        unpack_target="zic-build",
    ),
]

# Bash recipe for building across all platforms
script = raw"""
cd zic-build
make CC=$BUILD_CC VERSION_DEPS= zic
mv zic ../ && cd ../ && rm -rf zic-build
export ZIC=$WORKSPACE/srcdir/zic
export PATH=$WORKSPACE/srcdir:$PATH

cd postgres/postgresql-*

# Set up proper environment for dependencies
export CPPFLAGS="-I${includedir}"
export LDFLAGS="-L${libdir}"
export LD_LIBRARY_PATH="${libdir}:${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${prefix}/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Configure flags based on platform
# OAuth (libcurl) is only supported on Linux and macOS
# GSSAPI is only supported on Linux
if [[ "${target}" == *-linux-* ]]; then
    OAUTH_FLAG="--with-libcurl"
    GSSAPI_FLAG="--with-gssapi"
    # On musl, we need to explicitly link libcurl's dependencies
    if [[ "${target}" == *-musl* ]]; then
        export LIBS="-lcurl -lssl -lcrypto -lnghttp2 -lssh2 -lz"
    fi
elif [[ "${target}" == *-apple-* ]]; then
    OAUTH_FLAG="--with-libcurl"
    GSSAPI_FLAG=""
else
    # Windows and other platforms
    OAUTH_FLAG=""
    GSSAPI_FLAG=""
fi

./configure --prefix=${prefix} \
    --build=${MACHTYPE} \
    --host=${target} \
    --with-includes=${includedir} \
    --with-libraries=${libdir} \
    --without-readline \
    --without-zlib \
    --with-ssl=openssl \
    ${OAUTH_FLAG} \
    ${GSSAPI_FLAG}

make -C src/interfaces/libpq -j${nproc}
make -C src/interfaces/libpq install
make -C src/include install

# Delete static library
rm -f ${prefix}/lib/libpq.a

install_license COPYRIGHT
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
# Filter to x86_64 and aarch64 only
filter!(p -> arch(p) in ("x86_64", "aarch64"), platforms)
# Exclude FreeBSD - it has compiler compatibility issues with the current setup
filter!(p -> !Sys.isfreebsd(p), platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libpq", :libpq),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    HostBuildDependency("Bison_jll"),
    Dependency("LibCURL_jll"),
    Dependency("OpenSSL_jll"; compat="3.0.16"),
    Dependency("Kerberos_krb5_jll"; compat="1.21.3", platforms=filter(p -> Sys.islinux(p), platforms)),
    Dependency("ICU_jll"; compat="76.1"),
    Dependency("Zstd_jll"; compat="1.5.7"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", preferred_gcc_version=v"7")