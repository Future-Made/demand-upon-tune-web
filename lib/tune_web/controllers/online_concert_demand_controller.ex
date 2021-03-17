defmodule TuneWeb.OnlineConcertDemandController do
  use TuneWeb, :controller

  alias Tune.Demands
  alias Tune.Demands.OnlineConcertDemand
  alias Tune.Spotify.Schema.{Episode, Track}


  def index(conn, _params) do
    conn.assigns.user.avatar_url
    spotify_username = conn.assigns.user.name
    online_concert_demands = Demands.list_online_concert_demands(spotify_username)
    render(conn, "index.html", online_concert_demands: online_concert_demands)
  end

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, params) do

    artist_id = conn.query_params["artist_id"]
    artist_name = conn.query_params["artist_name"]
    artist_thumbnails = conn |> thumbnails_to_array()

    IO.inspect(Enum.at(artist_thumbnails, 0))

    changeset = Demands.change_online_concert_demand(
      %OnlineConcertDemand{artist_id: artist_id,
      artist_name: artist_name,
      artist_thumbnail_small: Enum.at(artist_thumbnails, 0),
      artist_thumbnail_medium: Enum.at(artist_thumbnails, 1),
      artist_thumbnail_large: Enum.at(artist_thumbnails, 2)
      })


    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"online_concert_demand" => online_concert_demand_params}) do
    # add spotify username to demand.

    artist_thumbnails = conn |> thumbnails_to_array()


    online_concert_demand_params =
      online_concert_demand_params
      |> Map.put("user_id", conn.assigns.user.name)
      |> Map.put("spotify_profile_img_url", conn.assigns.user.avatar_url)
      # |> Map.put("artist_thumbnails", conn.query_params["artist_thumbnails"])
      |> Map.put("artist_thumbnail_small", Enum.at(artist_thumbnails, 0))
      |> Map.put("artist_thumbnail_medium", Enum.at(artist_thumbnails, 1))
      |> Map.put("artist_thumbnail_large", Enum.at(artist_thumbnails, 2))


    case Demands.create_online_concert_demand(online_concert_demand_params) do
      {:ok, online_concert_demand} ->
        conn
        |> put_flash(:info, "well, now your demand is literally on-air!")
        |> redirect(to: Routes.online_concert_demand_path(conn, :show, online_concert_demand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    online_concert_demand = Demands.get_online_concert_demand!(id)
    render(conn, "show.html", online_concert_demand: online_concert_demand)
  end

  def edit(conn, %{"id" => id}) do
    online_concert_demand = Demands.get_online_concert_demand!(id)
    changeset = Demands.change_online_concert_demand(online_concert_demand)
    render(conn, "edit.html", online_concert_demand: online_concert_demand, changeset: changeset)
  end

  def update(conn, %{"id" => id, "online_concert_demand" => online_concert_demand_params}) do
    online_concert_demand = Demands.get_online_concert_demand!(id)

    case Demands.update_online_concert_demand(online_concert_demand, online_concert_demand_params) do
      {:ok, online_concert_demand} ->
        conn
        |> put_flash(:info, "Online concert demand updated successfully.")
        |> redirect(to: Routes.online_concert_demand_path(conn, :show, online_concert_demand))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          online_concert_demand: online_concert_demand,
          changeset: changeset
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    online_concert_demand = Demands.get_online_concert_demand!(id)
    {:ok, _online_concert_demand} = Demands.delete_online_concert_demand(online_concert_demand)

    conn
    |> put_flash(:info, "Online concert demand deleted successfully.")
    |> redirect(to: Routes.online_concert_demand_path(conn, :index))
  end

  defp thumbnails_to_array(conn) do

    [ conn.query_params["artist_thumbnail_small"],
     conn.query_params["artist_thumbnail_medium"],
     conn.query_params["artist_thumbnail_large"]
    ]

  end

end
