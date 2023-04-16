# Multi-Arch Docker - Mesa 3D OpenGL Software Rendering (Gallium) - LLVMpipe, and OpenSWR Drivers

## About

Minimal Docker container bundled with the Mesa 3D Gallium Drivers: [LLVMpipe][mesa-llvm] & [OpenSWR][openswr], enabling OpenGL support inside a Docker container **without the need for a GPU**.

## Features

- Alpine Linux Edge
- LLVMpipe Driver (Mesa 20.0.6)
- OpenSWR Driver (Mesa 20.0.6)
- OSMesa Interface (Mesa 20.0.6)
- softpipe - Reference Gallium software driver
- swrast - Legacy Mesa software rasterizer
- Xvfb - X Virtual Frame Buffer

## Docker Images
Please note there are images available for Alpine versions 3.10, 3.11 as well. Please see all available tags on [DockerHub]

| Image                           | Description         | Architectures             | Base Image  |
| ------------------------------- | ------------------- | ------------------------- | ----------- |
| `boundfoxstudios/opengl:latest` | Latest Mesa version | amd64, 386, arm64, arm/v7 | alpine:edge |

## Building

This image can be built locally using the supplied `Makefile`

Make default image (stable):
```shell
make
```

Make latest image:
```shell
make latest
```

Make all images:
```shell
make all
```

## Usage

This image is intended to be used as a base image to extend from. One good example of this is the [Envisaged][Envisaged] project which allows for quick and easy Gource visualizations from within a Docker container.

Extending from this image.

```Dockerfile
FROM boundfoxstudios/opengl:latest
COPY ./MyAppOpenGLApp /AnywhereMyHeartDesires
RUN apk add --update my-deps...
```

## Environment Variables

The following environment variables are present to modify rendering options.

### High level settings

| Variable                | Default Value  | Description                                                    |
| ----------------------- | -------------- | -------------------------------------------------------------- |
| `XVFB_WHD`              | `1920x1080x24` | Xvfb demensions and bit depth.                                 |
| `DISPLAY`               | `:99`          | X Display number.                                              |
| `LIBGL_ALWAYS_SOFTWARE` | `1`            | Forces Mesa 3D to always use software rendering.               |
| `GALLIUM_DRIVER`        | `llvmpipe`     | Sets OpenGL Driver `llvmpipe`, `swr`, `softpipe`, and `swrast` |

### Lower level settings / tweaks

| Variable         | Default Value | Description                                                                                                                                                              |
| ---------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LP_NO_RAST`     | `false`       | LLVMpipe - If set LLVMpipe will no-op rasterization                                                                                                                      |
| `LP_DEBUG`       | `""`          | LLVMpipe - A comma-separated list of debug options is accepted                                                                                                           |
| `LP_PERF`        | `""`          | LLVMpipe - A comma-separated list of options to selectively no-op various parts of the driver.                                                                           |
| `LP_NUM_THREADS` | `""`          | LLVMpipe - An integer indicating how many threads to use for rendering. Zero (`0`) turns off threading completely. The default value is the number of CPU cores present. |

[openswr]: http://openswr.org/
[mesa-llvm]: https://www.mesa3d.org/llvmpipe.html
[Envisaged]: https://github.com/utensils/Envisaged
[DockerHub]: https://hub.docker.com/repository/docker/utensils/opengl/tags?page=1