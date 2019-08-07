# self-service-ldap

This stack launches a Fargate service that helps people reset their own Active Directory password.

This has been tested fully against an AWS SimpleAD logic.

Notes: You have to make sure that the username used by SSP has the rights to reset users' passwords.