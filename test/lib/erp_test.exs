#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.ErpTest do
  use ExUnit.Case, async: false
  require Logger
  @moduletag :lib
  @moduletag :erp
  
  describe "Operations on Tuple" do
    @sut {:ref, Noizu.ElixirCore.CallerEntity, :system}
    
    test "id" do
      assert Noizu.ERP.id(@sut) ==  :system
    end
    
    test "id_ok" do
      assert Noizu.ERP.id_ok(@sut) == {:ok, :system}
    end
    
    test "ref" do
      assert Noizu.ERP.ref(@sut) ==  {:ref, Noizu.ElixirCore.CallerEntity, :system}
    end
    
    test "ref_ok" do
      assert Noizu.ERP.ref_ok(@sut) == {:ok, {:ref, Noizu.ElixirCore.CallerEntity, :system}}
    end
    
    test "sref" do
      assert Noizu.ERP.sref(@sut) ==  "ref.noizu-caller.system"
    end
    
    test "sref_ok" do
      assert Noizu.ERP.sref_ok(@sut) ==  {:ok, "ref.noizu-caller.system"}
    end
    
    test "entity" do
      assert Noizu.ERP.entity(@sut) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
    end
    
    test "entity_ok" do
      assert Noizu.ERP.entity_ok(@sut) == {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
    end
    
    test "entity!" do
      assert Noizu.ERP.entity!(@sut) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
    end
    
    test "entity_ok!" do
      assert Noizu.ERP.entity_ok!(@sut) == {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
    end
  
  end
  
  
  describe "Operations on Entity" do
    @sut %Noizu.ElixirCore.CallerEntity{identifier: :system}
    
    test "id" do
      assert Noizu.ERP.id(@sut) ==  :system
    end
    
    test "id_ok" do
      assert Noizu.ERP.id_ok(@sut) == {:ok, :system}
    end
    
    test "ref" do
      assert Noizu.ERP.ref(@sut) ==  {:ref, Noizu.ElixirCore.CallerEntity, :system}
    end
    
    test "ref_ok" do
      assert Noizu.ERP.ref_ok(@sut) == {:ok,{:ref, Noizu.ElixirCore.CallerEntity, :system}}
    end
    
    test "sref" do
      assert Noizu.ERP.sref(@sut) ==  "ref.noizu-caller.system"
    end
    
    test "sref_ok" do
      assert Noizu.ERP.sref_ok(@sut) ==  {:ok, "ref.noizu-caller.system"}
    end
    
    test "entity" do
      assert Noizu.ERP.entity(@sut) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
    end
    
    test "entity_ok" do
      assert Noizu.ERP.entity_ok(@sut) == {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
    end
    
    test "entity!" do
      assert Noizu.ERP.entity!(@sut) == %Noizu.ElixirCore.CallerEntity{identifier: :system}
    end
    
    test "entity_ok!" do
      assert Noizu.ERP.entity_ok!(@sut) == {:ok, %Noizu.ElixirCore.CallerEntity{identifier: :system}}
    end
  
  end
  
  
  describe "Operations on List" do
    @sut [
      %Noizu.ElixirCore.CallerEntity{identifier: :system},
      {:ref, Noizu.ElixirCore.CallerEntity, :restricted}
    ]
  
    test "id" do
      assert Noizu.ERP.id(@sut) ==  [
             :system,
             :restricted
             ]
    end
  
    test "id_ok" do
      assert Noizu.ERP.id_ok(@sut) == {:ok, [
               :system,
               :restricted
             ]
      }
    end
  
    test "ref" do
      assert Noizu.ERP.ref(@sut) ==  [{:ref, Noizu.ElixirCore.CallerEntity, :system},{:ref, Noizu.ElixirCore.CallerEntity, :restricted}]
    end
  
    test "ref_ok" do
      assert Noizu.ERP.ref_ok(@sut) == {:ok,[{:ref, Noizu.ElixirCore.CallerEntity, :system},{:ref, Noizu.ElixirCore.CallerEntity, :restricted}]}
    end
  
    test "sref" do
      assert Noizu.ERP.sref(@sut) ==  ["ref.noizu-caller.system", "ref.noizu-caller.restricted"]
    end
  
    test "sref_ok" do
      assert Noizu.ERP.sref_ok(@sut) ==  {:ok, ["ref.noizu-caller.system", "ref.noizu-caller.restricted"]}
    end
  
    test "entity" do
      assert Noizu.ERP.entity(@sut) == [%Noizu.ElixirCore.CallerEntity{identifier: :system},%Noizu.ElixirCore.CallerEntity{identifier: :restricted}]
    end
  
    test "entity_ok" do
      assert Noizu.ERP.entity_ok(@sut) == {:ok, [%Noizu.ElixirCore.CallerEntity{identifier: :system},%Noizu.ElixirCore.CallerEntity{identifier: :restricted}]}
    end
  
    test "entity!" do
      assert Noizu.ERP.entity!(@sut) == [%Noizu.ElixirCore.CallerEntity{identifier: :system},%Noizu.ElixirCore.CallerEntity{identifier: :restricted}]
    end
  
    test "entity_ok!" do
      assert Noizu.ERP.entity_ok!(@sut) == {:ok, [%Noizu.ElixirCore.CallerEntity{identifier: :system},%Noizu.ElixirCore.CallerEntity{identifier: :restricted}]}
    end

  end


end
