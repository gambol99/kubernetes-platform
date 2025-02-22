# Release Directory

The `release` cab be used to mock a consuming tenant repository. Here we can point back at the development branch of the repository for testing purposes.

## Local Development

In order to test the platform locally, you can use the tenant release repository to mock the tenant repository.

1. Create a branch from the repository and push your changes.
2. Run the `make local` script - this will build a `kind` cluster and bootstrap with the platform, using your branch as the entrypoint.
3. Any changes to the branch will be picked up by the platform.
