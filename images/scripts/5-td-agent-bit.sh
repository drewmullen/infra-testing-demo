#!/bin/bash

set -e

LOCAL_TMP=$(mktemp -d)

# add td-agent-bit repo
cat <<EOF > /etc/yum.repos.d/td-agent-bit.repo
[td-agent-bit]
name = TD Agent Bit
baseurl = https://packages.fluentbit.io/centos/7
gpgcheck=1
enabled=1
EOF

# preconfigure the package signing key
cat <<EOF > ${LOCAL_TMP}/fluentbit.key
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBFXlAtMBCAC7SievUBw7WTm9yWCp+Wfo28w7A7ERVJpZp3sTw5Wn+gISHA+1
iCkfG0UDDo0smWQb+zZ6spd2OV2zg/TTgSjZb0JJiCeIrzFtWctkm8zS7X7g3t+0
a92IYYL/yA9x2RP7DaszqqT90GIoMZ18Iu1qwe651rOhAtNCrcmw5lsa+rrHDUVH
tIH2EH/71akkxnlLB9jFknQ+8nDAkX2btByG0KYr+i7a2FmSFo+CKYZewauanriU
cPTQHHFmapKyEDLbE1DlTku+9IqhxakwTyUn9bCnhUMWEzqmpfZWS/FzcclBIsWC
SFZv4LLNbYMaIX2jwGI7umUuQ4GttDZS/6+fABEBAAG0KUVkdWFyZG8gU2lsdmEg
PGVkdWFyZG9AdHJlYXN1cmUtZGF0YS5jb20+iQE3BBMBCAAhAhsDAh4BAheABQJX
fIHPBQsJCAcDBRUKCQgLBRYCAwEAAAoJEE/4NotuoHIqeAwIAIAsyO6sV/W4xUro
XzYntfEvjcgVrR1DnZMLN/zkGbgv1AfoRLfOW/9pBDpIJAiifzYBr265zoKf7Wny
D99KN7N9NTf1lgzoDFgWdCltvUzKNj0D8xN1cTvUq0tGxpEFBCtbjg3swW68etJx
wkFhPXewcgbVk2PYz3AK7PDcR1A3HRZc/hI1GqfxoxYLT6qmXEE9/0ZI7cIvoYjp
S66QXnpSHDZ7thROEbQCwIvZh0usVaSa7HGzW6YLwq7Mtk36eRYXMOkl3tRlu3Me
KuD0vWrvHIBVU1C5GLSvK+K2O0dx9MgiwbuVegWCZUe56JsTH7THCozvKgcVF3yK
Wc6gKlO5AQ0EVeUC0wEIAKyJwOGZOTmh45i29c5gxvFB95lu4ajTa9X1zmaM7Xe3
2VhrLyaIp9noWE8xjv2i97wV9LrzrmUSxzhqSE8MG+qPxy6/PCdxe3kLB+PCvutO
4EnLy3MnglK6YPSZrxV69nbnO+Ts0dhYWFUqsdE7jwrr6DgED49MUUbzj4y+MPQt
ljEr69p4pja4VilgqMDWurnQ8M0tnALJHL4kvcWbSwWSAahhYT7HNvtyiXt3U/Na
Dbaw86L8ENTxXkS5YgiQbm8PLVrfoNzw/z37QVYf4izNpVaqek82TBp0A3FVfVd3
V7dObzvLDlEEX4kjEbhZYRAK2k74oazE3343ibPwIPUAEQEAAYkBHwQYAQIACQUC
VeUC0wIbDAAKCRBP+DaLbqByKm0GCACqMPKFdEdEQnmEJ1cTtwx4ax3HUML3frJW
/Kz4DytGpAD6yq7lLT5BRK2X6QNla+jezDSNfsOw9uPMDhV0iXw/hGpt3kr5wp4J
UT1LKfkd/0WHgygvLZUobmqkvpqTIKrp5yjAv6WGQpJyTZDcL0D5TsgLr6NC0taJ
I41ckHWc9Nd3kTS6oVNLngEVDaQ2AezYpHgXgww6XEb60wGvnj/3P0Cx1gvo+V0c
JIs2r6TYHNdrZKfY6ynxS08Is+axvSdUxoUL27CQ+/ljhkGD2qNyieY9feYRGx+A
POR1LlqgIS3UH36y9XojJsBF9Qki/3+GG2u//pBiVNSwb6hRtcPF
=RrLa
-----END PGP PUBLIC KEY BLOCK-----
EOF

rpm --import ${LOCAL_TMP}/fluentbit.key

# clean up
rm -rf ${LOCAL_TMP}

# install and disable, since it should only be enabled in user data
yum install -y td-agent-bit
systemctl disable td-agent-bit

# blank out default configuration since it will be replaced with
# user data script
echo "" > /etc/td-agent-bit/td-agent-bit.conf
