# SCA / SBOM

```
docker run --rm -v $(pwd):/app maven mvn org.owasp:dependency-check-maven:check -f /app/pom.xml
```

# SAST

scan is a tool primarily for java scanning..., help page:

```
docker run --rm -e "WORKSPACE=${PWD}" -v "$PWD:/app" shiftleft/sast-scan:v2.1.2 scan -h
```

and actual run...

```
docker run --rm -e "WORKSPACE=${PWD}" -v "$PWD:/app" shiftleft/sast-scan:v2.1.2 scan --build
```

or use SonarQube...

