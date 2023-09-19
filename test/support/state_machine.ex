
defmodule Noizu.TestSM do
  use Noizu.StateMachine

  @apple 5
  defsm well(a,b,c,d \\ 7)
  defsm well(a,b,5, d) when a in [5] and b == 5 do
    :ok1
  end

  defsm state_behaviour(nsm(local: %{flag: 1})) when (global.flag in [1,2,3] or local.flag == true) do
    defsm state_behaviour(nsm(global: %{flag: 1})) when global.flag2 in [1,2,3] and local.flag2 == 2 do
      defsm well(a,b,6, d) when a in [1,2] and b == 5 do
        :ok2
      end
      defsm well(a,b,6, d) when a in [3,6] and b == 5 do
        :ok3
      end
    end
    defsm well(a,b,c, d) when a in [1,2,3,4,5] do
      {:ok4, self(), a}
    end
  end
end
