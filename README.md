[logo]: assets/noizu-logo2.png "Noizu Labs, Inc."

> ![Noizu Labs][logo]

Elixir Core 
===============================================================================

Common protocols and convenience methods leveraged by other Noizu Labs, Inc. frameworks. 


# Noizu.ERP Protocol

The Noizu.ERP protocol allows ref tuples `{:ref, Entity, identifier}` to be used in the place of nesting full objects in other objects. It also supports
encoding/decoding those ref tuples to and from strings for use in restful APIs.

Behind the scenes the ref tuple {:ref, Module, identifier} unpacks itself by calling into Module which must adhere to the protocol and provide local copies of the protcol options.

```elixir
Noizu.ERP.entity({:ref, Noizu.ElixirCore.CallerEntity, :system}) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
Noizu.ERP.ref(%Noizu.ElixirCore.CallerEntity{identifier: :system}) == {:ref, Noizu.ElixirCore.CallerEntity, :system}
Noizu.ERP.sref(%Noizu.ElixirCore.CallerEntity{identifier: :system}) == "ref.noizu-caller.system"
Noizu.ERP.ref("ref.noizu-caller.system") == {:ref, Noizu.ElixirCore.CallerEntity, :system}
Noizu.ERP.ref("george") == nil
```

The methods `[id/1, ref/1, sref/1, entity/1,2, entity!/1,2, record/1,2 record!/1,2]` may all be used interchangeably on ref
strings tuples or actual entities with out having to know in advance what type of object you are access.

### New addition,
Recently added id_ok, ref_ok, sref_ok, entity_ok, and entity_ok! which mirror id/ref/sref/entity/entity!
but return {:ok, value} | {:error, details} in their place for use in `with` etc. pattern matching.


# CallingContext
Context object used to track a caller's state and permissions along
with unique request identifier for tracking requests as they travel through
the layers in your application. Useful for log collation, permission checks,
access auditing.

The basic structure looks like this and provides a semi lightweight object to pass along with your calls as they cross node/component/layer dividers.

```elixir 

%CallingContext{
    # - API Caller
    caller: {:ref, User.Entity, 1234}, 
    # - API caller or generated request id for log collation.
    token: "ajlakjfdowpoewpfjald",
    # - Purpose of API call if provided in request header or body param.
    reason: "New User Setup",
    # - user permissions passed along with call that may be referenced by code to decide if caller has permission to perform action
    auth: %{permissions: %{admin: true, system: true, internal: true, manage_users: true}}, 
    # - options to control ap behaviour. Such as log_filter or use_verbose_logging 
    options: %{},
    # - time Token was generated.
    time: DateTime.t | nil,
    # - original context if for instance a context was promoted to system level permissions using 
    # CallingContext.system(original_caller_context)
    outer_context: %CalingContext{},
}


```


### Configuration
If you have custom ACL/Authorization Bearer tokens etc. you want to extract your caller/permissions from
use these settings. 


Request ID Extraction Strategy.
{m,f}  or function\2 that accepts (conn, default) and pulls request id (CallingContext.token) from Plug.Conn.
> config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_token}

Request Reason Extraction Strategy.
{m,f}  or function\2 that accepts (conn, default) and pulls request reason (CallingContext.reason) from Plug.Conn.
> config :noizu_core, token_strategy: {Noizu.ElixirCore.CallingContext, :extract_reason}

Request Caller Extraction Strategy.
{m,f}  or function\2 that accepts (conn, default) and pulls request Caller (CallingContext.caller) from Plug.Conn
> config :noizu_core, get_plug_caller: {Noizu.ElixirCore.CallingContext, :extract_caller}

Request Caller's Auth Map Extraction Strategy.
{m,f}  or function\2 that accepts (conn, default) and returns effective permission map ContextCaller.auth.
> config :noizu_core, acl_strategy: {Noizu.ElixirCore.CallingContext, :default_auth}

Alternatively you can extract your caller and effective permission list map on your own and use 
> Noizu.ElixirCore.CallingContext.new_conn( your_caller, your_caller_auth_map,  %Plug.Conn{}, options)
> Noizu.ElixirCore.CallingContext.new( your_caller, your_caller_auth_map, options)

### Examples

#### Creation

Get new Calling Context with default Admin user and Permissions.
> Noizu.ElixirCore.CallingContext.admin() 

Get new Calling Context with default System user and Permissions.
> Noizu.ElixirCore.CallingContext.system()

Get new Calling Context with default Internal user and Permissions.
> Noizu.ElixirCore.CallingContext.internal()

Get new Calling Context with default Restricted user and Permissions.
> Noizu.ElixirCore.CallingContext.restricted()

Create new context pulling request caller, auth map, token and reason from Plug.Conn with user provided extract methods. 
> Noizu.ElixirCore.CallingContext.new_conn(conn, options)

#### Logging

Add Context metadata to Logger.  
Example: `[context_token: context.token, context_time: context.time, context_caller: context.caller] ++ context.options.log_filter`
> Noizu.ElixirCore.CallingContext.meta_update(context)

Strip Context metadata from Logger
> Noizu.ElixirCore.CallingContext.meta_strip(context)

Get Context metadata to append to Logger. 
> Logger.info "Your Log", Noizu.ElixirCore.CallingContext.metadata(context)

#### Guards Extensions

Check if context has admin, internal, system, restricted auth flags, etc.
```elixir 
cond do 
    is_admin_caller(context) -> :admin
    is_system_caller(context) -> :system
    is_internal_caller(context) -> :internal
    is_restricted_caller(context) -> :restricted
    permission?(context, :manage_users) -> :caller_can_manage_users
    persmission?(context, :security_level, 5) -> :caller_has_level_5_clearence
    has_call_reason?(context) -> Context was initiated with a call reason message/code.
end
```

# Custom Guards
Some new custom guards to make auth checks, etc. in code cleaner.

| Custom Guard                              | Purpose                                                    |
| :---------------------------------------- | ---------------------------------------------------------- |
| is_caller_context(context)                | is passed variable a %CallingContext{} struct              | 
| caller_context_with_permissions(context)  | dito and includes  context.auth.permissions map            |
| is_system_caller(context)                 | does context have system permission                        |
| is_admin_caller(context)                  | does context have admin permission                         | 
| is_internal_caller(context)               | does context have internal level permission                |
| is_restricted_caller(context)             | is context caller set to restricted level permissions      |
| permission?(context, check)               | does context have specified permission with truthy value   |
| permission?(context, check, value)        | does context have specified permission with specific value |
| has_call_reason?(context)                 | is context's call_reason set/not equal to nil or :none     |
| is_ref(value)                             | is object a {:ref, entity, id} tuple?                      |
| is_sref(value)                            | is object a "ref.code-name.id" string reference            |
| entity_ref(value)                         | is object a ref tuple or struct type with vsn field        |


# Option Helper
Option helpers make it easier to defined restricted/option requirements/defaults constraints for use in meta programming or just
parameter acceptance. The following test snippet detail what's under the hood well.

[option_test.exs](test/lib/option_test.exs)

```elixir

def prepare_options(options) do
  settings = %OptionSettings{
    option_settings: %{
      not_memberset: %OptionList{option: :not_memberset, default: [:one, :two], valid_members: [:one, :two, :three], membership_set: false},
      member_set: %OptionList{option: :member_set, default: [:one, :two], valid_members: [:one, :two, :three], membership_set: true},
      single_value: %OptionValue{option: :single_value, default: :default_value},
      restricted_required_value: %OptionValue{option: :restricted_required_value, required: true, valid_values: [:apple]},
      non_restricted_required_value: %OptionValue{option: :non_restricted_required_value, required: true},
      mapped_value: %OptionValue{option: :mapped_value, lookup_key: :mapped_field},
    }
  }
  OptionSettings.expand(settings, options)
end

@tag :lib
@tag :options
test "basic functionality - expansion" do
  sut = prepare_options([])
  assert sut.effective_options.not_memberset == [:one, :two]
  assert sut.effective_options.member_set == %{one: true, two: true, three: false}
  assert sut.effective_options.single_value == :default_value
  assert Map.has_key?(sut.effective_options, :restricted_required_value) == false
  assert Map.has_key?(sut.effective_options, :non_restricted_required_value) == false
  assert sut.effective_options.mapped_value == nil
end

@tag :lib
@tag :options
test "basic functionality - validation" do
  sut = prepare_options([not_memberset: [:one, :apple], member_set: [:one, :apple], restricted_required_value: :not_apple, non_restricted_required_value: :not_henry])
  assert sut.effective_options.not_memberset == [:one, :apple]
  assert sut.output.errors.not_memberset == {:unsupported_members, [:apple]}

  assert sut.effective_options.member_set ==  %{one: true, two: false, three: false}
  assert sut.output.errors.member_set == {:unsupported_members, [:apple]}

  assert sut.effective_options.restricted_required_value == :not_apple
  assert sut.output.errors.restricted_required_value == {:unsupported_value, :not_apple}

  assert sut.effective_options.non_restricted_required_value == :not_henry
end

@tag :lib
@tag :options
test "basic functionality - mapping" do
  sut = prepare_options([mapped_field: :assigned_to_another])
  assert sut.effective_options.mapped_value == :assigned_to_another
end

```


# Testing Utility - Partial Object Check
Partial Object checks allow you to build a custom assert that compares two objects based off of only specific fields while 
being capable of restricting allowed values or specifying optional fields. E.g.  Assert only that a user.email, user.name.first and user.name.last equal expected values instead of checking for the whole value of the user. . 
This is useful in test automation for creating custom assert methods `assert_user_first_last_and_email(user, expected)` while not having to write a lot of object comparison logic.


It is additionally handy in that it will scan the whole object and report on all constraint violations at once letting your custom assert message tell you exactly why the object is a mismatch 
and not simply the first assert mismatch encountered in a basic custom assert implementation.  

Some raw code examples. 

```elixir

  @tag :testing
  test "IO.inspect check - field constraint fail" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, %{a: 2, b: 2})
    sut_str = "#{inspect sut, limit: 50}"
    assert sut_str == "#PartialObjectCheck<%{assert: :unmet, field_constraints: %{a: #FieldConstraint<%{assert: :unmet, required: true, value_constraint: #ValueConstraint<%{assert: :unmet, constraint: {:value, 1}}>}>}}>"
  end



  @tag :testing
  test "basic functionality - validation - required field with out constraints" do
    poc = POC.prepare(%{a: 1, b: %{any_value: {POC, [:any_value], %{a: 5}}, required: 6}})

    sut = POC.check(poc, %{a: 1, b: %{any_value: %{}, required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{any_value: %{b: 1}, required: 6}, c: :apple})
    assert sut.assert == :met

    # required
    sut = POC.check(poc, %{a: 1, b: %{any_value: nil, required: 6}, c: :apple})
    assert sut.assert == :unmet

    # type fail
    sut = POC.check(poc, %{a: 1, b: %{any_value: 7, required: 6}, c: :apple})
    assert sut.assert == :unmet
  end

  @tag :testing
  test "IO.inspect check - pass" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, %{a: 1, b: 2})
    sut_str = "#{inspect sut}"
    assert sut_str == "#PartialObjectCheck<%{assert: :met}>"
  end

  @tag :testing
  test "IO.inspect check - field constraint fail" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, %{a: 2, b: 2})
    sut_str = "#{inspect sut, limit: 50}"
    assert sut_str == "#PartialObjectCheck<%{assert: :unmet, field_constraints: %{a: #FieldConstraint<%{assert: :unmet, required: true, value_constraint: #ValueConstraint<%{assert: :unmet, constraint: {:value, 1}}>}>}}>"
  end



```



# Convenience Structs
Noizu.ElixirCore.CallerEntity
Noizu.ElixirCore.UnauthenticatedCallerEntity




