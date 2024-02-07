{% if azure_devops_pipeline is defined %}
trigger:
  batch: true
  branches:
    include:
      - main
  tags:
    include:
      - "*"

pool:
  vmImage: ubuntu-latest
{%- for cluster in clusters %}
stages:
  - stage: validate
    displayName: validate
    jobs:
      - job: validate
        displayName: validate
        variables: # vars from azure devOps in library
          - group: {{ azure_devops_pipeline.library_group }}
        steps:
          - checkout: self
          - script: |
              terraform -chdir=platform/env/{{ cluster.stage }} init
              terraform -chdir=platform/env/{{ cluster.stage }} validate
            name: "ValidateTerraform"
            displayName: "Validate Terraform"
            env:
              ARM_CLIENT_ID: $(ARM_CLIENT_ID)
              ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
              ARM_TENANT_ID: $(ARM_TENANT_ID)
              ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)

  - stage: plan
    displayName: plan
    jobs:
      - job: plan
        displayName: plan
        variables: # vars from azure devOps in library
          - group: {{ azure_devops_pipeline.library_group }}
        steps:
          - checkout: self
          - script: |
              mkdir -p platform/env/{{ cluster.stage }}/build
              terraform -chdir=platform/env/{{ cluster.stage }} init
              terraform -chdir=platform/env/{{ cluster.stage }} plan -var-file=terraform.tfvars -out=$(Build.SourceVersion).plan
              cp platform/env/{{ cluster.stage }}/$(Build.SourceVersion).plan platform/env/{{ cluster.stage }}/build
            name: "PlanTerraform"
            displayName: "Terraform Plan"
            env:
              ARM_CLIENT_ID: $(ARM_CLIENT_ID)
              ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
              ARM_TENANT_ID: $(ARM_TENANT_ID)
              ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
          - publish: $(Build.SourcesDirectory)/platform/env/{{ cluster.stage }}/build
            artifact: $(Build.SourceVersion).plan

  - stage: apply
    jobs:
      - deployment: ApplyTerraform
        displayName: "Terraform Apply"
        variables: # vars from azure devOps in library
          - group: {{ azure_devops_pipeline.library_group }}
        # creates an environment if it doesn't exist
        environment: {{ cluster.stage }}
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self
                - download: current
                  artifact: $(Build.SourceVersion).plan
                - script: |
                    cp $(Pipeline.Workspace)/$(Build.SourceVersion).plan/$(Build.SourceVersion).plan platform/env/{{ cluster.stage }}
                    terraform -chdir=platform/env/{{ cluster.stage }} init
                    terraform -chdir=platform/env/{{ cluster.stage }} apply $(Build.SourceVersion).plan
                  name: "ApplyTerraform"
                  displayName: "Terraform Apply"
                  env:
                    ARM_CLIENT_ID: $(ARM_CLIENT_ID)
                    ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
                    ARM_TENANT_ID: $(ARM_TENANT_ID)
                    ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
{%- endfor %}
{% endif %}
