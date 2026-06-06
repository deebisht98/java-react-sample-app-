# Use official PostgreSQL image
FROM postgres:16-alpine

# Set environment variables
ENV POSTGRES_DB=myapp_db
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres_password

# Create a non-root user for security (optional but recommended)
# Uncomment the lines below if you want to run PostgreSQL as a non-root user
# RUN addgroup -S postgres && adduser -S postgres -G postgres

# Create a volume for persistent data storage
VOLUME ["/var/lib/postgresql/data"]

# Expose PostgreSQL default port
EXPOSE 5432

# Add health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Optional: Copy initialization SQL scripts
# COPY init.sql /docker-entrypoint-initdb.d/

# The entrypoint and cmd are already defined in the base image
# CMD ["postgres"]
