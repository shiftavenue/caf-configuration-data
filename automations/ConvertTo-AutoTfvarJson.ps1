<#
.SYNOPSIS
    Generate auto.tfvars.json for Terraform
.DESCRIPTION
    Using the collected YAML files for a given environment, generate the auto.tfvars.json file for Terraform.
    At the moment, this only extends to the app landing zones. A current state is required to determine the hub network resource IDs.
.PARAMETER Path
    The path to the YAML files.
.PARAMETER TerraformRootModulePath
    The path to the Terraform root module "enterprise_scale".
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [string]
    $RootId = 'shiftavenue',

    [Parameter()]
    [string]
    $TerraformRootModulePath = (Resolve-Path -Path (Join-Path $PSScriptRoot '../')).Path
)

if (-not (Get-Module -ListAvailable powershell-yaml))
{
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

Push-Location
Set-Location -Path $TerraformRootModulePath

$path = (Resolve-Path -Path (Join-Path $PSScriptRoot "../configurationdata/$rootId") -ErrorAction Stop).Path
$variables = @{}

if (Test-Path -Path (Join-Path -Path $Path -ChildPath identity.yml))
{    
    $variables['configure_identity_resources'] = Get-Content -Raw -Path (Join-Path -Path $Path -ChildPath identity.yml) | ConvertFrom-Yaml
}

if (Test-Path -Path (Join-Path -Path $Path -ChildPath management.yml))
{
    $variables['configure_management_resources'] = Get-Content -Raw -Path (Join-Path -Path $Path -ChildPath management.yml) | ConvertFrom-Yaml
}

if (Test-Path -Path (Join-Path -Path $Path -ChildPath networking.yml))
{
    $variables['configure_connectivity_resources'] = Get-Content -Raw -Path (Join-Path -Path $Path -ChildPath networking.yml) | ConvertFrom-Yaml
}

if (Test-Path -Path (Join-Path -Path $Path -ChildPath archetype_config_overrides.yml))
{
    $variables['archetype_config_overrides'] = Get-Content -Raw -Path (Join-Path -Path $Path -ChildPath archetype_config_overrides.yml) | ConvertFrom-Yaml
}

if (Test-Path -Path (Join-Path -Path $Path -ChildPath custom_landing_zones.yml))
{
    $variables['custom_landing_zones'] = Get-Content -Raw -Path (Join-Path -Path $Path -ChildPath custom_landing_zones.yml) | ConvertFrom-Yaml
}

$subscriptions = Get-ChildItem -Path (Join-Path -Path $Path -ChildPath applicationlandingzones) -Filter *.y*ml -PipelineVariable file | Get-Content -Raw | foreach-object { $_ | ConvertFrom-Yaml | Add-Member -NotePropertyName BaseName -NotePropertyValue $file.BaseName -PassThru }

$variables['subscriptions'] = [System.Collections.Generic.List[hashtable]]::new()
$variables['federated_credentials'] = [System.Collections.Generic.List[hashtable]]::new()
foreach ($subscription in $subscriptions)
{
    $variables['subscriptions'].Add(
        @{
            subscription_id                                       = $subscription.subscription_id
            subscription_alias_enabled                            = [string]::IsNullOrWhiteSpace($subscription.subscription_id)
            subscription_display_name                             = if ([string]::IsNullOrWhiteSpace($subscription.subscription_display_name)) { $subscription.BaseName } else { $subscription.subscription_display_name }
            subscription_alias_name                               = if ([string]::IsNullOrWhiteSpace($subscription.subscription_alias_name)) { $subscription.BaseName } else { $subscription.subscription_alias_name }
            subscription_workload                                 = if (-not $subscription.subscription_workload) { 'Production' } else { $subscription.subscription_workload } # DevTest only for EA
            subscription_tags                                     = $subscription.subscription_tags
            subscription_management_group_id                      = $subscription.subscription_management_group_id
            resource_groups                                       = if ($subscription.resource_groups.Count -gt 0) { $subscription.resource_groups } else { @{} }
            umi_name                                              = $subscription.umi_name
            umi_resource_group_name                               = $subscription.umi_resource_group_name
            umi_role_assignments                                  = $subscription.umi_role_assignments
            virtual_networks                                      = if ($subscription.virtual_networks) { $subscription.virtual_networks } else { @{} }
            role_assignment_enabled                               = $subscription.role_assignments.Count -gt 0
            role_assignments                                      = if ($subscription.role_assignments) { $subscription.role_assignments } else { @{} }
            subscription_register_resource_providers_and_features = if ($subscription.subscription_register_resource_providers_and_features) { $subscription.subscription_register_resource_providers_and_features } else { @{} }
            umi_resource_group_lock_name                          = if (-not [string]::IsNullOrWhitespace($subscription.umi_resource_group_lock_name)) { $subscription.umi_resource_group_lock_name } else { [string]::Empty }
            umi_federated_credentials_github                      = $subscription.umi_federated_credentials_github
        }
    )

    if ($subscription.umi_federated_credentials_github -and $subscription.subscription_tags['project_name'])
    {
        $variables['federated_credentials'].Add(@{
                subscription_display_name = $subscription.subscription_display_name
                project_name              = $subscription.subscription_tags['project_name']
            })
    }
}

$variables | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $TerraformRootModulePath 'full.auto.tfvars.json') -Force
