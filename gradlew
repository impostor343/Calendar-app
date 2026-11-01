#!/bin/sh
# Gradle start up script for POSIX generated for CollegeCompanion
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'
APP_HOME=$( cd "${0%/*}" && pwd -P ) || exit
CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar
# The source archive may omit the binary wrapper JAR. Fall back to a locally
# installed Gradle so this script remains useful until the official wrapper
# JAR is generated with: gradle wrapper --gradle-version 8.9.
if [ ! -f "$CLASSPATH" ]; then
    if command -v gradle >/dev/null 2>&1; then
        exec gradle "$@"
    fi
    echo "Gradle wrapper JAR is missing. Install Gradle 8.9 and run: gradle wrapper --gradle-version 8.9" >&2
    exit 1
fi
if [ -n "$JAVA_HOME" ] ; then
    JAVACMD="$JAVA_HOME/bin/java"
else
    JAVACMD="java"
fi
exec "$JAVACMD" $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS "-Dorg.gradle.appname=$0" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
