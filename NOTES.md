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

---

# Dockle

```
docker run --rm goodwithtech/dockle:latest docker.io/docker-hub-username/image-to-be-analyzed
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock goodwithtech/dockle:latest mikejonesey/dso-demo
```

