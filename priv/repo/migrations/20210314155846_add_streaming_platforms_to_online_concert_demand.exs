defmodule Tune.Repo.Migrations.AddStreamingPlatformsToOnlineConcertDemand do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do
      add :preferred_broadcasters, {:array, :string}

    end
  end
end
