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
        {:ok, list_content} = File.read("items")
        fun_map = ExJSON.parse(list_content, :to_map)
        fun_list = Map.keys(fun_map)
        IO.puts("")
        List.foldl(fun_list, 0, fn fun_name, _acc ->
                params = fun_map[fun_name]
                test_all_cases(fun_name, List.foldl(Map.keys(params), [], fn key, acc -> [params[key] | acc] end), [])
                IO.puts("")
            end);
    end

    defp test_all_cases(fun_name, p_lists, args) do
        case length(p_lists) == 1 do
            true -> List.foldl(List.first(p_lists), 0, fn x, _acc -> apply(__MODULE__, String.to_atom(fun_name), [x | args]) end);
            false -> List.foldl(List.first(p_lists), 0, fn x, _acc -> test_all_cases(fun_name, List.delete_at(p_lists, 0), [x | args]) end)
        end
    end

    def add2(x, y) do
        IO.puts("fun add/2: #{x} + #{y} = #{x + y}")
    end

    def add3(x, y, z) do
        IO.puts("fun add/3: #{x} + #{y} + #{z} = #{x + y + z}")
    end
end
