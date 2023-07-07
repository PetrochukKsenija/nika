FROM ubuntu:22.04 as base
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
# install dependencies
COPY ./scripts/install_deps_ubuntu.sh /tmp/install_deps_ubuntu.sh
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo ccache tzdata git && \ 
    /tmp/install_deps_ubuntu.sh

FROM base as devcontainer
ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
ENV CCACHE_DIR=/ccache

WORKDIR /nika
COPY ./scripts/install_deps_ubuntu.sh ./scripts/set_vars.sh /nika/scripts/
COPY ./problem-solver/sc-machine/scripts/install_deps_ubuntu.sh /nika/problem-solver/sc-machine/scripts/
RUN cd /nika/scripts && ./install_deps_ubuntu.sh --dev

FROM devcontainer as builder
ENV CCACHE_DIR=/ccache
WORKDIR /nika
COPY . .
RUN --mount=type=cache,target=/ccache/ cd /nika/scripts && ./build_problem_solver.sh

FROM base as final
COPY --from=builder /nika/problem-solver/sc-machine/scripts /nika/problem-solver/sc-machine/scripts
COPY --from=builder /nika/problem-solver/sc-machine/requirements.txt /nika/problem-solver/sc-machine/requirements.txt
RUN /nika/problem-solver/sc-machine/scripts/install_deps_ubuntu.sh && apt-get install -y --no-install-recommends tini

COPY --from=builder /nika/bin /nika/bin
COPY --from=builder /nika/scripts /nika/scripts
COPY --from=builder /nika/nika.ini /nika/nika.ini

WORKDIR /nika/scripts
ENTRYPOINT ["tini", "--", "/nika/scripts/docker_entrypoint.sh"]
