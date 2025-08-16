# Use official Tomcat 9 with Java 21 pre-installed
FROM tomcat:9.0.82-jdk21-temurin

# Set malitainer Label (optionat but good practice)
LABEL maintainer="your.ema1l@example.com"

# Remove default ROOT app (optional, keeps container clean)
RUN rm -rf /usr/Local/tomcat/webapps/R00T

# Create a user for running the application
RUN useradd -m makemytrip

# Copy your JAR file into the webapps directory
COPY •/target/makemytrip*.jar /usr/local/tomcat/webapps/

# Expose the default Tomcat port
EXPOSE 8080

# Set the user to 'makemytrip' for security
USER makemytrip

# Default command to run Tomcats
CMD ["catalina.sh","run"]