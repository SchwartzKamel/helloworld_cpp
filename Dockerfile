### Builder image ###
# Using Ubuntu 24.04
FROM ubuntu:24.04 AS builder-image

# Avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    ninja-build \
    clang \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*/*

# Copy over build files and change to workdir
COPY /app /home/app
WORKDIR /home/app

# Compile into ninja, then build the application
RUN chmod 755 build.sh && ./build.sh && ninja

### Runner image ###
# Using Ubuntu 24.04
FROM ubuntu:24.04 AS runner-image

# Run the software
CMD [ "./HelloWorld" ]

# Add labels
LABEL maintainer="tom@sierrahackingcompany.com"

ARG build_number
ARG build_timestamp
ARG build_url
ARG git_branch_name
ARG git_sha1

LABEL sierrahackingcompany.build.number="${build_number}" \
    sierrahackingcompany.build.timestamp="${build_timestamp}" \
    sierrahackingcompany.build.url="${build_url}" \
    sierrahackingcompany.discover.dockerfile="/Dockerfile" \
    sierrahackingcompany.discover.packages="apk info -v | sort" \
    sierrahackingcompany.git.branch-name="${git_branch_name}" \
    sierrahackingcompany.git.url="https://github.com/SchwartzKamel/helloworld_cpp" \
    sierrahackingcompany.git.sha-1="${git_sha1}" \
    sierrahackingcompany.project.name="helloworld_cpp" \
    sierrahackingcompany.project.url="https://github.com/SchwartzKamel/helloworld_cpp" \
    sierrahackingcompany.version="${git_branch_name}-${build_timestamp}"

# Update runner image
RUN apt-get update && apt-get install --no-install-recommends -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user and copy compiled software
# Define workdir and make file executable
RUN useradd --create-home iron-chef
COPY --from=builder-image /home/app/HelloWorld /home/iron-chef/HelloWorld
WORKDIR /home/iron-chef/
RUN chmod 755 ./HelloWorld

USER iron-chef