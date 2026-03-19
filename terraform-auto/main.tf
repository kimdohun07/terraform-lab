name: Terraform Check

on:
  push:
    branches:
      - main

jobs:
  terraform-web2:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform-web2

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan

  terraform-alb:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform-alb

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan