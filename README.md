# Closing the Gap Between Build Evidence and Compliance Enforcement

Demo scripts and slides for our [DevConf.US 2026 presentation](https://pretalx.devconf.info/devconf-us-2026/talk/review/MVVUQTHHN3RT9E89BHJWRKARKSGZBQGJ).

## Speakers

- Simon Baird (Tech Lead, Conforma)
- Cuiping Huo (Quality Engineer, Konflux / Conforma)

## Useful links

Used or mentioned in the demos:
- Conforma project - https://conforma.dev
- Conforma CLI - https://github.com/conforma/cli
- Conforma policy rules - https://conforma.dev/docs/policy/release_policy.html
- Golden container image - https://quay.io/repository/konflux-ci/ec-golden-image
- Policy config presets - https://github.com/conforma/config
- More demos - https://github.com/conforma/demos

## Demos

- **demo1**: Validate structured input (no-cats policy)
- **demo2**: Real image validation + source correlation attack
- **demo3**: Custom policy tuning with ruleData
- **demo4**: Grace periods with effective_on

## Usage

### Using Docker

Build the Docker image:

```bash
docker build -t devconf-conforma-demo .
```

Run a specific demo (1-4):

```bash
docker run -it devconf-conforma-demo 1
docker run -it devconf-conforma-demo 2
docker run -it devconf-conforma-demo 3
docker run -it devconf-conforma-demo 4
```

### Running Locally

Run any demo script from its directory:

```bash
cd demo1
./demo1.sh
```

**Required Tools:**

- **bash** - Shell interpreter
- **jq** - JSON processor
- **yq** - YAML processor
- **bat** - Syntax highlighting for file viewing
- **tree** - Directory structure visualization
- **ec** - Conforma CLI (`brew install conforma/tap/ec`)

## Related talks

- [From Passive Data to Active Defense](https://fosdem.org/2026/schedule/event/UGRZNA-conforma-supply-chain-policy-as-code/) - Stefano Pentassuglia, FOSDEM 2026
- [Enforcing Organization Policies with EC](https://www.youtube.com/watch?v=OmnF_Bm4KOU) - Zoran Regvart, SOSS EU 2024
- [Policy-Driven Supply Chain Security](https://www.youtube.com/watch?v=JgXXAjRuHfo) - Mark Bestavros, DevConf.US 2024
- [How We Use Software Provenance at Red Hat](https://developers.redhat.com/articles/2025/05/15/how-we-use-software-provenance-red-hat) - Ralph Bean
