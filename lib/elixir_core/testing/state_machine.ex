

defmodule Noizu.StateMachine.Module do
  require Record
  Record.defrecord(:nsm, [global: nil, local: nil, other: nil, smother: 5])

  defmacro defsm_module(name, [do: block]) do
    quote do
      m = Module.get_attribute(__MODULE__, :__sm_ms, [])
      @__sm_ms [unquote(name), m]
      IO.puts "ENTER MODULE| #{inspect @__sm_ms}"
      unquote(block)
      @__sm_ms Enum.slice(@__sm_ms, 1..-1)
    end
  end

#  defmacro defsm({:when, _, [{:state_behavior, meta, args} = signature | guards]}, do: body) do
#  #defmacro state_behavior(yabba, [do: block]) do
#    IO.puts "ENTERING FOR_STATE: #{inspect signature}"
#  end

  #    args_list = Enum.map(args, fn
  #      {{:., _, [:&, _]}, _, [arg]} -> arg
  #      arg -> arg
  #    end)
  #
  #    quote do
  #      def unquote(name)(unquote_splicing(args_list)) when unquote(guards) do
  #        unquote(body)
  #      end
  #    end
  def check_header(name, args) do
    IO.puts "HAS #{name}/#{length(args)} been pushed already?"
    :ok
  end

  defmacro defsm({:when, _, [{:state_behaviour, meta, args} = signature | guards]}, do: body) do
    # Disallow default args
    # Replace global_state, local_state with nsm__internal_global nsm__internal_local
    {p_args, f} =
      cond do
        args == [] || args == nil ->
          m = meta
          nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
          {[{:nsm, meta, [nargs]}], :set}
        length(args) == 1 ->
          Macro.postwalk(args || [], nil,
            fn

              (ast = {:nsm, m, [nargs]}, acc) when is_list(nargs) ->
                gi = Enum.find_index(nargs, &(elem(&1, 0) == :global))
                nargs = case gi do
                  nil -> nargs ++ [global: {:=, m, [{:global, m, nil}, {:_global, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:global, v}) ->
                               {:global, {:=, [{:global, m, nil}, v]}}
                             end
                           )
                end
                li = Enum.find_index(nargs, &(elem(&1, 0) == :local))
                nargs = case li do
                  nil -> nargs ++ [local: {:=, m, [{:local, m, nil}, {:_local, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:local, v}) ->
                               {:local, {:=, [{:local, m, nil}, v]}}
                             end
                           )
                end
                {{:nsm, m, [nargs]}, :updated}

              (ast = {:nsm, m, []}, acc) ->
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              (ast = {:nsm, m, nil}, acc) ->
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              (other, acc) -> {other, acc}
            end
          )
      end
    IO.puts "ENTER STATE CONSTRAINT SECTION| #{f}"
    unless f do
      throw "MALFORMED"
    end

    # todo composite p_args
    p_args = p_args
             |> Macro.escape()
    guards = guards
                 |> Macro.escape()


    quote do
      a = Module.get_attribute(__MODULE__, :__sm_withargs, [])
      g = Module.get_attribute(__MODULE__, :__sm_withguards, [])

      @__sm_withargs [unquote(p_args)  | a]
      @__sm_withguards [unquote(guards) | g]
      unquote(body)

      @__sm_withguards Enum.slice(@__sm_withguards, 1..-1)
      @__sm_withargs Enum.slice(@__sm_withargs, 1..-1)
    end
  end

  defmacro blowitup22(name, meta, args, guards, block) do
    inject = quote do
      unquote({:def, meta, [{:when, meta, [{name, meta, args}|guards]}, [do: block]]})
    end
    Macro.to_string(inject) |> IO.inspect(label: "Code")

    inject
  end
  defmacro blowitup2(name, meta, args, guards, block) do
    guards = Macro.expand(guards, __CALLER__)
    inject = quote do
      unquote({:def, meta, [{:when, meta, [{name, meta, args}|[guards]]}, [do: block]]})
#      def unquote(name)(unquote_splicing(args)) when unquote(guards) do
#        unquote(block)
#      end
    end
    Macro.to_string(inject) |> IO.inspect(label: "Code")
    inject
  end

  defmacro blowitup_join(a,b) do
    a = Macro.expand(a, __CALLER__)
    b = Macro.expand(b, __CALLER__)
    quote do
      unquote(a) and unquote(b)
    end
  end

  defmacro blowitup(name, meta, prefix, args, guards, block) do
    [gg] = guards

    quote do
      IO.puts "\n\n-------- #{unquote name} ------\n"
      q = Macro.expand(unquote(prefix),__ENV__)
      args = unquote(Macro.escape(args))

      effective_guards =
        (Module.get_attribute(__MODULE__, :__sm_withguards, [])
         |> List.flatten()
         |> case do
              [] -> nil
              prefix_guard when is_list(prefix_guard) ->
                p = prefix_guard
                    |> Enum.reduce([], fn(x, acc) ->
                  cond do
                    acc == [] -> x
                    :else -> {:and, unquote(meta), [x,acc]}
                  end
                end)
                guards = unquote(Macro.escape(guards))
                {:and, [], [p| guards]}
            end)
        |> IO.inspect(label: :guards)
      unless g_pre = effective_guards do
        def unquote(name)(nsm = (quote do: unquote(q)), unquote_splicing(args)) when unquote(gg) do
          unquote(block)
        end
        |> IO.inspect(label: "DELCA1")
      else
        name = unquote(name)
        [qq] = q
        {qq2,_} = qq
              |> Macro.prewalk(nil,
                   fn
                   ({:=, [lhs, rhs]}, acc) ->
                     inject = quote do
                       unquote(lhs) = unquote(rhs)
                     end
                     {inject, acc}
                     (ast, acc) ->
                       IO.inspect ast
                       {ast, acc}
                   end
                 )
                 |> IO.inspect(label: "QQ2")


        iargs = [{:=, [], [{:state, [], nil}, qq2]}| unquote(Macro.escape(args))]
                |> Macro.expand(__ENV__)
                #|> IO.inspect(label: "IARAGS")
        block = unquote(Macro.escape(block))

        q = {:def, [], [{:when, [], [{unquote(name), [], (quote do: unquote(iargs))}, g_pre]}, [do: block]]}
            |> Macro.to_string()
            |> Code.string_to_quoted!()

        #{:def, [], [{:when, [], [{name, [], iargs}, g_pre]}, do: block]}
        #unquote(h)
#        q = quote do
#          def unquote(name)(unquote_splicing(iargs)) do
#            unquote(block)
#          end
#        end
#            |> IO.inspect
#            |> Macro.expand(__ENV__)
            |> IO.inspect(label: "DECLARED 2.")
      end



    end
  end

  defmacro defsm({:when, wm, [{name, meta, args} = signature | guards]}, do: block) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args} with guards"

    prefix_arg =
      quote do
        Module.get_attribute(__MODULE__, :__sm_withargs, [])
        |> IO.inspect(label: :arg_statements)
        |> List.first()
      end



    quote do
      guards = unquote(Macro.escape(guards))


      q = blowitup(
        unquote(name),
        unquote(wm),
        unquote(prefix_arg),
        unquote(args),
        unquote(guards),
        unquote(block)
      ) #|> IO.inspect(label: :inner)
      |> Macro.expand(__ENV__)
      |> Code.compile_quoted()
      |> IO.inspect(label: :inner2)

    end

  end

  defmacro defsm({name, meta, args} = signature, do: body) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args}"
  end
  defmacro defsm({name, meta, args} = signature) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    with :ok <- check_header(name, args) do
      IO.puts "PUSH def head for #{inspect name}\\#{length args}"
    end
  end

end

defmodule Noizu.StateMachine do

  defmacro __using__(options \\ nil) do
    quote do
      require Noizu.StateMachine.Module
      import Noizu.StateMachine.Module
    end
  end


end
