## CHORE/DEPLOY-DOCS-TO-LINODE

1) CREATE INSTANCE:

terraform init && terraform plan
terraform apply

2) BUILD THE DOCS:

docker image build -t docker.pkg.github.com/gilacost/tapi/docs:0.0.1 -f tapi_docs.tf .

3) TEST DOCS LOCALLY:

docker run -p 80:80 docker.pkg.github.com/gilacost/tapi/docs:0.0.1

4) PUSH THE IMAGE:

docker push docker.pkg.github.com/gilacost/tapi/docs:0.0.1

5) PULL AND RUN:

## ALGORITHM IN CONFIG

docker --host ssh://root@178.79.184.119 --log-level debug pull docker.pkg.github.com/gilacost/tapi/docs:0.0.1
docker --host ssh://root@178.79.184.119 --log-level debug run -d -p 80:80 docker.pkg.github.com/gilacost/tapi/docs:0.0.1

1) EXTRACT ALGORITHM TO CONFIG:

2) CREATE EXSSS FOLDER:

3) MOVE TRANSACTION AND ACCOUNTS TESTS THERE:

4) TRANSACTION INDEX CHANGES, NEEDS TO BE UPDATED:

account.transactions |> Enum.take(10) |> IO.inspect(label: "first ")

5) NEW EXSSS ALGORITHM TESTS NEED TO BE SYNC

6) ADD CRON TO CHECK ENOUGH ENTROPY
