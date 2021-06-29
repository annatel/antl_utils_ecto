{:ok, _pid} = AntlUtilsEcto.TestRepo.start_link()
{:ok, _pid} = AntlUtilsEcto.PaginatorRepo.start_link()

ExUnit.start()
