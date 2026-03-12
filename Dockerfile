FROM gitlab/gitlab-ce:18.2.8-ce.0
LABEL maintainer="Jubilee Tan"

COPY assets/gitlab.rb /assets/gitlab.rb
# as gitlab-ci checks out with mode 666 we need to set permissions of the files we copied into the
# container to a secure value. Issue #5956
RUN chmod -R og-w /assets/gitlab.rb
