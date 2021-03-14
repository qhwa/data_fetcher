defmodule DataFetcher do
  @moduledoc """
  An abstraction on periodic data fetching jobs.

  ## Usage

  ```elixir
  defmodule MyFetcher do
    use DataFetcher, interval: :timer.minutes(10)

    @impl DataFetcher
    def fetch(_), do: fetch_my_data_from_remote_server()
  end
  ```

  In the above exmple, we define a data fetcher, which will call
  `fetch_my_data_from_remote_server/0` every ten minutes.

  The fetched data can be accessed with:

  ```elixir
  MyFetcher.data!()
  ```
  """
  defmacro __using__(opts) do
    quote location: :keep do
      use GenServer
      require Logger

      @name unquote(Keyword.get(opts, :name)) || __MODULE__
      @reg Module.concat(DataFetcher.WorkersRegistry, @name)
      @supervisor DataFetcher.WorkersSupervisor.dynamic_sup_name(name: @name)

      @default_interval unquote(Keyword.get(opts, :interval, :timer.seconds(7_200)))

      @behaviour unquote(__MODULE__)

      @impl true
      def init(opts) do
        {:ok, get_context(opts), {:continue, :fetch_data}}
      end

      defp get_context(opts) do
        default_ctx = %{retries: 0, data: nil, parent: opts[:parent], name: opts[:name]}

        Keyword.get(
          opts,
          :context,
          default_ctx
        )
        |> Map.put(:pid, self())
      end

      defp data! do
        [{_, data} | _] = :ets.lookup(ets_table(), reg_name())
        data
      end

      defp reg_name,
        do: @name

      def child_spec(opts),
        do:
          opts
          |> Keyword.put(:mfa, starting_mfa())
          |> Keyword.put_new(:name, @name)
          |> DataFetcher.Supervisor.child_spec()
          |> Map.put(:id, @name)

      defp starting_mfa(opts \\ []),
        do: {
          GenServer,
          :start_link,
          [__MODULE__, opts]
        }

      @impl true
      def handle_continue(:fetch_data, context) do
        case __MODULE__.fetch(context) do
          {:ok, data} ->
            handle_success(data, context)

          err ->
            handle_failure(err, context)
        end
      end

      defp handle_success(data, context) do
        case __MODULE__.success(data, context) do
          :ok ->
            save(data, reset_context(context))

          {:ok, new_context} ->
            save(data, reset_context(new_context))

          other ->
            raise "`on_success/1` callback if returning invalid value: #{inspect(other)}. Only `:skip` or `:stop` (default) are supported."
        end
      end

      defp reset_context(context),
        do: Map.put(context, :retries, 0)

      defp save(data, context) do
        :ets.insert(ets_table(), {reg_name(), data})

        Process.send_after(self(), :refresh, __MODULE__.interval(context))
        {:noreply, context, {:continue, :maybe_terminate_parent}}
      end

      defp handle_failure(err, context) do
        case __MODULE__.error(err, context) do
          :retry ->
            {:stop, context, :retry}

          :ignore ->
            {:stop, context, :normal}

          :stop ->
            {:stop, context, :normal}
        end
      end

      def handle_continue(:maybe_terminate_parent, context) do
        case context.parent do
          parent when is_pid(parent) ->
            {:noreply, context, {:continue, {:terminate_parent, parent}}}

          _ ->
            {:noreply, context}
        end
      end

      def handle_continue({:terminate_parent, parent}, state) do
        send(parent, :stop)

        {:noreply, state}
      end

      @impl true
      def handle_info(:refresh, context) do
        DynamicSupervisor.start_child(
          @supervisor,
          %{
            id: {DataFetcher, :rand.uniform()},
            start: starting_mfa(parent: self(), context: context)
          }
        )

        {:noreply, context}
      end

      def handle_info(:stop, state) do
        DynamicSupervisor.terminate_child(@supervisor, self())

        {:noreply, state}
      end

      @impl unquote(__MODULE__)
      def interval(_), do: @default_interval

      @impl unquote(__MODULE__)
      def success(_data, _context), do: :ok

      @impl unquote(__MODULE__)
      def error(_error, _context), do: :stop

      defoverridable success: 2, error: 2, interval: 1

      defp ets_table, do: :ets.new(@reg, [:set, :protected])
    end
  end

  @type context :: %{retries: non_neg_integer, pid: pid, parent: pid | nil}

  @callback interval(context) :: non_neg_integer
  @callback fetch(context) :: {:ok, term} | {:error, term}
  @callback success(data :: term, context) :: :ok | {:ok, context} | {:error, term}
  @callback error(error_term :: {:error, term}, context) :: :retry | :ignore
end
