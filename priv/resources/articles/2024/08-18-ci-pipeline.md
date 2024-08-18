%{
  slug: "elixir-ci-testing-publishing-and-containerization-with-github-actions",
  title: "Elixir CI: Testing, Publishing, and Containerization with GitHub Actions",
  description: "This article is about setting up a CI pipeline for an Elixir application using GitHub Actions. We'll cover installing dependencies, running tests, and checking code formatting, as well as publishing hex packages and building Docker images as part of the pipeline.",
  published: true,
  tags: ["CI", "Elixir", "GitHub Actions"]
}
---
This article is about setting up a CI pipeline for an Elixir application using GitHub Actions. We'll cover installing dependencies, running tests, and checking code formatting, as well as publishing hex packages and building Docker images as part of the pipeline.

## Introduction

Continuous Integration (CI) is a software development practice in which developers frequently integrate code changes into a shared repository. This allows problems to be identified and fixed early in the development process. Even if you are not working on a large project, setting up a basic CI pipeline that performs a few simple checks will ensure that your codebase is in good shape. In this article, we will explore how to set up a CI pipeline for an Elixir application using GitHub Actions.

## The Workflow

The following steps explain how to set up a basic CI pipeline for an Elixir application using GitHub Actions. This serves as a starting point for automating the testing process and can be expanded to include additional checks and tasks. We assume that you already have an Elixir project set up and are familiar with Git and GitHub.

### Setting Up GitHub Actions

First, we need to create a `.github/workflows` directory in the root of our project. Inside this directory, we will create a YAML file that defines the CI pipeline. The file can have any name, but for this example, we will name it `ci.yml`.

```yaml
name: CI

on:
  push:

jobs:
  test:
    name: Test app
    runs-on: ubuntu-latest
    env:
      MIX_ENV: test
```

We start by defining the name of the workflow and the event that triggers it. In this case, the workflow will run whenever a push event occurs because we specified `on: push`. We then define a job named `test` that will run on the latest version of Ubuntu. We also set the `MIX_ENV` environment variable to `test` to ensure that the tests are run in the test environment.

This workflow will serve as the basis for our CI pipeline. We will add more steps as we go along.

### Preparing the Elixir Environment

We need to set up the Elixir environment before we can run tests. This includes installing Elixir and Erlang. We can use the `erlef/setup-beam` action to set up the BEAM environment.

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: erlef/setup-beam@v1
    id: beam
    with:
      version-file: .tool-versions
      version-type: strict
```

First, we check out the code using the [`actions/checkout` action](https://github.com/actions/checkout). This action clones the repository into the runner, allowing us to access the codebase. Then we use the [`erlef/setup-beam` action](https://github.com/erlef/setup-beam) to set up the BEAM environment. The action needs to know the version of Elixir and Erlang to install. We could specify the versions directly in the action, but since we use `asdf` to manage our Elixir and Erlang versions, we already have a `.tool-versions` file in our project that specifies the versions. We can pass this file to the action under the `version-file` key. This allows us to keep the versions in sync with our local development environment and we don't have to update the workflow file every time we change the versions.

The `.tool-versions` file looks like this:

```
elixir 1.17.1
erlang 27.0
```

### Optimizing Build Times with Caching

To speed up the build process, we can cache the dependencies and build artifacts. These files will be generated in the next steps, but we need to put the caching step in front of them to ensure that the cache is restored before the dependencies are installed and the code is compiled. With the caching in place, we don't have to reinstall the dependencies and recompile the code every time the workflow runs. We can use the `actions/cache` action to add caching to our workflow.

```yaml
steps:
  - name: Restore the deps and _build cache
    uses: actions/cache@v4
    id: restore-cache
    env:
      OTP_VERSION: ${{ steps.beam.outputs.otp-version }}
      ELIXIR_VERSION: ${{ steps.beam.outputs.elixir-version }}
      MIX_LOCK_HASH: ${{ hashFiles('**/mix.lock') }}
    with:
      path: |
        deps
        _build
      key: ${{ runner.os }}-${{ env.ELIXIR_VERSION }}-${{ env.OTP_VERSION }}-${{ env.MIX_ENV }}-mixlockhash-${{ env.MIX_LOCK_HASH }}
```

We cache the `deps` and `_build` directories. We define some environment variables that we use to construct the cache key. The cache key is important because it determines when the cache will be restored. The cache key in the above example is based on the operating system, Elixir and Erlang versions, the `MIX_ENV` environment variable, and the hash of the `mix.lock` file. This ensures that the cache is only restored if the versions and dependencies have not changed.

 We can access the Elixir and OTP versions from the previous step using the expressions `${{ steps.beam.outputs.otp-version }}` and `${{ steps.beam.outputs.elixir-version }}` (where `beam` is the action step ID). The hash is calculated using the `hashFiles` function.

### Installing and Compiling Dependencies

We are now ready to install the dependencies and compile the code.

```yaml
steps:
  - name: Install mix dependencies
    if: steps.restore-cache.outputs.cache-hit != 'true'
    run: mix deps.get

  - name: Compile dependencies
    if: steps.restore-cache.outputs.cache-hit != 'true'
    run: mix deps.compile

  - name: Compile
    run: mix compile --warnings-as-errors --force
```

We define three steps to install the mix dependencies, compile the dependencies and compile the code. We use an `if` condition in the first two steps to check if the cache has been restored. If the cache has not been restored, we install the mix dependencies and compile the dependencies. The step of compiling our codebase has to be done every time because the code may have changed. We use the `--warnings-as-errors` flag to treat warnings as errors as we don't want to allow warnings in our codebase.

### Running Checks and Tests

The elixir environment is set up, the dependencies are installed, and the code is compiled. Now we can run our checks and tests. This is the most important part of the CI pipeline because it ensures that the code behaves as expected.

```yaml
steps:
  - name: Check Formatting
    run: mix format --check-formatted

  - name: Check unused deps
    run: mix deps.unlock --check-unused

  - name: Credo
    run: mix credo

  - name: Run Tests
    run: mix test
```

We define four steps to check code formatting, unused dependencies, run Credo and test the application. This is pretty basic, but it's a good place to start. You can add additional checks and tasks here, such as running dialyzer or checking code coverage.

### Full Pipeline

In the previous sections, we built a basic CI pipeline that installs dependencies, compiles code and runs checks and tests. It also includes caching to speed up the workflow. Here is the complete pipeline, which you can copy and paste as a starting point for your Elixir project.

```yaml
name: CI

on:
  push:

jobs:
  test:
    name: Test app
    runs-on: ubuntu-latest
    env:
      MIX_ENV: test

    steps:
      - uses: actions/checkout@v4

      - uses: erlef/setup-beam@v1
        id: beam
        with:
          version-file: .tool-versions
          version-type: strict

      - name: Restore the deps and _build cache
        uses: actions/cache@v4
        id: restore-cache
        env:
          OTP_VERSION: ${{ steps.beam.outputs.otp-version }}
          ELIXIR_VERSION: ${{ steps.beam.outputs.elixir-version }}
          MIX_LOCK_HASH: ${{ hashFiles('**/mix.lock') }}
        with:
          path: |
            deps
            _build
          key: ${{ runner.os }}-${{ env.ELIXIR_VERSION }}-${{ env.OTP_VERSION }}-${{ env.MIX_ENV }}-mixlockhash-${{ env.MIX_LOCK_HASH }}

      - name: Install mix dependencies
        if: steps.restore-cache.outputs.cache-hit != 'true'
        run: mix deps.get

      - name: Compile dependencies
        if: steps.restore-cache.outputs.cache-hit != 'true'
        run: mix deps.compile

      - name: Compile
        run: mix compile --warnings-as-errors --force

      - name: Check Formatting
        run: mix format --check-formatted

      - name: Check unused deps
        run: mix deps.unlock --check-unused

      - name: Credo
        run: mix credo

      - name: Run Tests
        run: mix test
```

## Bonus: Publishing Hex Packages

When you develop a library, you may want to publish it to the Hex package manager. We can automate the publishing process by adding a step to the CI pipeline that publishes the package to Hex.

**Add Workflow Trigger**

You probably don't want to publish a new version of your package every time you push a commit. We can add a trigger that will also run the workflow when a new release is created. We can use the `release` event for this with the `types` parameter set to `[published]`.

```yaml
on:
  push:
  release:
    types: [published]
```

We will check for the workflow trigger event later on to determine if the package should be published.

**Add Hex Secret**

To publish a package to Hex, we need to authenticate to the Hex package manager in our workflow. We create a secret in the GitHub repository that contains an Hex authorization key. The secret can be accessed in the workflow file and used to authenticate to Hex.

You can can create a Hex authorization key by running the [`mix hex.user key generate` command](https://hexdocs.pm/hex/Mix.Tasks.Hex.User.html#module-generate-user-key) or by visiting the [Hex Keys Settings page](https://hex.pm/dashboard/keys). Your key should have write access to the package you want to release.

Add the generated key to your GitHub repository as a repository secret. See [Managing development environment secrets for your repository or organization](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-development-environment-secrets-for-your-repository-or-organization) for more information.

**Add Publishing Job**

We can now add a step to the workflow that publishes the package to Hex. We use the `mix hex.publish` command to publish the package. We need to set the `HEX_API_KEY` environment variable to the secret we created earlier. Change the name of the environment variable accordingly if you used a different name for the secret.

```yaml
steps:
  - name: Publish package
    if: github.event_name == 'release'
    env:
      HEX_API_KEY: ${{ secrets.HEX_API_KEY }}
    run: mix hex.publish --yes
```

As you can see, we use an `if` condition to check whether the workflow was triggered by a GitHub release event. If it was, we publish the package to Hex. We set the `HEX_API_KEY` environment variable to the secret we created earlier. The `--yes` flag is used to automatically confirm the release.

You may want to create a new job in your pipeline to publish your hex package to separate testing and publishing, but note that you must set up the BEAM environment and install the dependencies before you can publish the package.

## Bonus: Building and Publishing Docker Images

If you deploy your Elixir application as a Docker container, you can automate the process of building and publishing Docker images as part of your CI pipeline. In the following sections we will create a pipeline job that builds a Docker image and publishes it to the GitHub Container Registry (GHCR).

**Add a new job for building and publishing Docker images**

We add a new job to our pipeline that builds and publishes our Docker image. We also add two environment variables to the job that specify the name of the image and the registry where the image will be pushed. We customize the permissions for the job, setting the `contents` permission to `read` and the `packages` permission to `write`. This will allow the job to read the contents of the repository and write packages to the GitHub container registry. We also add a step to the job that checks out the repository.

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    name: Build and push Docker image
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4
```

**Log in to the Container Registry**

Before we can push the Docker image to the GitHub Container Registry, we need to log in to the registry. We use the [`docker/login-action` action](https://github.com/docker/login-action) to authenticate to the registry. We set the `registry` parameter to the URL of the registry, the `username` parameter to the GitHub actor, and the `password` parameter to the GitHub token. We defined the `REGISTRY` environment variable earlier. The GitHub token and GitHub actor variables are automatically provided by GitHub Actions.

```yaml
steps:
  - name: Log in to the container registry
    uses: docker/login-action@v3
    with:
      registry: ${{ env.REGISTRY }}
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}
```

We are now authenticated to the GitHub Container Registry.

**Set up Docker Buildx**

Next, we set up Docker Buildx with the [`docker/setup-buildx-action` action](https://github.com/docker/setup-buildx-action). We need Docker Buildx to cache the build layers and speed up the build process. We don't need to specify any parameters for the action.

```yaml
steps:
  - name: Set up Docker Buildx
    uses: docker/setup-buildx-action@v3
```

**Lowercase the image name**

If the repository name contains uppercase letters, we need to lowercase the image name as Docker does not allow uppercase in the image name.

```yaml
steps:
  - name: Lowercase image name
    run: echo "IMAGE_NAME=$(echo "$IMAGE_NAME" | awk '{print tolower($0)}')" >> $GITHUB_ENV
```

This step uses the `awk` command to lowercase the image name and sets the `IMAGE_NAME` environment variable to the lowercase version of the image name.

**Prepare Metadata for Docker**

When we push the image to the GitHub container registry, we want to provide metadata such as tags and labels. We can use the [`docker/metadata-action` action](https://github.com/docker/metadata-action) to automatically extract metadata based on Git reference and GitHub events. We will use the output of this action in the next pipeline step when building and pushing the Docker image.
 
```yaml
steps:
  - name: Extract metadata (tags, labels) for Docker
    id: meta
    uses: docker/metadata-action@v5
    with:
      images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
```

**Build and Push**

We are now ready to build and push the Docker image. We use the [`docker/build-push-action` action](https://github.com/docker/build-push-action) to build and push the image. We set `push` to `true` to not only build the image but also push it to the registry. We set the `tags` and `labels` parameters to the output of the previous step to add appropriate labels and tags to the image. We also set the `cache-from` and `cache-to` parameters to cache the build layers. This will speed up the build process.

```yaml
steps:
  - name: Build and push
    uses: docker/build-push-action@v6
    with:
      push: true
      tags: ${{ steps.meta.outputs.tags }}
      labels: ${{ steps.meta.outputs.labels }}
      cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
      cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
```

We have successfully built and pushed the Docker image to the GitHub Container Registry.

**The Full Pipeline**

```yaml
name: CI

on:
  push:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    name: Build and push Docker image
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Lowercase image name
        run: echo "IMAGE_NAME=$(echo "$IMAGE_NAME" | awk '{print tolower($0)}')" >> $GITHUB_ENV

      - name: Log in to the container registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache
          cache-to: type=registry,ref=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
```

## Conclusion

In this article, we explored how to set up a CI pipeline for an Elixir application using GitHub Actions. We covered how to install dependencies, run tests and perform certain code checks, as well as how to publish hex packages and build Docker images as part of the pipeline. This serves as a starting point for automating the testing process and can be expanded to include additional checks and tasks.
