#
# Redis Dockerfile
#
# https://github.com/dockerfile/redis
#

# Pull base image.
FROM dockerfile/ubuntu

# Add .config with REDIS_PASSWORD
ADD .config /tmp/config

# Install Redis.
RUN \
  cd /tmp && \
  wget http://download.redis.io/redis-stable.tar.gz && \
  tar xvzf redis-stable.tar.gz && \
  cd redis-stable && \
  make && \
  make install && \
  cp -f src/redis-sentinel /usr/local/bin && \
  mkdir -p /etc/redis && \
  cp -f *.conf /etc/redis && \
  rm -rf /tmp/redis-stable* && \
  sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
  sed -i 's/^[# ]*\(logfile\).*$/\1 \/log\/redis.log/' /etc/redis/redis.conf && \
  sed -i 's/^[# ]*\(loglevel\).*$/\1 notice/' /etc/redis/redis.conf && \
  bash -c 'source /tmp/config && sed -i "s/^[# ]*\(requirepass\) .*$/\1 $REDIS_PASSWORD/" /etc/redis/redis.conf'

# Clean config
RUN rm /tmp/config

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# Expose ports.
EXPOSE 6379
