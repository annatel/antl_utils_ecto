Application.put_env(:ecto, AntlUtilsEcto.TestRepo, user: "invalid")

defmodule AntlUtilsEcto.TestRepo do
  use Ecto.Repo, otp_app: :ecto, adapter: Ecto.TestAdapter

  use AntlUtilsEcto.Repo, repo: AntlUtilsEcto.TestRepo

  def init(type, opts) do
    opts = [url: "ecto://user:pass@local/hello"] ++ opts
    opts[:parent] && send(opts[:parent], {__MODULE__, type, opts})
    {:ok, opts}
  end
end
