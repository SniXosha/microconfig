native-image \
    -H:+TraceClassInitialization \
    --initialize-at-build-time=io.microconfig.core.properties.io.ioservice.selector.ConfigFormatDetector \
    --initialize-at-build-time=io.microconfig.core.properties.resolver.PropertyResolverHolder \
    --initialize-at-build-time=io.microconfig.core.properties.resolver.PropertyResolver \
    --initialize-at-build-time=io.microconfig.core.environments.EnvironmentProvider \
    --initialize-at-build-time=io.microconfig.core.properties.ConfigProvider \
    --initialize-at-build-time=io.microconfig.core.properties.Property \
    --initialize-at-build-time=io.microconfig.core.properties.resolver.EnvComponent \
    --initialize-at-build-time=io.microconfig.core.environments.Component \
    --allow-incomplete-classpath \
    --report-unsupported-elements-at-runtime \
    -jar microconfig/microconfig-core/build/libs/microconfig-core-3.11.1.jar

    #    -H:+PrintClassInitialization \
