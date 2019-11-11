FROM ubuntu:18.04

# This dockerfile follows the setup in
# https://github.com/apache/trafficserver/blob/master/tests/bootstrap.py

# Install packages to build trafficserver
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
 && sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:hnakamur/openresty-luajit \
 && add-apt-repository ppa:hnakamur/yaml-cpp \
 && add-apt-repository ppa:hnakamur/trafficserver \
 && apt-get update \
 && apt-get install -y trafficserver \
 && apt-get install -y git build-essential \
 && apt-get install -y python3 python3-virtualenv virtualenv python3-dev curl netcat net-tools \
 && useradd -r -m -s /bin/bash build

USER build

# Get the source and configure trafficserver
RUN mkdir -p ~/dev \
 && cd ~/dev \
 && git clone -b 8.0.5 --depth 1 https://github.com/apache/trafficserver

# Set up test environment
RUN cd ~/dev/trafficserver/tests \
 && virtualenv --python=python3 env-test \
 && env-test/bin/pip install pip --upgrade \
 && env-test/bin/pip install autest==1.7.2 hyper requests dnslib httpbin traffic-replay

# Run trafficserver tests
COPY run-trafficserver-tests.sh /usr/local/bin/
RUN /usr/local/bin/run-trafficserver-tests.sh || :

## Run negative cache tests
#COPY --chown=build:build tests/gold_tests/negative_cache/ /tmp/negative_cache/
#RUN mv /tmp/negative_cache ~/dev/trafficserver/tests/gold_tests/
#RUN . ~/dev/trafficserver/tests/env-test/bin/activate \
# && cd ~/dev/trafficserver/tests/gold_tests/negative_cache \
# && ./generate_and_run_negative_cache_tests.py | tee ~/logs/negative_cache_tests-$(date +%Y%m%d-%H%M%S.log)

ENTRYPOINT ["/bin/bash"]
