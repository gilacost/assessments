#!/bin/sh

curl http://localhost:4001/accounts \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR/transactions \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR/transactions \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="

curl http://localhost:4001/accounts/test_acc_1JBMeXJR/transactions \
  -H "Authorization: Basic dGVzdF9BUUJmS3RfOFdPQkdqQnd6bmJseTo="
