#!/bin/sh
APP_HOME=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -z "$JAVA_HOME" ]; then
  echo "JAVA_HOME is not set. Please install a JDK and set JAVA_HOME."
  exit 1
fi

WRAPPER_JAR="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# GitHub Actions can work without a checked-in wrapper JAR. If it is missing,
# fetch the official Gradle 8.13 wrapper JAR before starting Gradle.
if [ ! -f "$WRAPPER_JAR" ]; then
  mkdir -p "$(dirname "$WRAPPER_JAR")"
  WRAPPER_URL="https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$WRAPPER_URL" -o "$WRAPPER_JAR"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$WRAPPER_URL" -O "$WRAPPER_JAR"
  else
    echo "Neither curl nor wget is available; cannot download Gradle Wrapper JAR."
    exit 1
  fi
fi

if [ ! -s "$WRAPPER_JAR" ]; then
  echo "Failed to obtain gradle-wrapper.jar."
  exit 1
fi

exec "$JAVA_HOME/bin/java" -classpath "$WRAPPER_JAR" org.gradle.wrapper.GradleWrapperMain "$@"
