// Helper closures to make our buildExclusions DSL terse and readable
def gte = { v -> { nodeVersion -> nodeVersion >= v} }
def lt = { v -> { nodeVersion -> nodeVersion < v} }
def releaseType = { buildType -> buildType == 'release' }
def anyType = { buildType -> true }

def buildExclusions = [
  // Given a machine label, build type (release or !release) and a Node.js
  // major version number, determine which ones to _exclude_ from a build

  // -------------------------------------------------------
  // Machine Label,                   Build Type,  Node Version

  // Linux -------------------------------------------------
  [ /^centos6/,                       releaseType, lt(8)   ],
  [ /^centos6/,                       anyType,     gte(12) ],
  [ /centos[67]-(arm)?(64|32)-gcc48/, anyType,     gte(10) ],
  [ /centos[67]-(arm)?(64|32)-gcc6/,  anyType,     lt(10)  ],
  [ /centos6-32-gcc6/,                releaseType, gte(10) ], // 32-bit linux for <10 only
  [ /^centos7-64/,                    releaseType, lt(12)  ],
  [ /^centos7-ppcle/,                 anyType,     lt(10)  ],
  [ /^ppcle-ubuntu/,                  releaseType, gte(10) ],
  [ /debian8-x86/,                    anyType,     gte(10) ], // 32-bit linux for <10 only
  [ /debian8/,                        anyType,     gte(13) ],
  [ /^ubuntu1804/,                    anyType,     lt(10)  ], // probably temporary
  [ /^ubuntu1404-32/,                 anyType,     gte(10) ], // 32-bit linux for <10 only
  [ /^ubuntu1404-64/,                 anyType,     gte(12) ],
  [ /^ubuntu1604-32/,                 anyType,     gte(10) ], // 32-bit linux for <10 only

  // ARM  --------------------------------------------------
  [ /^debian8-docker-armv7$/,         releaseType, lt(10)  ],
  [ /^debian8-docker-armv7$/,         anyType,     gte(12) ],
  [ /^debian9-docker-armv7$/,         anyType,     lt(10)  ],
  [ /^pi1-docker$/,                   releaseType, gte(10) ],
  [ /^cross-compiler-armv[67]-gcc-4.8$/, anyType,  gte(10) ],
  [ /^cross-compiler-armv[67]-gcc-4.9/, anyType,   lt(10)  ],
  [ /^cross-compiler-armv[67]-gcc-4.9/, anyType,   gte(12) ],
  [ /^cross-compiler-armv[67]-gcc-6/, anyType,     lt(12)  ],

  // Windows -----------------------------------------------
  [ /vs2013/,                         anyType,     gte(6)  ],
  [ /vs2015/,                         anyType,     lt(6)   ],
  [ /vs2015/,                         anyType,     gte(10) ],
  [ /vs2017/,                         anyType,     lt(10)  ],

  // SmartOS -----------------------------------------------
  [ /^smartos15/,                     anyType,     lt(8)   ],
  [ /^smartos15/,                     anyType,     gte(10) ],
  [ /^smartos16/,                     anyType,     lt(8)   ],
  [ /^smartos16/,                     anyType,     gte(12) ],
  [ /^smartos17/,                     anyType,     lt(10)  ],
  [ /^smartos17/,                     anyType,     gte(12) ],
  [ /^smartos18/,                     anyType,     lt(12)  ],

  // PPC BE ------------------------------------------------
  [ /^ppcbe-ubuntu/,                  anyType,     gte(8)  ],

  // s390x -------------------------------------------------
  [ /s390x/,                          anyType,     lt(6)   ],

  // AIX61 -------------------------------------------------
  [ /aix61/,                          anyType,     lt(6)   ],

  // Shared libs docker containers -------------------------
  [ /sharedlibs_openssl111/,          anyType,     lt(11)  ],
  [ /sharedlibs_openssl110/,          anyType,     lt(9)   ],
  [ /sharedlibs_openssl110/,          anyType,     gte(12) ],
  [ /sharedlibs_openssl102/,          anyType,     gte(10) ],
  [ /sharedlibs_fips20/,              anyType,     gte(10) ],
  [ /sharedlibs_withoutintl/,         anyType,     lt(9)   ],
  [ /sharedlibs_withoutssl/,          anyType,     lt(10)  ],
  [ /sharedlibs_shared/,              anyType,     lt(9)   ],

  // OSX ---------------------------------------------------
  [ /^osx1010/,                       anyType,     gte(11) ],
  [ /^osx1011/,                       releaseType, lt(11)  ],
  
  // FreeBSD -----------------------------------------------
  [ /^freebsd10/,                     anyType,     gte(11) ],

  // Source / headers / docs -------------------------------
  [ /^osx1010-release-sources$/,      releaseType, gte(11) ],
  [ /^osx1011-release-sources$/,      releaseType, lt(11)  ],
  [ /^osx1011-release-sources$/,      releaseType, gte(12) ],
  [ /^centos7-release-sources$/,      releaseType, lt(12)  ],

  // -------------------------------------------------------
]

def canBuild = { nodeVersion, builderLabel, buildType ->
  buildExclusions.findResult(true) { // this works like an array.contains(), returns true (default) or false
    def match = it[0]
    def type = it[1]
    def version = it[2]

    if (version(nodeVersion) && type(buildType) && builderLabel =~ match)
      return false
    return null
  }
}

// setup for execution of the above rules

int nodeMajorVersion = -1
if (parameters['NODEJS_MAJOR_VERSION'])
  nodeMajorVersion = parameters['NODEJS_MAJOR_VERSION'].toString().toInteger()
println "Node.js major version: $nodeMajorVersion"
println "Node.js version: ${parameters['NODEJS_VERSION']}"

// NOTE: this assumes that the default "Slaves"->"Name" in the Configuration
// Matrix is left as "nodes", if it's changed then `it.nodes` below won't work
// and returning a result with a "nodes" property won't work.
result['nodes'] = []

// Before running this script, `def buildType = 'release'` or some other value
// to be able to use the appropriate `buildType` in the exclusions
def _buildType
try {
  _buildType = buildType
} catch (groovy.lang.MissingPropertyException e) {
  _buildType = 'test'
}

combinations.each{
  def builderLabel = it.nodes
  // Default to running all builders if nodeMajorVersion is still -1
  // (i.e. the version check failed)
  if (nodeMajorVersion >= 4) {
    if (!canBuild(nodeMajorVersion, builderLabel, _buildType)) {
      println "Skipping $builderLabel for Node.js $nodeMajorVersion"
      return
    }
  }
  result['nodes'].add(it)
}
