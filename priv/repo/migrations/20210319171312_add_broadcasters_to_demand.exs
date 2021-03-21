defmodule Tune.Repo.Migrations.AddBroadcastersToDemand do
  use Ecto.Migration

  # add actually broadcasters to existing platforms
  # and those platforms need to be streaming platforms,
  # instead broadcasters on the sys
  def change do
    alter table(:online_concert_demands) do
      add :streaming_platforms, {:array, :string}

      # also let user extend it with suggesting others, for both via text input.

      add :suggested_streaming_platforms, :string
      add :suggested_radios, :string

    end

    create index(:online_concert_demands, [:artist_id, ])

  end
end
