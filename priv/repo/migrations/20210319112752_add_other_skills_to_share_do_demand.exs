defmodule Tune.Repo.Migrations.AddOtherSkillsToShareDoDemand do
  use Ecto.Migration

  def change do
    alter table(:online_concert_demands) do
      add :other_skills_offered, :string
    end
  end
end
