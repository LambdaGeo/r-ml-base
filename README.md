# r-ml-base

Base Docker image for R services using [Plumber](https://www.rplumber.io/), with "heavy" Machine Learning libraries pre-compiled and pre-installed.

## Why this image exists

Packages like `caret`, `randomForest` and `kernlab` have system-level dependencies (C/C++/Fortran compilation) that make `install.packages()` quite slow — every `docker build` of an application that uses them directly can take several minutes just on that step.

This image solves that by doing the heavy lifting once: it starts from `rstudio/plumber:latest`, installs the required system dependencies, and pre-installs the most expensive R packages. Services that need these packages can then use `r-ml-base` as their base image (`FROM`) and skip the compilation step, making the final application's build much faster.

> This image **does not** contain application code — it should only be used as a base for other `Dockerfile`s.

## What's included

**System dependencies** (via `apt-get`):
- `build-essential`
- `libcurl4-openssl-dev`
- `libssl-dev`
- `libgit2-dev`
- `libxml2-dev`
- `libcairo2-dev`
- `libxt-dev`
- `libfontconfig1-dev`
- `libpng-dev`

**R packages** (via `install_packages_base.R`):
- `kernlab`
- `caret`
- `fastshap`
- `dplyr`
- `ggfittext`
- `gggenes`
- `shapviz`
- `randomForest`

The CRAN repository used is configurable via the `CRAN_REPO` environment variable (default: `https://cloud.r-project.org`).

## Usage

### 1. Build the base image

```bash
docker build -f Dockerfile.base -t lambdageo/r-ml-base:latest .
```

Optionally, publish it to a registry (Docker Hub, GHCR, etc.) to reuse it across projects:

```bash
docker push lambdageo/r-ml-base:latest
```

### 2. Using it as a base for another service

In your R/Plumber service's `Dockerfile`:

```dockerfile
FROM lambdageo/r-ml-base:latest

WORKDIR /app
COPY . .

# Install only the packages specific to your application here
RUN Rscript -e "install.packages(c('your-specific-package'))"

EXPOSE 8000
ENTRYPOINT ["Rscript", "plumber.R"]
```

This way, the final service's build doesn't need to recompile `caret`, `randomForest` and the other heavy packages — they're already available in the base image.

## Adding new packages to the base

Edit `install_packages_base.R` and add the new package to the `packages` vector. Then rebuild and republish the base image so projects depending on it get access to the package.

```r
packages <- c(
  "kernlab",
  "caret",
  "fastshap",
  "dplyr",
  "ggfittext",
  "gggenes",
  "shapviz",
  "randomForest"
  # add other generic packages you always use here
)
```

## Repository structure

```
.
├── Dockerfile.base           # Base image definition
└── install_packages_base.R   # R package installation script
```
