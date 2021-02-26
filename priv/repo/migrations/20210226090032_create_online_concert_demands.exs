defmodule Tune.Repo.Migrations.CreateOnlineConcertDemands do
  use Ecto.Migration

  def change do
    create table(:online_concert_demands) do
      add :willing_to_pay_min, :integer
      add :willing_to_pay_max, :integer
      add :have_slow_internet, :boolean, default: false, null: false
      add :will_support_causes, {:array, :string}
      add :charitable_percentage, :integer
      add :demand_as_multipass, :boolean, default: false, null: false
      add :demand_on_air_months, :integer
      add :requested_songs, {:array, :string}
      add :note_to_artist, :string
      add :can_offer_help, :boolean, default: false, null: false
      add :artist_id, :string

      timestamps()
    end

    alter table(:online_concert_demands) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:online_concert_demands, [:user_id])

  end
end
