FROM amazon/aws-cli:latest

LABEL "com.github.actions.name"="aws-ecr-eks-action"
LABEL "com.github.actions.description"="logs into aws, build and pushes to ecr, allows to run kubectl"
LABEL "com.github.actions.repository"="https://github.com/NitMedia/aws-ecr-eks-action"
LABEL "com.github.actions.maintainer"="Nithin Meppurathu <nithin@nitmedia.com>"
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="red"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]