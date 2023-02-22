#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.RequestContextTest do
  use ExUnit.Case, async: false
  require Logger
  require Noizu.ElixirCore.RequestContext.Types
  
  @moduletag :lib
  @moduletag :context
  
  describe "Initialize Context" do
    test "Restricted Context" do
    
    end
    
    test "Admin Context - Default" do
      {:ok, sut} = Noizu.RequestContext.admin()
      Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, auth: auth) = sut
      assert caller = {:ref, Noizu.ElixirCore.CallerEntity, :admin}
      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: roles) = auth
      assert true = Enum.member?(roles, :admin)
      
    end
    
    test "System Context" do
    
    end
  end

  describe "Set Context / Fetch Context" do

  end

  describe "Permission Tracking" do
  
  end
  
  describe "Permission Escalation" do
  
  end
  
  describe "Pass context across processes." do

  end


end
