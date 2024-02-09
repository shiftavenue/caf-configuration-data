# CAF Configuration Data

This template repository helps you get started with the Azure Cloud Adoption Framework Landing Zone Architecture using an opinionated approach with Terraform and configuration data.

## Why opinionated?

We are using a configuration-data-driven approach with YAML configuration data and Terraform configurations.
The actual code does not need to be modified regularly,
whereas the configuration data may be a bit more actively updated. By separating both, we have clean code with little to
no hardcoded data and a wealth of configuration data to draw from. By using schemas for both code completion as well as
validation, editing the configuration data should be just as lovely as writing Terraform code.

## What's in it for me?

Peace of mind! Oh, and the use of two standardized modules which combined with configuration data will set up
your tenant in no time.