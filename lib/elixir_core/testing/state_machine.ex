

defmodule Noizu.StateMachine.Module do
  require Record
  Record.defrecord(:nsm, [global: nil, local: nil, other: nil, smother: 5])
  import Macro

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


  defmacro blowitup(name, meta, prefix, args, guards, block) do
    gg = case guards do
      [gg] -> gg
      gg -> gg
    end

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
                unless guards == [] do
                  {:and, [], [p| guards]}
                else
                  p
                end

            end)

      unless g_pre = effective_guards do
#        def unquote(name)(nsm = (quote do: unquote(q)), unquote_splicing(args)) when unquote(gg) do
#          unquote(block)
#        end

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
                           {ast, acc}
                       end
                     )


        iargs = [{:=, [], [{:nsm, [], nil}, qq2]}| unquote(Macro.escape(args))]
                |> Macro.expand(__ENV__)
        #|> IO.inspect(label: "IARAGS")
        block = unquote(Macro.escape(block))

        unless unquote(Macro.escape(gg)) == [] do
          q = {:def, [], [{:when, [], [{unquote(name), [], (quote do: unquote(iargs))}, unquote(Macro.escape(gg))]}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        else
          q = {:def, [], [{unquote(name), [], (quote do: unquote(iargs))}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        end




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
                           {ast, acc}
                       end
                     )


        iargs = [{:=, [], [{:nsm, [], nil}, qq2]}| unquote(Macro.escape(args))]
                |> Macro.expand(__ENV__)
        #|> IO.inspect(label: "IARAGS")
        block = unquote(Macro.escape(block))

        unless g_pre == [] do
          q = {:def, [], [{:when, [], [{unquote(name), [], (quote do: unquote(iargs))}, g_pre]}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        else
          q = {:def, [], [{unquote(name), [], (quote do: unquote(iargs))}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        end


        #{:def, [], [{:when, [], [{name, [], iargs}, g_pre]}, do: block]}
        #unquote(h)
        #        q = quote do
        #          def unquote(name)(unquote_splicing(iargs)) do
        #            unquote(block)
        #          end
        #        end
        #            |> IO.inspect
        #            |> Macro.expand(__ENV__)

      end



    end
  end


  def merge_nsm_ast(nil, outer), do: outer
  def merge_nsm_ast(inner, nil), do: inner
  def merge_nsm_ast(match, match), do: match
  def merge_nsm_ast(inner, outer) do
    # Check if inner has a catch all assignment, if so replace
    # Check if outer has a catch all assignment, if so replace
    case [inner, outer] do
      [{:=, inner_m, [inner_lhs, inner_rhs]}, {:=, outer_m, [outer_lhs, outer_rhs]}] ->
        m = Keyword.merge(inner_m, outer_m)
        Enum.uniq([inner_lhs, inner_rhs, outer_lhs, outer_rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> {:_, [], nil}
             [a] -> a
             [a,b] -> {:=, m, [a,b]}
             [a,b,c] -> {:=, m, [a,{:=, m, [b,c]}]}
             [_,_,_,_] -> {:=, [], [inner, outer]}
           end
      [check = {:=, m, [lhs, rhs]}, keep] ->
        Enum.uniq([lhs, rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> keep
             [a] -> {:=, m, [a, keep]}
             [_,_] -> {:=, [], [check, keep]}
           end
      [keep, check = {:=, m, [lhs, rhs]}] ->
        Enum.uniq([lhs, rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> keep
             [a] -> {:=, m, [a, keep]}
             [_,_] -> {:=, [], [keep, check]}
           end
      _ ->
        {:=, [], [inner, outer]}
    end
  end

  def merge_nsm([[]], outer) do
    outer
  end
  def merge_nsm([], outer) do
    outer
  end
  def merge_nsm(inner, [[]]) do
    inner
  end
  def merge_nsm(inner, []) do
    inner
  end
  def merge_nsm([inner], [outer]) do
    inner_keys = List.flatten(inner) |> Enum.map(fn
      ({key, _}) when is_atom(key) -> key
      _ -> nil
    end) |> Enum.reject(&is_nil/1)
    outer_keys = List.flatten(outer) |> Enum.map(fn
      ({key, _}) when is_atom(key) -> key
      _ -> nil
    end) |> Enum.reject(&is_nil/1)
    keys = (inner_keys ++ outer_keys)
           |> Enum.uniq()
           #|> IO.inspect(label: "MERGE KEYS")
    merged = Enum.map(keys, & {&1, merge_nsm_ast(inner[&1], outer[&1])})
            # |> IO.inspect(label: "MERGED ")
    [merged]
  end

  def combine_attributes() do
    qq = quote do
      {:nsm, [], []}
    end
    quote do
      (Module.get_attribute(__MODULE__, :__sm_withargs, [])
      |> Macro.postwalk(nil,
           fn
             (ast = {:nsm, m, args}, nil) ->
               {ast, args}
             ({:nsm, m, args}, acc) ->
               #args |> IO.inspect(label: "INNER AST")
               #acc |> IO.inspect(label: "OUTER AST")
               args = merge_nsm(args, acc)
               {{:nsm, m, args}, args} #|> IO.inspect(label: Merged)
             (ast, acc) ->
               #IO.inspect(ast)
               {ast, acc}
           end
         )
      |> elem(0)
       #|> IO.inspect(label: "args1")
      |> List.last()
       #|> IO.inspect(label: "args2")
       ) || [unquote(qq)]
    end
  end




  defmacro defsm({:when, _, [{:state_behaviour, meta, args} = signature | guards]}, do: body) do
    # Disallow default args
    # Replace global_state, local_state with nsm__internal_global nsm__internal_local
    {p_args, f} =
      cond do
        args == [] || args == nil ->
          m = meta
          nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, [{:local, m, nil}, {:_, m, nil}]}]
          {[{:nsm, meta, [nargs]}], :set}
        length(args) == 1 ->
          Macro.postwalk(args || [], nil,
            fn
              (ast = {:nsm, m, [nargs]}, acc) when is_list(nargs) ->
                m = Keyword.delete(m, :line)
                gi = Enum.find_index(nargs, &(elem(&1, 0) == :global))
                nargs = case gi do
                  nil -> nargs ++ [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:global, v}) ->
                               {:global, {:=, m, [{:global, m, nil}, v]}}
                             end
                           )
                end
                li = Enum.find_index(nargs, &(elem(&1, 0) == :local))
                nargs = case li do
                  nil -> nargs ++ [local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:local, v}) ->
                               {:local, {:=, m, [{:local, m, nil}, v]}}
                             end
                           )
                end
                {{:nsm, m, [nargs]}, :updated}

              (ast = {:nsm, m, []}, acc) ->
                m = Keyword.delete(m, :line)
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              (ast = {:nsm, m, nil}, acc) ->
                m = Keyword.delete(m, :line)
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              ({type, m, args}, acc) ->
                m = Keyword.delete(m, :line)
                {{type, m, args}, acc}
              (ast, acc) -> {ast, acc}
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
      @__sm_withguards [unquote(guards) | g] |> IO.inspect(label: "ON ENTER")
      unquote(body)
      @__sm_withguards Enum.slice(@__sm_withguards, 1..-1) |> IO.inspect(label: "ON EXIT")
      @__sm_withargs Enum.slice(@__sm_withargs, 1..-1)
    end
  end

  defmacro defsm({:when, wm, [{name, meta, args} = signature | guards]}, do: block) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args} with guards"
    prefix_arg_old =
      quote do
        Module.get_attribute(__MODULE__, :__sm_withargs, [])
        |> List.first()
      end
    prefix_arg = combine_attributes()
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
    end
  end

  defmacro defsm({name, meta, args} = signature, do: block) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args}"
    prefix_arg_old =
      quote do
        Module.get_attribute(__MODULE__, :__sm_withargs, [])
        |> List.first()
      end
    prefix_arg = combine_attributes()
    guards = []
    quote do
      guards = unquote(Macro.escape(guards))
      q = blowitup(
            unquote(name),
            unquote(meta),
            unquote(prefix_arg),
            unquote(args),
            unquote(guards),
            unquote(block)
          ) #|> IO.inspect(label: :inner)
          |> Macro.expand(__ENV__)
          |> Code.compile_quoted()
    end
  end
  defmacro defsm({name, meta, args} = signature) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    with :ok <- check_header(name, args) do
      IO.puts "PUSH def head for #{inspect name}\\#{length args}"
    end
  end


  defmacro for_state({:when, m, [{:~>, meta, [name, signature]} | guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    q = quote do
      defsm state_behaviour(unquote(signature)) when unquote(guards) do
        unquote(body)
      end
    end
  end

  defmacro for_state({:when, m, [{state, meta, args} = signature | guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [:unamed_state, :unamed_state]} | guards]}]
    q = quote do
      defsm state_behaviour(unquote(signature)) when unquote(guards) do
        unquote(body)
      end
    end
  end


  defmacro for_state({:when, m, [name | guards]}, do: body) when is_bitstring(name) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    q = quote do
      defsm state_behaviour() when unquote(guards) do
        unquote(body)
      end
    end
  end


  defmacro for_state({state, meta, args} = signature, do: body) do
    quote do
      defsm state_behaviour(unquote(state)) when :unnamed_state == :unnamed_state do
        unquote(body)
      end
    end
  end

  defmacro for_state(name, {:when, m, [arg_guard|guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    quote do
      defsm state_behaviour(unquote(arg_guard)) when unquote(guards) do
        unquote(body)
      end
    end
  end
  defmacro for_state(name, state, do: body) do
    quote do
      defsm state_behaviour(unquote(state)) when (unquote(name) == unquote(name)) do
        unquote(body)
      end
    end
  end

  defmacro lhs ~> rhs do
    {:~>, [], [lhs, rhs]}
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
