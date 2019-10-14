FROM python:3.7-alpine

LABEL "com.github.actions.name"="aws-helper"
LABEL "com.github.actions.description"="github actions aws helper"
LABEL "com.github.actions.icon"="check-square"
LABEL "com.github.actions.color"="blue"

RUN apk add --no-cache bash
RUN apk add --no-cache jq
RUN pip3 install awscli
RUN pip3 install boto3

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]