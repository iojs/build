#!/bin/bash

if [ "$DONTSELECT_COMPILER" != "DONT" ]; then
  case $NODE_NAME in
    *ppc64_le* ) SELECT_ARCH=PPC64LE ;;
    *s390x* ) SELECT_ARCH=S390X ;;
    *aix* ) SELECT_ARCH=AIXPPC ;;
  esac
fi

# get node version
if [ -z ${NODEJS_MAJOR_VERSION+x} ]; then
  NODE_VERSION="$(python tools/getnodeversion.py)"
  NODEJS_MAJOR_VERSION="$(echo "$NODE_VERSION" | cut -d . -f 1)"
fi

if [ "$SELECT_ARCH" = "PPC64LE" ]; then
  # Set default
  export COMPILER_LEVEL="4.8"

  echo "Setting compiler for Node version $NODEJS_MAJOR_VERSION on ppc64le"

  if [ "$NODEJS_MAJOR_VERSION" -gt "11" ]; then
    # See: https://github.com/nodejs/build/pull/1723#discussion_r265740122
    export PATH=/usr/lib/binutils-2.26/bin/:$PATH
    export COMPILER_LEVEL="6"
  elif [ "$NODEJS_MAJOR_VERSION" -gt "9" ]; then
    export PATH=/usr/lib/binutils-2.26/bin/:$PATH
    export COMPILER_LEVEL="4.9"
  fi

  # Select the appropriate compiler
  export CC="gcc-${COMPILER_LEVEL}"
  export CXX="g++-${COMPILER_LEVEL}"
  export LINK="g++-${COMPILER_LEVEL}"

  echo "Compiler set to $COMPILER_LEVEL"

elif [ "$SELECT_ARCH" = "S390X" ]; then

  # Set default
  # Default is 4.8 but it does not have the prefixes
  export COMPILER_LEVEL=""

  echo "Setting compiler for Node version $NODEJS_MAJOR_VERSION on s390x"

  if [ "$NODEJS_MAJOR_VERSION" -gt "11" ]; then
    export PATH="/data/gcc-6.3/bin:/data/binutils-2.28/bin:$PATH"
    export LD_LIBRARY_PATH="/data/gcc-6.3/lib64:$LD_LIBRARY_PATH"
    export COMPILER_LEVEL="-6.3"
  elif [ "$NODEJS_MAJOR_VERSION" -gt "9" ]; then
    export PATH="/data/gcc-4.9/bin:/data/binutils-2.28/bin:$PATH"
    export LD_LIBRARY_PATH="/data/gcc-4.9/lib64:$LD_LIBRARY_PATH"
    export COMPILER_LEVEL="-4.9"
  fi

  # Select the appropriate compiler
  export CC="ccache gcc${COMPILER_LEVEL}"
  export CXX="ccache g++${COMPILER_LEVEL}"
  export LINK="g++${COMPILER_LEVEL}"

  echo "Compiler set to $COMPILER_LEVEL"

elif [ "$SELECT_ARCH" = "AIXPPC" ]; then
  # get node version
  echo "Setting compiler for Node version $NODEJS_MAJOR_VERSION on AIX"

  if [ "$NODEJS_MAJOR_VERSION" -gt "9" ]; then
    export LIBPATH=/home/iojs/gmake/opt/freeware/lib:/home/iojs/gcc-6.3.0-1/opt/freeware/lib/gcc/powerpc-ibm-aix6.1.0.0/6.3.0/pthread/ppc64:/home/iojs/gcc-6.3.0-1/opt/freeware/lib
    export PATH="/home/iojs/gcc-6.3.0-1/opt/freeware/bin:$PATH"
    export CC="ccache `which gcc`" CXX="ccache `which g++`" CXX_host="ccache `which g++`"
    echo "Compiler set to 6.3"
  else
    export CC="ccache `which gcc`" CXX="ccache `which g++`" CXX_host="ccache `which g++`"
    echo "Compiler set to default at 4.8.5"
  fi
fi
