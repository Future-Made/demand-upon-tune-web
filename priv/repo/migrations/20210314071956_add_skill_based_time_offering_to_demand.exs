defmodule Tune.Repo.Migrations.AddSkillBasedTimeOfferingToDemand do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do

      add :event_related_helps_offered, {:array, :string}
      add :skills_offered_for_public, {:array, :string}
      add :time_offer_for_skills_in_mins, :integer
    end
  end
end
