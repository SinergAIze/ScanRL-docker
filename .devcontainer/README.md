# Dev Container setup - `ScanRL`

This `.devcontainer/` directory contains everything related to setting up a Dev
Container for a specific user. This requires a custom Docker image for each
user, and we build this dynamically using all the files contained and described
herein.

## Walkthrough

### Overview

This Dev Container setup starts from a specifiable Docker Image, and then
customises it to add a user with UID and GID that matches your user credentials
on your Docker host. This ensures that you won't run into permission problems
when editing mounted files inside or outside the dev container.

We achieve this by specifying the custom `scanrl.Dockerfile` that creates
a user with matching credentials on top of a base Docker image
([tensorflow/tensorflow:1.14.0-gpu-py3](https://hub.docker.com/layers/tensorflow/tensorflow/1.14.0-gpu-py3/images/sha256-e72e66b3dcb9c9e8f4e5703965ae1466b23fe8cad59e1c92c6e9fa58f8d81dc8?context=explore)).
To edit the contents of the Docker image, you should only need to specify an
existing image in this `.Dockerfile`'s `FROM <image-name>` line, but you can
also include specific Dockerfile instructions.

### Dev Container Spec

The `.devcontainer.json` specifies how any [Dev Container-compatible editor](https://containers.dev/supporting)
should interact with the Docker container setup described above. In it we:

1. Specify to build a Docker image using the `scanrl.Dockerfile`, if an image
hasn't already been built from it.
2. Pass information regarding your user on the Docker host, such
that the image is built containing a matching user.
3. Bind mount the repo inside the container.
4. Add extra bind mounts usually necessary to autheticate against the git
remote, or to have access to other files from the host inside the container
(such as custom `.bash_aliases`). Feel free to add here any paths you like to
have access to inside the container!
5. Specify how to run/launch the Docker container. Including GPUs is done here!
6. Tailor the container to the current project's development environment via
the `post_create.sh` script, but only on container creation.
7. Specify any project-specific (and _NOT_
[user-specific](#customizations--qol)!) preferences to
customize the Contents of the container (`"features"`) or VS Code
(`"customizations"`).

### Life-cycle scripts used

In order to (1) obtain the docker host user info and (2) run a
custom setup script inside the container we make use of
[Dev Containers' Life-cycle scripts](https://containers.dev/implementors/json_reference/#lifecycle-scripts).

> Note: \
> Make sure both scripts have been `chmod +x`-ed to allow them to be executed!

#### `"initializeCommand"`

We first use the `"initializeCommand"` which executes the `init_env.sh` script
on the Docker host, before anything else. In the `init_env.sh` we dump a
(`.gitignore`d) `.env` file that contains info about the user's `UID`, `GID`,
and `GROUPNAME`, which require commands to be executed, and therefore can't be
referenced via environment variables in the `.devcontainer.json`,
as we do for the `USERNAME` (via `$USER`). While the info from the `.env` is
`COPY`-ed in to the container, the `USERNAME` is passed in as a build argument.
Then, both are used to setup a matching user directly in the container.

#### `"postCreateCommand"`

To configure a project-specific development environment we make use of the
`"postCreateCommand"` life-cycle script, which instead executes the
`post_create.sh` script only after the container is built. In it any specific
installations or setup may be performed!

For `ScanRL`:

1. We update `pip` and `setuptools` packages that come pre-installed in the
`tensorflow/tensorflow:1.14.0-gpu-py3` Docker image.
2. We install all the required Python package dependencies specified in the
`requirements.txt` file (including `numpy`, which is used in the next step).
3. Download and build `pycuda==2017.1.1` from source, since installation via
normal `pip install` breaks. This is fixed by specifying a custom configuration
via that `python ~/pycuda-2017.1.1/configuration.py` call.
4. Install Daryl's custom fork of `gym-unrealcv` in editable mode, promptly
added as a submodule and initialised in this repo.

### Customizations + QoL Improvements

- [\[link\]](https://containers.dev/implementors/features/)
Dev Container Features: Re-usable install scripts.
- [\[link\]](https://code.visualstudio.com/docs/devcontainers/containers#_always-installed-features)
Specifying user-specific VS Code Extensions that are always included in Dev
Containers, regardless of `.devcontainer.json` contents.
