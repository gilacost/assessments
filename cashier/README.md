# Cashier  🛒

Main module `Cashier`.

This is a minimal elixir application that implements a shopping kart.

[![Coverage Status](https://coveralls.io/repos/github/gilacost/cashier/badge.svg?branch=master&t=3Anqcg)](https://coveralls.io/github/gilacost/cashier?branch=master)&nbsp;&nbsp;![Deploy status](https://github.com/gilacost/cashier/workflows/Push%20to%20ECR%20and%20Deploy%20to%20ECS/badge.svg)&nbsp;&nbsp;![Elixir CI status](https://github.com/gilacost/cashier/workflows/Elixir%20CI/badge.svg)

## Installation &nbsp;🚀

So that the teams local environments can be as similar as possible and all of
the same versions of each package are used, I have used [asdf](https://github.com/asdf-vm/asdf).
If you don't have it already installed you can just run `make asdf` and `make install`.

By doing this you will be running:

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.2

asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git
```

And then &nbsp;☕️

```
asdf install
```

These bash commands have been redirected to `/dev/null`, so don't worry if you have
previously installed any of the packages.

If you don't have asdf in your dot-files, add it like this:

```bash
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
```

If you use zsh, you  should add it to your `.zshrc` file.


## Hooks &nbsp;⚓️

To ensure a fast and secure development and to avoid mistakes, using hooks is
encouraged. If you want to do so, you can install them by running `make hooks`.
This will install [pre-commit](https://pre-commit.com/), which is a python
package; so you will need to have python already installed.

## Documentation &nbsp;🗃

[Ex doc](https://github.com/elixir-lang/ex_doc) has been added as a depenency in
order to generate documentation for the codebase. If you fancy reviewing the
different modules and their function run `make docs`.

## Continuous Integration &nbsp;🔁

[Elixir CI](https://github.com/actions/setup-elixir) github action has been
set up. It runs the following tasks.

```
- name: Check Formatting
  run: mix format --check-formatted

- name: Run Tests
  run: mix test

- name: Check Typespec
  run: mix dialyzer --halt-exit-status

- name: Run Coveralls
  run: mix coveralls.github
```

Here is the action [yaml](https://github.com/gilacost/cashier/tree/master/.github/workflows/elixir.yml).

* Code coverage has also been set up with [coveralls](https://coveralls.io/github/gilacost/cashier).

## ECR pipeline &nbsp;🏎

This pipeline builds a multi stage docker image. The builder stage inherits from
`elixir:1.9.4` which is the latest version on `2020-01`. This stage generates
the docs. Then this docs are copied into an apache2 container into the default
virtual host folder.

```
  # Builder stage
  FROM elixir:1.9.4 as builder

  RUN mix local.hex --force \\
   && mix local.rebar --force

  RUN mkdir -p /cashier
  WORKDIR /cashier

  COPY . .

  RUN mix deps.get && \\
      mix deps.compile && \\
      mix docs

  # Default stage
  FROM httpd:2.4
  COPY --from=builder /cashier/doc /usr/local/apache2/htdocs/

  CMD [ "httpd-foreground" ]
```

if you want to run the image locally, you need to build it first:

```
  docker build . -t cashier-docs
  docker run -p 8080:80 cashier-docs
```

One the github actio has built the image then it is pushed to a private aws
docker registy. You can check the steps [ecr](https://github.com/gilacost/cashier/tree/master/.github/workflows/ecr.yml).

## Terraform (CD, ECR, ECS) 🏗

The registry has been built with terraform. After speaking with Dan I
immediatelly wanted to do something with ECS. &nbsp; So, after all cashier
requirements were satisfied, I Jumped onto terraform and AWS 🤙.

Al resources had been declared [here](https://github.com/gilacost/cashier/tree/master/.github/workflows/terraform/main.terraform).

There is already a working `cahier-docs` &nbsp;[here](http://ec2-35-180-251-200.eu-west-3.compute.amazonaws.com/readme.html)

If you want play with terraform export the environment variables that I
sent in the email like this:

```bash
  export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
  export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Once you have this set up you can destroy the ECS service if you want. To do so
you need to specify the resource target because the registry has been declared
with `prevent_destroy` as you can see here:

```
  lifecycle {
    prevent_destroy = true
  }
```
### Init &nbsp;🤯

Asdf plugin for terraform should be already installed from previous `make install`.

```
  terraform init
```

```
  terraform destroy -target=aws_ecs_cluster.sense_eight
  terraform destroy -target=aws_security_group.docs_sg
```

This will destroy the service and wont be accessible
for the time being. Whenever you run `apply` or `destroy` you need to confirm
the plan by writing `yes`.

Once we have everything destroyed but the ECRegistry, we can run `apply` again.
We need to do this in two stages in order to query the public ip or dns.

```
  terraform apply --var 'show_ip=true'
  terraform refresh --var 'show_ip=true'
```

The state is remotely stored in s3, so even that `*.tfstate` is not under
version control, you should be able to access the infrastructure state 🙆🏻‍♂️.
