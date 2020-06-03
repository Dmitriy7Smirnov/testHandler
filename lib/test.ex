defmodule Test do
    use GenServer

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    @impl true
    def init(state) do
        start_tests()
        {:ok, state}
    end

    def start_tests do
        {:ok, functions_list} = File.read("functions")
        fun_map = ExJSON.parse(functions_list, :to_map)
        {:ok, datasets_list} = File.read("datasets")
        datasets_map = ExJSON.parse(datasets_list, :to_map)
        fun_list = Map.keys(fun_map)
        IO.puts("")
        List.foldl(fun_list, 0, fn fun_name, _acc ->
                params = fun_map[fun_name]["params"]
                fun_module = fun_map[fun_name]["module"]
                test_all_cases(fun_module, fun_name, List.foldl(Map.keys(params), [], fn key, acc -> [datasets_map[params[key]] | acc] end), [])
                IO.puts("")
            end);
    end

    defp test_all_cases(fun_module, fun_name, p_lists, args) do
        case length(p_lists) == 1 do
            true ->
                List.foldl(List.first(p_lists),
                    0,
                    fn x, _acc ->
                        params = [x | args]
                        result = apply(String.to_atom("Elixir." <> fun_module), String.to_atom(fun_name), params)
                        IO.puts("#{fun_module}.#{fun_name} params = #{Enum.join(params, " ")}; result = #{result}")
                    end
                );
            false -> List.foldl(List.first(p_lists), 0, fn x, _acc -> test_all_cases(fun_module, fun_name, List.delete_at(p_lists, 0), [x | args]) end)
        end
    end

    def add2(x, y) do
        x + y
    end

    def add3(x, y, z) do
        x + y + z
    end
end
