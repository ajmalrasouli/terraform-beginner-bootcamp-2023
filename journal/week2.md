# Terraform Beginner Bootcamp 2023 - Week 2

## Working with Ruby

### Bundler

Bundler is a package manager for runy.
It is the primary way to install ruby packages (known as gems) for ruby.

#### Install Gems

You need to create a Gemfile and define your gems in that file.

```rb
source "https://rubygems.org"

gem 'sinatra'
gem 'rake'
gem 'pry'
gem 'puma'
gem 'activerecord'
```

Then you need to run the `bundle install` command

This will install the gems on the system globally (unlike nodejs which install packages in place in a folder called node_modules)

A Gemfile.lock will be created to lock down the gem versions used in this project.

#### Executing ruby scripts in the context of bundler

We have to use `bundle exec` to tell future ruby scripts to use the gems we installed. This is the way we set context.

### Sinatra

Sinatra is a micro web-framework for ruby to build web-apps.

Its great for mock or development servers or for very simple projects.

You can create a web-server in a single file.

https://sinatrarb.com/

## Terratowns Mock Server

### Running the web server

We can run the web server by executing the following commands:

```rb
bundle install
bundle exec ruby server.rb
```

All of the code for our server is stored in the `server.rb` file.


## CRUD

Terraform Provider resources utilize CRUD.

CRUD stands for Create, Read Update, and Delete

https://en.wikipedia.org/wiki/Create,_read,_update_and_delete



## Implement Create

Back in `resource_server.go`, implement the create functionality:

```go
func resourceServerCreate(d *schema.ResourceData, m interface{}) error {
	address := d.Get("address").(string)
	d.SetId(address)
	return nil
}
```

This uses the [`schema.ResourceData
API`](https://godoc.org/github.com/hashicorp/terraform/helper/schema#ResourceData)
to get the value of `"address"` provided by the user in the Terraform
configuration. Due to the way Go works, we have to typecast it to string. This
is a safe operation, however, since our schema guarantees it will be a string
type.

Next, it uses `SetId`, a built-in function, to set the ID of the resource to the
address. The existence of a non-blank ID is what tells Terraform that a resource
was created. This ID can be any string value, but should be a value that can be
used to read the resource again.

Recompile the binary, the run `terraform plan` and `terraform apply`.

```shell
$ go build -o terraform-provider-example
# ...
```

```text
$ terraform plan

+ example_server.my-server
    address: "1.2.3.4"


Plan: 1 to add, 0 to change, 0 to destroy.
```

```text
$ terraform apply

example_server.my-server: Creating...
  address: "" => "1.2.3.4"
example_server.my-server: Creation complete (ID: 1.2.3.4)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Since the `Create` operation used `SetId`, Terraform believes the resource created successfully. Verify this by running `terraform plan`.

```text
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

example_server.my-server: Refreshing state... (ID: 1.2.3.4)
No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, Terraform
doesn't need to do anything.
```

Again, because of the call to `SetId`, Terraform believes the resource was
created. When running `plan`, Terraform properly determines there are no changes
to apply.

To verify this behavior, change the value of the `address` field and run
`terraform plan` again. You should see output like this:

```text
$ terraform plan
example_server.my-server: Refreshing state... (ID: 1.2.3.4)

~ example_server.my-server
    address: "1.2.3.4" => "5.6.7.8"


Plan: 0 to add, 1 to change, 0 to destroy.
```

Terraform detects the change and displays a diff with a `~` prefix, noting the
resource will be modified in place, rather than created new.

Run `terraform apply` to apply the changes.

```text
$ terraform apply
example_server.my-server: Refreshing state... (ID: 1.2.3.4)
example_server.my-server: Modifying... (ID: 1.2.3.4)
  address: "1.2.3.4" => "5.6.7.8"
example_server.my-server: Modifications complete (ID: 1.2.3.4)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Since we did not implement the `Update` function, you would expect the
`terraform plan` operation to report changes, but it does not! How were our
changes persisted without the `Update` implementation?

## Error Handling &amp; Partial State

Previously our `Update` operation succeeded and persisted the new state with an
empty function definition. Recall the current update function:

```golang
func resourceServerUpdate(d *schema.ResourceData, m interface{}) error {
	return nil
}
```

The `return nil` tells Terraform that the update operation succeeded without
error. Terraform assumes this means any changes requested applied without error.
Because of this, our state updated and Terraform believes there are no further
changes.

To say it another way: if a callback returns no error, Terraform automatically
assumes the entire diff successfully applied, merges the diff into the final
state, and persists it.

Functions should _never_ intentionally `panic` or call `os.Exit` - always return
an error.

In reality, it is a bit more complicated than this. Imagine the scenario where
our update function has to update two separate fields which require two separate
API calls. What do we do if the first API call succeeds but the second fails?
How do we properly tell Terraform to only persist half the diff? This is known
as a _partial state_ scenario, and implementing these properly is critical to a
well-behaving provider.

Here are the rules for state updating in Terraform. Note that this mentions
callbacks we have not discussed, for the sake of completeness.

- If the `Create` callback returns with or without an error without an ID set
  using `SetId`, the resource is assumed to not be created, and no state is
  saved.

- If the `Create` callback returns with or without an error and an ID has been
  set, the resource is assumed created and all state is saved with it. Repeating
  because it is important: if there is an error, but the ID is set, the state is
  fully saved.

- If the `Update` callback returns with or without an error, the full state is
  saved. If the ID becomes blank, the resource is destroyed (even within an
  update, though this shouldn't happen except in error scenarios).

- If the `Destroy` callback returns without an error, the resource is assumed to
  be destroyed, and all state is removed.

- If the `Destroy` callback returns with an error, the resource is assumed to
  still exist, and all prior state is preserved.

- If partial mode (covered next) is enabled when a create or update returns,
  only the explicitly enabled configuration keys are persisted, resulting in a
  partial state.

_Partial mode_ is a mode that can be enabled by a callback that tells Terraform
that it is possible for partial state to occur. When this mode is enabled, the
provider must explicitly tell Terraform what is safe to persist and what is not.

Here is an example of a partial mode with an update function:

```go
func resourceServerUpdate(d *schema.ResourceData, m interface{}) error {
	// Enable partial state mode
	d.Partial(true)

	if d.HasChange("address") {
		// Try updating the address
		if err := updateAddress(d, m); err != nil {
			return err
		}

		d.SetPartial("address")
	}

	// If we were to return here, before disabling partial mode below,
	// then only the "address" field would be saved.

	// We succeeded, disable partial mode. This causes Terraform to save
	// all fields again.
	d.Partial(false)

	return nil
}
```

Note - this code will not compile since there is no `updateAddress` function.
You can implement a dummy version of this function to play around with partial
state. For this example, partial state does not mean much in this documentation
example. If `updateAddress` were to fail, then the address field would not be
updated.

## Implementing Destroy

The `Destroy` callback is exactly what it sounds like - it is called to destroy
the resource. This operation should never update any state on the resource. It
is not necessary to call `d.SetId("")`, since any non-error return value assumes
the resource was deleted successfully.

```go
func resourceServerDelete(d *schema.ResourceData, m interface{}) error {
  // d.SetId("") is automatically called assuming delete returns no errors, but
  // it is added here for explicitness.
	d.SetId("")
	return nil
}
```

The destroy function should always handle the case where the resource might
already be destroyed (manually, for example). If the resource is already
destroyed, this should not return an error. This allows Terraform users to
manually delete resources without breaking Terraform.

```shell
$ go build -o terraform-provider-example
```

Run `terraform destroy` to destroy the resource.

```text
$ terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

example_server.my-server: Refreshing state... (ID: 5.6.7.8)
example_server.my-server: Destroying... (ID: 5.6.7.8)
example_server.my-server: Destruction complete

Destroy complete! Resources: 1 destroyed.
```

## Implementing Read

The `Read` callback is used to sync the local state with the actual state
(upstream). This is called at various points by Terraform and should be a
read-only operation. This callback should never modify the real resource.

If the ID is updated to blank, this tells Terraform the resource no longer
exists (maybe it was destroyed out of band). Just like the destroy callback, the
`Read` function should gracefully handle this case.

```go
func resourceServerRead(d *schema.ResourceData, m interface{}) error {
  client := m.(*MyClient)

  // Attempt to read from an upstream API
  obj, ok := client.Get(d.Id())

  // If the resource does not exist, inform Terraform. We want to immediately
  // return here to prevent further processing.
  if !ok {
    d.SetId("")
    return nil
  }

  d.Set("address", obj.Address)
  return nil
}
```

## Next Steps

This guide covers the schema and structure for implementing a Terraform provider
using the provider framework. As next steps, reference the internal providers
for examples. Terraform also includes a full framework for testing providers.

## General Rules

### Dedicated Upstream Libraries

One of the biggest mistakes new users make is trying to conflate a client
library with the Terraform implementation. Terraform should always consume an
independent client library which implements the core logic for communicating
with the upstream. Do not try to implement this type of logic in the provider
itself.