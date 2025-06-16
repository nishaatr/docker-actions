### get-hz-versions Action

A GitHub Action that extracts Hazelcast OSS and EE version information from Dockerfiles and Maven repositories.

#### Inputs

| Name                | Description                                                                 | Required | Default |
|---------------------|-----------------------------------------------------------------------------|----------|---------|
| working-directory   | Directory containing `hazelcast-oss` and `hazelcast-enterprise` directories | No       | .       |

#### Outputs

| Name                         | Description                                                 |
|------------------------------|-------------------------------------------------------------|
| HZ_VERSION_OSS               | Hazelcast OSS version from `hazelcast-oss/Dockerfile`       |
| LAST_RELEASED_HZ_VERSION_OSS | Latest released Hazelcast OSS version from Maven Central    |
| HZ_VERSION_EE                | Hazelcast EE version from `hazelcast-enterprise/Dockerfile` |

## Usage

Example workflow:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hazelcast/docker-actions/get-hz-versions@master
        id: hz_versions
      - run: echo "OSS Version: ${{ steps.hz_versions.outputs.HZ_VERSION_OSS }}"
```