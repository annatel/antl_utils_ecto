defmodule AntlUtilsEcto.PaginatorRepo do
  use Ecto.Repo, otp_app: :antl_utils_ecto, adapter: AntlUtilsEcto.TestAdapter

  use AntlUtilsEcto.Repo

  def init(type, opts) do
    opts = [url: "ecto://user:pass@local/hello"] ++ opts
    opts[:parent] && send(opts[:parent], {__MODULE__, type, opts})
    {:ok, opts}
  end
end
