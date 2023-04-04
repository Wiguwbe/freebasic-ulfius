# FreeBASIC + Ulfius

_A test to run ulfius on FreeBASIC_

It uses ulfius with a few modifications to be able to run websockets without the need for
(porting) gnutls to FB, as the porting would require a lot of headers.

(It still uses gnutls internally for hashing and other minor stuff).

It also required a few minimal modifications to fbfrog.

### Base image

- `Dockerfile.base` builds the base docker image;
- `ulfius-install.sh` builds ulfius from the custom source, disabling GNUTLS, CURL and the client tools. It installs to /opt/ulfius to later copy to a new docker stage;
- `fbfrog-install.sh` builds fbfrog from the custom source;
- `fbfrog-runner.sh` runs the fbfrog commands to /opt/ulfius, to later be copied to another stage;
- `*.fbfrog` fbfrog options;

### Test service

- `test.bas` a minimal test that shows the integration with ulfius, with JSON and websockets+JSON;
- `Dockerfile` builds the test image, assumes base image is `basic-ulfius`;

---

There are some current limitations on running FreeBASIC as a Linux daemon, namely not being able to use `pause`
and instead having to use the FB's `sleep` (wait for user input), which requires the container to be run as
interactive (`-ti`).

There is also (apparently) no stderr, or at least not with the conventional numbers and not exposed to the FB's
"api". It's probably possible to use with the standard C libraries.
