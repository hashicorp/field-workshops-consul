# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This dockerfile isn't managed via CI because we don't have a system currently setup in this
# repo. I(asumner) built and pushed it to our GCP project manually, and pointed our config.yml
# file to use it. Currently I've named it: gcr.io/instruqt-hashicorp/asumner-test-consul-cloud-client-no-license
#
# If anyone has any questions, it'll lead them to me.
# I'm packaging this with the track for right now to keep things self contained and _obvious_
#
# Without baking in the gcloud auth plugin install step, our setup track times out consistently
# and takes longer than 30 minutes
#
# We also currently rely on the base image here to copy the envoy binary into our packer builds.
# I'm just overwriting that process with a new version. This is not a great way to install
# software, the obvious being cross platform issues...
# It can't be installed via apt because we'd need to upgrade Ubuntu which is a whole other can of worms
FROM gcr.io/instruqt-hashicorp/consul-cloud-client-no-license:v1.10.2

RUN wget -O envoy https://github.com/envoyproxy/envoy/releases/download/v1.23.8/envoy-1.23.8-linux-x86_64
RUN chmod +x envoy
RUN mv envoy /usr/local/bin/envoy

RUN apt update -y
RUN apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
RUN apt-get --only-upgrade -y install google-cloud-sdk kubectl
