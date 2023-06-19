ARG BUILD_FROM
FROM $BUILD_FROM
#FROM wordpress:latest

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]