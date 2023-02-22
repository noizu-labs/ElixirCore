#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.RequestContextTest do
  use ExUnit.Case, async: false
  use Plug.Test
  require Logger
  require Noizu.ElixirCore.RequestContext.Types
  
  @moduletag :lib
  @moduletag :context
  
  describe "Default Contexts" do
    test "System Context - Default" do
      {:ok, sut} = Noizu.RequestContext.system()
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :system)
    end
    
    test "Admin Context - Default" do
      {:ok, sut} = Noizu.RequestContext.admin()
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :admin}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :admin)
    end

    test "Internal Context - Default" do
      {:ok, sut} = Noizu.RequestContext.internal()
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :internal}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :internal)
    end

    test "Restricted Context - Default" do
      {:ok, sut} = Noizu.RequestContext.restricted()
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :restricted}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :restricted)
    end
  end
  
  describe "Privilege Escalation/De-escalation" do
    test "System Context - Permission De-escalation" do
      {:ok, context} = Noizu.RequestContext.system()
      {:ok, sut} = Noizu.RequestContext.restricted(context)
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth, inner_context: nested) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :restricted}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert false == Enum.member?(roles, :system)
      assert true == Enum.member?(roles, :restricted)
      assert nested == context
    end

    test "Restricted Context - Permission Escalation" do
      {:ok, context} = Noizu.RequestContext.restricted()
      {:ok, sut} = Noizu.RequestContext.system(context)
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth, inner_context: nested) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :system)
      assert false == Enum.member?(roles, :restricted)
      assert nested == context
    end
  end
  
  describe "Context from Conn.Plug source" do
    test "System Context - Query Param Settings" do
       conn = conn(:post, "/hello?request-id=fiz&call-reason=testing", %{})
      {:ok, sut} = Noizu.RequestContext.system(conn)
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth, extended: details) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :system)
       Noizu.ElixirCore.RequestContext.Types.extended_request_context(
         token: token,
         reason: reason,
         options: options
       ) = details
      assert token == "fiz"
      assert reason == "testing"
      assert options == nil
    end

    test "System Context - Body Params" do
      conn = conn(:post, "/hello", %{"request-id" => "bop", "call-reason" => "more testing"})
      {:ok, sut} = Noizu.RequestContext.system(conn)
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth, extended: details) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :system)
      Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        token: token,
        reason: reason,
        options: options
      ) = details
      assert token == "bop"
      assert reason == "more testing"
      assert options == nil
    end


    test "System Context - Header Params" do
      conn = conn(:post, "/hello", %{})
             |> put_req_header("x-request-id", "header guid")
             |> put_req_header("x-call-reason", "configuring context with headers")
      {:ok, sut} = Noizu.RequestContext.system(conn)
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth, extended: details) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :system)
      Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        token: token,
        reason: reason,
        options: options
      ) = details
      assert token == "header guid"
      assert reason == "configuring context with headers"
      assert options == nil
    end
  end
  
  describe "Logger Instrumentation" do
    
    test "Auto Instrument For From Conn" do
      (Logger.metadata() || [])
      |> Keyword.drop([:context_caller, :context_time, :context_token])
      |> Logger.metadata()
      
      meta_pre = Logger.metadata()
      conn = conn(:post, "/hello", %{"request-id" => "bop", "call-reason" => "more testing"})
      {:ok, sut} = Noizu.RequestContext.system(conn)
      meta_post = Logger.metadata()


      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, extended: details) = sut
      Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        token: token
      ) = details

      assert meta_pre[:context_caller] == nil
      assert meta_pre[:context_token] == nil
      
      assert meta_post[:context_caller] == caller
      assert meta_post[:context_token] == token
    end




    test "Extended Log Filter Metadata" do
      [context_caller: nil, context_time: nil, context_token: nil]
      |> Logger.metadata()

      test_field = :"test_#{:os.system_time(:millisecond)}_filter"
      options = [request_context: [log_filter: [{test_field, :biz_bop}]]]

      meta_pre = Logger.metadata()
      conn = conn(:post, "/hello", %{"request-id" => "bop", "call-reason" => "more testing"})
      {:ok, sut} = Noizu.RequestContext.system(conn, options)
      meta_post = Logger.metadata()
  
  
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, extended: details) = sut
      Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        token: token
      ) = details
  
      assert meta_pre[:context_caller] == nil
      assert meta_pre[:context_token] == nil
      assert meta_pre[test_field] == nil
      
      
      assert meta_post[:context_caller] == caller
      assert meta_post[:context_token] == token
      assert meta_post[test_field] == :biz_bop

      Noizu.RequestContext.meta_strip(sut)
      meta_post_strip = Logger.metadata()
      assert meta_post_strip[:context_caller] == nil
      assert meta_post_strip[:context_token] == nil
      assert meta_post_strip[test_field] == nil

      Noizu.RequestContext.meta_update(sut)
      meta_post = Logger.metadata()
      assert meta_post[:context_caller] == caller
      assert meta_post[:context_token] == token
      assert meta_post[test_field] == :biz_bop




    end
    
    
  end
  
  describe "Legacy CallingContext Interop" do
    test "Cast To Legacy" do
      {:ok, context} = Noizu.RequestContext.system()
      {:ok, sut} = Noizu.RequestContext.to_legacy(context, [])

      assert sut.caller == {:ref, Noizu.ElixirCore.CallerEntity, :system}
      assert sut.auth.permissions == %{system: true, internal: true}
      assert sut.outer_context == nil
    end

    test "Cast From Legacy" do
      context = Noizu.ElixirCore.CallingContext.admin()
      {:ok, sut} = Noizu.RequestContext.from_legacy(context, [])
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller == {:ref, Noizu.ElixirCore.CallerEntity, :admin}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true == Enum.member?(roles, :admin)
    end
  end
  
  describe "Set Context / Fetch Context" do

  end
  
  describe "Pass context across processes." do

  end


end
