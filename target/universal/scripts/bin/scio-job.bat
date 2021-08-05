@REM scio-job launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM SCIO_JOB_config.txt found in the SCIO_JOB_HOME.
@setlocal enabledelayedexpansion
@setlocal enableextensions

@echo off


if "%SCIO_JOB_HOME%"=="" (
  set "APP_HOME=%~dp0\\.."

  rem Also set the old env name for backwards compatibility
  set "SCIO_JOB_HOME=%~dp0\\.."
) else (
  set "APP_HOME=%SCIO_JOB_HOME%"
)

set "APP_LIB_DIR=%APP_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%APP_HOME%\SCIO_JOB_config.txt"
set CFG_OPTS=
call :parse_config "%CFG_FILE%" CFG_OPTS

rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

set "APP_CLASSPATH=%APP_LIB_DIR%\example.scio-job-0.1.0-SNAPSHOT.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.13.3.jar;%APP_LIB_DIR%\com.spotify.scio-core_2.13-0.10.4.jar;%APP_LIB_DIR%\org.apache.beam.beam-runners-direct-java-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-runners-google-cloud-dataflow-java-2.30.0.jar;%APP_LIB_DIR%\org.slf4j.slf4j-simple-1.7.32.jar;%APP_LIB_DIR%\com.spotify.scio-macros_2.13-0.10.4.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.13.3.jar;%APP_LIB_DIR%\com.chuusai.shapeless_2.13-2.3.4.jar;%APP_LIB_DIR%\com.esotericsoftware.kryo-shaded-4.0.2.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.12.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-scala_2.13-2.12.1.jar;%APP_LIB_DIR%\com.github.alexarchambault.case-app_2.13-2.0.6.jar;%APP_LIB_DIR%\com.github.alexarchambault.case-app-annotations_2.13-2.0.6.jar;%APP_LIB_DIR%\com.google.api-client.google-api-client-1.31.3.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-dataflow-v1b3-rev20210408-1.31.0.jar;%APP_LIB_DIR%\com.google.auto.service.auto-service-1.0.jar;%APP_LIB_DIR%\com.google.guava.guava-30.1.1-jre.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-1.39.2.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-jackson2-1.39.2.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-3.17.3.jar;%APP_LIB_DIR%\com.twitter.chill-java-0.10.0.jar;%APP_LIB_DIR%\com.twitter.chill-protobuf-0.10.0.jar;%APP_LIB_DIR%\com.twitter.algebird-core_2.13-0.13.8.jar;%APP_LIB_DIR%\com.twitter.chill_2.13-0.10.0.jar;%APP_LIB_DIR%\com.twitter.chill-algebird_2.13-0.10.0.jar;%APP_LIB_DIR%\commons-io.commons-io-2.10.0.jar;%APP_LIB_DIR%\io.grpc.grpc-auth-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-core-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-netty-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-api-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-stub-1.37.0.jar;%APP_LIB_DIR%\io.netty.netty-handler-4.1.52.Final.jar;%APP_LIB_DIR%\joda-time.joda-time-2.10.10.jar;%APP_LIB_DIR%\me.lyh.protobuf-generic_2.13-0.2.9.jar;%APP_LIB_DIR%\org.apache.avro.avro-1.8.2.jar;%APP_LIB_DIR%\org.apache.beam.beam-runners-core-construction-java-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-core-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-extensions-protobuf-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-vendor-guava-26_0-jre-0.1.jar;%APP_LIB_DIR%\org.apache.commons.commons-compress-1.20.jar;%APP_LIB_DIR%\org.apache.commons.commons-math3-3.6.1.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.32.jar;%APP_LIB_DIR%\org.typelevel.algebra_2.13-2.2.3.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-collection-compat_2.13-2.4.4.jar;%APP_LIB_DIR%\com.propensive.magnolia_2.13-0.17.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-model-pipeline-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-vendor-grpc-1_36_0-0.1.jar;%APP_LIB_DIR%\org.checkerframework.checker-qual-3.10.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-extensions-google-cloud-platform-core-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-io-kafka-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-io-google-cloud-platform-2.30.0.jar;%APP_LIB_DIR%\com.google.cloud.bigdataoss.util-2.1.6.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.15.jar;%APP_LIB_DIR%\com.google.flogger.flogger-system-backend-0.6.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-clouddebugger-v2-rev20210326-1.31.0.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-storage-v1-rev20210127-1.31.0.jar;%APP_LIB_DIR%\com.google.auth.google-auth-library-credentials-0.25.2.jar;%APP_LIB_DIR%\com.google.auth.google-auth-library-oauth2-http-0.25.2.jar;%APP_LIB_DIR%\org.hamcrest.hamcrest-2.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.12.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.12.2.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-extensions-sql-2.30.0.jar;%APP_LIB_DIR%\com.esotericsoftware.minlog-1.3.0.jar;%APP_LIB_DIR%\org.objenesis.objenesis-2.5.1.jar;%APP_LIB_DIR%\com.github.alexarchambault.case-app-util_2.13-2.0.6.jar;%APP_LIB_DIR%\com.google.oauth-client.google-oauth-client-1.31.4.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-gson-1.39.2.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-apache-v2-1.39.0.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.4.14.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.5.13.jar;%APP_LIB_DIR%\com.google.auto.service.auto-service-annotations-1.0.jar;%APP_LIB_DIR%\com.google.auto.auto-common-1.0.jar;%APP_LIB_DIR%\com.google.guava.failureaccess-1.0.1.jar;%APP_LIB_DIR%\com.google.guava.listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.2.jar;%APP_LIB_DIR%\com.google.errorprone.error_prone_annotations-2.6.0.jar;%APP_LIB_DIR%\com.google.j2objc.j2objc-annotations-1.3.jar;%APP_LIB_DIR%\io.opencensus.opencensus-api-0.28.0.jar;%APP_LIB_DIR%\io.opencensus.opencensus-contrib-http-util-0.28.0.jar;%APP_LIB_DIR%\com.googlecode.javaewah.JavaEWAH-1.1.12.jar;%APP_LIB_DIR%\org.apache.xbean.xbean-asm7-shaded-4.15.jar;%APP_LIB_DIR%\org.codehaus.mojo.animal-sniffer-annotations-1.20.jar;%APP_LIB_DIR%\io.grpc.grpc-context-1.37.0.jar;%APP_LIB_DIR%\com.google.code.gson.gson-2.8.6.jar;%APP_LIB_DIR%\com.google.android.annotations-4.1.1.4.jar;%APP_LIB_DIR%\io.perfmark.perfmark-api-0.23.0.jar;%APP_LIB_DIR%\io.netty.netty-codec-http2-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-handler-proxy-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-common-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-resolver-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-buffer-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-transport-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-4.1.52.Final.jar;%APP_LIB_DIR%\org.codehaus.jackson.jackson-core-asl-1.9.13.jar;%APP_LIB_DIR%\org.codehaus.jackson.jackson-mapper-asl-1.9.13.jar;%APP_LIB_DIR%\com.thoughtworks.paranamer.paranamer-2.7.jar;%APP_LIB_DIR%\org.xerial.snappy.snappy-java-1.1.8.4.jar;%APP_LIB_DIR%\org.tukaani.xz-1.5.jar;%APP_LIB_DIR%\org.apache.beam.beam-model-job-management-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-fn-execution-2.30.0.jar;%APP_LIB_DIR%\io.github.classgraph.classgraph-4.8.104.jar;%APP_LIB_DIR%\org.apache.beam.beam-vendor-bytebuddy-1_10_8-0.1.jar;%APP_LIB_DIR%\org.typelevel.cats-kernel_2.13-2.6.1.jar;%APP_LIB_DIR%\com.propensive.mercator_2.13-0.2.1.jar;%APP_LIB_DIR%\commons-logging.commons-logging-1.2.jar;%APP_LIB_DIR%\org.apache.logging.log4j.log4j-api-2.6.2.jar;%APP_LIB_DIR%\org.conscrypt.conscrypt-openjdk-uber-2.5.1.jar;%APP_LIB_DIR%\org.apache.beam.beam-runners-core-java-2.30.0.jar;%APP_LIB_DIR%\com.google.cloud.bigdataoss.gcsio-2.1.6.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-cloudresourcemanager-v1-rev20210331-1.31.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-expansion-service-2.30.0.jar;%APP_LIB_DIR%\org.springframework.spring-expression-4.3.18.RELEASE.jar;%APP_LIB_DIR%\io.confluent.kafka-avro-serializer-5.3.2.jar;%APP_LIB_DIR%\io.confluent.kafka-schema-registry-client-5.3.2.jar;%APP_LIB_DIR%\com.google.api.gax-1.63.0.jar;%APP_LIB_DIR%\com.google.api.gax-grpc-1.63.0.jar;%APP_LIB_DIR%\com.google.api.gax-httpjson-0.80.0.jar;%APP_LIB_DIR%\com.google.api.api-common-1.10.1.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-bigquery-v2-rev20210410-1.31.0.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-healthcare-v1beta1-rev20210407-1.31.0.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-pubsub-v1-rev20210322-1.31.0.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-bigquerystorage-1.17.0.jar;%APP_LIB_DIR%\com.google.cloud.bigtable.bigtable-client-core-1.19.1.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-core-1.94.6.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-core-grpc-1.94.6.jar;%APP_LIB_DIR%\com.google.cloud.datastore.datastore-v1-proto-client-1.6.3.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-pubsublite-0.13.2.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-pubsub-1.112.0.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-spanner-6.2.0.jar;%APP_LIB_DIR%\io.grpc.grpc-alts-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-grpclb-1.37.0.jar;%APP_LIB_DIR%\io.grpc.grpc-netty-shaded-1.37.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-pubsub-v1-1.94.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-pubsublite-v1-0.13.2.jar;%APP_LIB_DIR%\org.hamcrest.hamcrest-core-2.1.jar;%APP_LIB_DIR%\junit.junit-4.13.1.jar;%APP_LIB_DIR%\io.netty.netty-tcnative-boringssl-static-2.0.33.Final.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigquerystorage-v1-1.17.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigquerystorage-v1beta2-0.117.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigtable-admin-v2-1.22.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigtable-v2-1.22.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-datastore-v1-0.89.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-pubsub-v1-1.94.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-pubsublite-v1-0.13.2.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-spanner-admin-database-v1-6.2.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-spanner-v1-6.2.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-common-protos-2.1.0.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-util-3.15.8.jar;%APP_LIB_DIR%\org.threeten.threetenbp-1.5.0.jar;%APP_LIB_DIR%\com.google.api-client.google-api-client-java6-1.30.10.jar;%APP_LIB_DIR%\com.google.api-client.google-api-client-jackson2-1.30.10.jar;%APP_LIB_DIR%\com.google.apis.google-api-services-iamcredentials-v1-rev20201022-1.30.10.jar;%APP_LIB_DIR%\com.google.auto.value.auto-value-annotations-1.7.4.jar;%APP_LIB_DIR%\com.google.oauth-client.google-oauth-client-java6-1.31.2.jar;%APP_LIB_DIR%\com.google.flogger.google-extensions-0.6.jar;%APP_LIB_DIR%\com.google.flogger.flogger-0.6.jar;%APP_LIB_DIR%\org.checkerframework.checker-compat-qual-2.5.5.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-extensions-join-library-2.30.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-extensions-sql-udf-2.30.0.jar;%APP_LIB_DIR%\org.apache.commons.commons-csv-1.8.jar;%APP_LIB_DIR%\org.apache.beam.beam-vendor-calcite-1_20_0-0.1.jar;%APP_LIB_DIR%\com.alibaba.fastjson-1.2.69.jar;%APP_LIB_DIR%\org.codehaus.janino.janino-3.0.11.jar;%APP_LIB_DIR%\org.codehaus.janino.commons-compiler-3.0.11.jar;%APP_LIB_DIR%\org.mongodb.mongo-java-driver-3.12.7.jar;%APP_LIB_DIR%\org.apache.beam.beam-sdks-java-io-mongodb-2.30.0.jar;%APP_LIB_DIR%\io.netty.netty-codec-http-4.1.52.Final.jar;%APP_LIB_DIR%\io.netty.netty-codec-socks-4.1.52.Final.jar;%APP_LIB_DIR%\org.apache.beam.beam-model-fn-execution-2.30.0.jar;%APP_LIB_DIR%\io.grpc.grpc-protobuf-1.37.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-iam-v1-1.0.11.jar;%APP_LIB_DIR%\com.github.rholder.guava-retrying-2.0.0.jar;%APP_LIB_DIR%\org.apache.beam.beam-runners-java-fn-execution-2.30.0.jar;%APP_LIB_DIR%\org.springframework.spring-core-4.3.18.RELEASE.jar;%APP_LIB_DIR%\io.confluent.common-config-5.3.2.jar;%APP_LIB_DIR%\io.confluent.common-utils-5.3.2.jar;%APP_LIB_DIR%\javax.annotation.javax.annotation-api-1.3.2.jar;%APP_LIB_DIR%\io.grpc.grpc-protobuf-lite-1.37.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigquerystorage-v1alpha2-0.117.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-bigquerystorage-v1beta1-0.117.0.jar;%APP_LIB_DIR%\org.json.json-20200518.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-bigquery-1.127.11.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-core-http-1.94.3.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-appengine-1.39.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-bigquerystorage-v1beta1-0.117.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-bigquerystorage-v1beta2-0.117.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-bigquerystorage-v1-1.17.0.jar;%APP_LIB_DIR%\com.google.cloud.google-cloud-bigtable-1.19.2.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-common-protos-2.1.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-bigtable-v2-1.19.2.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-bigtable-admin-v2-1.19.2.jar;%APP_LIB_DIR%\io.opencensus.opencensus-contrib-grpc-util-0.28.0.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-core-3.2.6.jar;%APP_LIB_DIR%\com.google.http-client.google-http-client-protobuf-1.33.0.jar;%APP_LIB_DIR%\com.google.api.grpc.proto-google-cloud-spanner-admin-instance-v1-6.2.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-spanner-admin-instance-v1-6.2.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-spanner-v1-6.2.0.jar;%APP_LIB_DIR%\com.google.api.grpc.grpc-google-cloud-spanner-admin-database-v1-6.2.0.jar;%APP_LIB_DIR%\com.101tec.zkclient-0.10.jar;%APP_LIB_DIR%\org.apache.commons.commons-lang3-3.5.jar"
set "APP_MAIN_CLASS=example.WordCount"
set "SCRIPT_CONF_FILE=%APP_HOME%\conf\application.ini"

rem Bundled JRE has priority over standard environment variables
if defined BUNDLED_JVM (
  set "_JAVACMD=%BUNDLED_JVM%\bin\java.exe"
) else (
  if "%JAVACMD%" neq "" (
    set "_JAVACMD=%JAVACMD%"
  ) else (
    if "%JAVA_HOME%" neq "" (
      if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
    )
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running scio-job.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)

rem if configuration files exist, prepend their contents to the script arguments so it can be processed by this runner
call :parse_config "%SCRIPT_CONF_FILE%" SCRIPT_CONF_ARGS

call :process_args %SCRIPT_CONF_ARGS% %%*

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !SCIO_JOB_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal

exit /B %ERRORLEVEL%


rem Loads a configuration file full of default command line options for this script.
rem First argument is the path to the config file.
rem Second argument is the name of the environment variable to write to.
:parse_config
  set _PARSE_FILE=%~1
  set _PARSE_OUT=
  if exist "%_PARSE_FILE%" (
    FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%_PARSE_FILE%") DO (
      set _PARSE_OUT=!_PARSE_OUT! %%i
    )
  )
  set %2=!_PARSE_OUT!
exit /B 0


:add_java
  set _JAVA_PARAMS=!_JAVA_PARAMS! %*
exit /B 0


:add_app
  set _APP_ARGS=!_APP_ARGS! %*
exit /B 0


rem Processes incoming arguments and places them in appropriate global variables
:process_args
  :param_loop
  call set _PARAM1=%%1
  set "_TEST_PARAM=%~1"

  if ["!_PARAM1!"]==[""] goto param_afterloop


  rem ignore arguments that do not start with '-'
  if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
  set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  shift
  goto param_loop

  :param_java_check
  if "!_TEST_PARAM:~0,2!"=="-J" (
    rem strip -J prefix
    set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
    shift
    goto param_loop
  )

  if "!_TEST_PARAM:~0,2!"=="-D" (
    rem test if this was double-quoted property "-Dprop=42"
    for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
      if not ["%%H"] == [""] (
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      ) else if [%2] neq [] (
        rem it was a normal property: -Dprop=42 or -Drop="42"
        call set _PARAM1=%%1=%%2
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
        shift
      )
    )
  ) else (
    if "!_TEST_PARAM!"=="-main" (
      call set CUSTOM_MAIN_CLASS=%%2
      shift
    ) else (
      set _APP_ARGS=!_APP_ARGS! !_PARAM1!
    )
  )
  shift
  goto param_loop
  :param_afterloop

exit /B 0
