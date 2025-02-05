# create CC, CXX, CC_host and CXX_host environment variables appropriate for the
# worker label in use. Of the form: cross-compiler-ubuntu1[68]04-armv[67]-gcc-(4\.9.4?|6|8)

# Expected labels:
# cross-compiler-ubuntu1604-armv6-gcc-4.9.4
# cross-compiler-ubuntu1604-armv7-gcc-4.9.4
# cross-compiler-ubuntu1604-armv7-gcc-6
# cross-compiler-ubuntu1804-armv7-gcc-6
# cross-compiler-ubuntu1804-armv7-gcc-8
# cross-compiler-rhel8-armv7-gcc-8-glibc-2.28
# cross-compiler-rhel8-armv7-gcc-10-glibc-2.28
# cross-compiler-rhel9-armv7-gcc-12-glibc-2.28

rpi_newer_tools_base="/opt/raspberrypi/rpi-newer-crosstools/"
base_4_9_4="${rpi_newer_tools_base}x64-gcc-4.9.4-binutils-2.28/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"
base_6="${rpi_newer_tools_base}x64-gcc-6.5.0/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"
base_8="${rpi_newer_tools_base}x64-gcc-8.3.0/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"
base_8_glibc_2_28="${rpi_newer_tools_base}x64-gcc-8.3.0-glibc-2.28/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"
base_10_glibc_2_28="${rpi_newer_tools_base}x64-gcc-10.3.0-glibc-2.28/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"
base_12_glibc_2_28="${rpi_newer_tools_base}x64-gcc-12.3.0-glibc-2.28/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-"

flags_armv6="-march=armv6zk"
flags_armv7="-march=armv7-a"

function run {
  local label="$1"

  export arm_type=$(echo $label | sed -E 's/^cross-compiler-(ubuntu1[68]04|rhel[89])-(armv[67])-gcc-.*$/\2/')
  export gcc_version=$(echo $label | sed -E 's/^cross-compiler-(ubuntu1[68]04|rhel[89])-armv[67]-gcc-(4\.9\.4|6|8|10|12)/\2/')
  export git_branch="cc-${arm_type}"
  export host_os=$(echo $label | sed -E 's/^cross-compiler-(ubuntu1[68]04|rhel[89])-(armv[67])-gcc-.*$/\1/')

  if [[ ! "$arm_type" =~ ^armv[67]$ ]]; then
    echo "Could not determine ARM type from '$label'"
    exit 1
  fi
  if [[ ! "$gcc_version" =~ ^(4\.9\.4|6|8|8-glibc-2\.28|10-glibc-2\.28|12-glibc-2\.28)$ ]]; then
    echo "Could not determine gcc version from '$label'"
    exit 1
  fi

  gcc_version_safe="$(echo $gcc_version | sed -E 's/[\.-]/_/g')"
  gcc_host_version="$(echo $gcc_version | sed -E 's/([^-]+).*$/\1/g' | sed -E 's/\.4//g')" # 4.9.4 -> 4.9
  base_varname="base_${gcc_version_safe}"
  flags_varname="flags_${arm_type}"

  echo "ARM variant:           $arm_type"
  echo "GCC version:           $gcc_version"
  echo "Using compiler at:     ${!base_varname}gcc"
  echo "Using commpiler flags: ${!flags_varname}"

  export ARCH="${arm_type}l"
  export DESTCPU=arm
  if [ "$host_os" = "rhel8" ] || [ "$host_os" = "rhel9" ]; then
    current_gcc_version="$(gcc -dumpversion)"
    # Additional gcc versions are installed via gcc-toolset-<n> packages.
    # No such package exists for the default gcc version (8 on RHEL 8,
    # 11 on RHEL 9).
    if [ "${current_gcc_version}" != "${gcc_host_version}" ]; then
      if ! . /opt/rh/gcc-toolset-${gcc_host_version}/enable; then
        echo "Host gcc version mismatch (wanted ${gcc_host_version} but got ${current_gcc_version})."
        exit 1
      fi
    fi
    export CC_host="ccache gcc -m32"
    export CXX_host="ccache g++ -m32"
  else
    export CC_host="ccache gcc-${gcc_host_version} -m32"
    export CXX_host="ccache g++-${gcc_host_version} -m32"
  fi
  export CC="ccache ${!base_varname}gcc ${!flags_varname}"
  export CXX="ccache ${!base_varname}g++ ${!flags_varname}"
}

run $1
