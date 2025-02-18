defmodule TuneWeb.ExplorerLive do
  @moduledoc """
  Main view used in the application. Covers:

  - Search
  - Suggestions
  - Displaying details for artists, albums, etc.
  - Mini player

  ## Mounting and authentication

  When mounting, `TuneWeb.ExplorerLive` uses the session data to start a
  Spotify session. Note that we use a private function `spotify_session/0` to load the appropriate
  behaviour (for example in tests we use a mock).

  `mount/3` always loads user profile data, player status and currently available
  devices, as such information is always displayed irrespectively of the section.

  When connected, `mount/3` also subscribes to session event for the relevant session id.

  ## Routing

  Depending on the route, `handle_params/3` dispatches to different internal functions which
  take care of loading additional data specific for each section.

  ## Events

  Events generated by subscriptions are handled in `handle_info/2` and
  primarily take care of updating the socket assigns. When appropriate, changes
  are forwarded to the progress bar so that it gets updated. This mechanism ensures that:

  - when the same song plays and only elapsed time changes, only the progress bar is re-rendered
  - when the song changes or is played/paused, we also re-render other parts of
    the UI (e.g. if the currently playing song is visualized in its album's
    tracklist)

  Events generated by the UI are all handled via `handle_event/3`.
  """

  use TuneWeb, :live_view

  alias Tune.Spotify.Schema.{Album, Player, Track, User}

  alias TuneWeb.{
    AlbumView,
    ArtistView,
    MiniPlayerComponent,
    PaginationView,
    ProgressBarComponent,
    SearchView,
    ShowView,
    SuggestionsView
  }

  @default_time_range "short_term"

  @initial_state [
    q: nil,
    type: :track,
    results: %{items: [], total: 0},
    user: nil,
    now_playing: %Player{},
    item: :not_fetched,
    artist_albums_group: :all,
    per_page: 8,
    page: 1,
    suggestions_playlist: :not_fetched,
    suggestions_recently_played_albums: :not_fetched,
    suggestions_top_albums: :not_fetched,
    suggestions_top_albums_time_range: @default_time_range,
    suggestions_recommended_tracks: :not_fetched,
    suggestions_recommended_tracks_time_range: @default_time_range
  ]

  @impl true
  def mount(_params, session, socket) do
    case Tune.Auth.load_user(session) do
      {:authenticated, session_id, user} ->
        now_playing = spotify_session().now_playing(session_id)

        # artists = now_playing.item.artists |> Enum.uniq()

        # Enum.map(artists, fn artist -> IO.inspect(artist.name) end)

        devices = spotify_session().get_devices(session_id)

        socket =
          case spotify_session().get_player_token(session_id) do
            {:ok, token} ->
              assign(socket, :player_token, token)

            error ->
              handle_spotify_session_result(error, socket)
          end

        if connected?(socket) do
          spotify_session().subscribe(session_id)
        end


        {:ok,
         socket
         |> assign(@initial_state)
         |> assign(:static_changed, static_changed?(socket))
         |> assign_new(:player_id, &generate_player_id/0)
         |> assign(
           session_id: session_id,
           user: user,
           premium?: User.premium?(user),
           now_playing: now_playing,
           devices: devices
         )}



      _error ->
        {:ok, redirect(socket, to: "/auth/logout")}
    end
  end

  @impl true
  def handle_params(params, url, socket) do
    case socket.assigns.live_action do
      :suggestions -> handle_suggestions(params, url, socket)
      :search -> handle_search(params, url, socket)
      :artist_details -> handle_artist_details(params, url, socket)
      :album_details -> handle_album_details(params, url, socket)
      :show_details -> handle_show_details(params, url, socket)
      :episode_details -> handle_episode_details(params, url, socket)
    end
  end

  @impl true
  def handle_event("toggle_play_pause", %{"key" => " "}, socket) do
    spotify_session().toggle_play(socket.assigns.session_id)

    {:noreply, socket}
  end

  def handle_event("toggle_play_pause", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_play_pause", _params, socket) do
    socket.assigns.session_id
    |> spotify_session().toggle_play()
    |> handle_spotify_session_result(socket)
  end

  def handle_event("play", %{"uri" => uri, "context-uri" => context_uri}, socket) do
    socket.assigns.session_id
    |> spotify_session().play(uri, context_uri)
    |> handle_spotify_session_result(socket)
  end

  def handle_event("play", %{"uri" => uri}, socket) do
    socket.assigns.session_id
    |> spotify_session().play(uri)
    |> handle_spotify_session_result(socket)
  end

  def handle_event("next", _params, socket) do
    socket.assigns.session_id
    |> spotify_session().next()
    |> handle_spotify_session_result(socket)
  end

  def handle_event("prev", _params, socket) do
    socket.assigns.session_id
    |> spotify_session().prev()
    |> handle_spotify_session_result(socket)
  end

  def handle_event("seek", %{"position_ms" => position_ms}, socket) do
    socket.assigns.session_id
    |> spotify_session().seek(position_ms)
    |> handle_spotify_session_result(socket)
  end

  def handle_event("search", params, socket) do
    q = Map.get(params, "q")
    type = Map.get(params, "type", "track")

    {:noreply, push_patch(socket, to: Routes.explorer_path(socket, :search, q: q, type: type))}
  end

  def handle_event("set_top_albums_time_range", %{"time-range" => time_range}, socket) do
    case get_top_tracks(socket.assigns.session_id, time_range) do
      {:ok, top_tracks} ->
        {:noreply,
         assign(socket,
           suggestions_top_albums: Album.from_tracks(top_tracks),
           suggestions_top_albums_time_range: time_range
         )}

      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  def handle_event("set_recommended_tracks_time_range", %{"time-range" => time_range}, socket) do
    with {:ok, top_tracks} <- get_top_tracks(socket.assigns.session_id, time_range),
         {:ok, recommended_tracks} <- get_recommendations(socket.assigns.session_id, top_tracks) do
      {:noreply,
       assign(socket,
         suggestions_recommended_tracks: recommended_tracks,
         suggestions_recommended_tracks_time_range: time_range
       )}
    else
      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  def handle_event("transfer_playback", %{"device" => device_id}, socket) do
    case spotify_session().transfer_playback(socket.assigns.session_id, device_id) do
      :ok ->
        {:noreply, socket}

      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  def handle_event("inc_volume", %{}, socket) do
    case socket.assigns.now_playing.device do
      nil ->
        {:noreply, socket}

      device ->
        volume_percent = min(device.volume_percent + 10, 100)
        set_volume(volume_percent, socket)
    end
  end

  def handle_event("dec_volume", %{}, socket) do
    case socket.assigns.now_playing.device do
      nil ->
        {:noreply, socket}

      device ->
        volume_percent = max(device.volume_percent - 10, 0)
        set_volume(volume_percent, socket)
    end
  end

  def handle_event("set_volume", %{"volume_percent" => volume_percent}, socket) do
    set_volume(volume_percent, socket)
  end

  def handle_event("refresh_devices", _params, socket) do
    :ok = spotify_session().refresh_devices(socket.assigns.session_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:now_playing, player}, socket) do
    changes = Player.changes(socket.assigns.now_playing, player)

    cond do
      changes == [] ->
        {:noreply, socket}

      [:progress_ms] == changes ->
        send_update(ProgressBarComponent, id: :progress_bar, progress_ms: player.progress_ms)
        {:noreply, socket}

      :item in changes ->
        case spotify_session().recently_played_tracks(socket.assigns.session_id, limit: 50) do
          {:ok, recently_played_tracks} ->
            {:noreply,
             assign(socket,
               suggestions_recently_played_albums: Album.from_tracks(recently_played_tracks),
               now_playing: player
             )}

          error ->
            handle_spotify_session_result(error, socket)
        end

      true ->
        {:noreply, assign(socket, :now_playing, player)}
    end
  end

  def handle_info({:player_token, token}, socket) do
    {:noreply, assign(socket, :player_token, token)}
  end

  def handle_info({:devices, devices}, socket) do
    {:noreply, assign(socket, :devices, devices)}
  end

  defp spotify_session, do: Application.get_env(:tune, :spotify_session)

  defp handle_suggestions(_params, _url, socket) do
    socket = assign(socket, :page_title, gettext("Future, Made"))

    with {:ok, playlist} <- get_suggestions_playlist(socket.assigns.session_id),
         {:ok, top_tracks} <-
           get_top_tracks(
             socket.assigns.session_id,
             socket.assigns.suggestions_top_albums_time_range
           ),
         {:ok, recently_played_tracks} <-
           spotify_session().recently_played_tracks(socket.assigns.session_id, limit: 50),
         {:ok, recommended_tracks} <-
           get_recommendations(socket.assigns.session_id, top_tracks) do
      {:noreply,
       assign(socket,
         suggestions_playlist: playlist,
         suggestions_top_albums: Album.from_tracks(top_tracks),
         suggestions_recegently_played_albums: Album.from_tracks(recently_played_tracks),
         suggestions_recommended_tracks: recommended_tracks
       )}
    else
      {:error, :not_present} ->
        {:noreply, assign(socket, :suggestions_playlist, :not_present)}

      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  defp handle_search(params, _url, socket) do
    q = Map.get(params, "q", "")
    type = Map.get(params, "type", "track")
    page = Map.get(params, "page", "1")
    per_page = Map.get(params, "per_page", "24")
    socket = assign(socket, :page_title, gettext("Search results"))

    if String.length(q) >= 1 do
      type = parse_type(type)
      page = String.to_integer(page)
      limit = String.to_integer(per_page)
      offset = max(page - 1, 0) * limit

      socket =
        socket
        |> assign(:q, q)
        |> assign(:type, type)
        |> assign(:page, page)
        |> assign(:per_page, limit)
        |> assign(:page_title, gettext("Search results for %{q}", %{q: q}))

      search_opts = [types: [type], limit: limit, offset: offset]

      case spotify_session().search(socket.assigns.session_id, q, search_opts) do
        {:ok, results} ->
          {:noreply, assign(socket, :results, Map.get(results, type))}

        error ->
          handle_spotify_session_result(error, socket)
      end
    else
      {:noreply,
       socket
       |> assign(:q, nil)
       |> assign(:type, type)
       |> assign(:results, %{items: [], total: 0})}
    end
  end

  defp handle_artist_details(%{"artist_id" => artist_id} = params, _url, socket) do
    album_group =
      params
      |> Map.get("album_group", "all")
      |> parse_album_group()

    page =
      params
      |> Map.get("page", "1")
      |> String.to_integer()

    limit =
      params
      |> Map.get("per_page", "24")
      |> String.to_integer()

    offset = max(page - 1, 0) * limit

    socket = assign(socket, :page_title, gettext("Artist details"))

    with {:ok, artist} <- spotify_session().get_artist(socket.assigns.session_id, artist_id),
         {:ok, %{albums: albums, total: total_albums}} <-
           spotify_session().get_artist_albums(socket.assigns.session_id, artist_id,
             limit: limit,
             offset: offset,
             album_group: album_group
           ) do
      artist = %{artist | albums: albums, total_albums: total_albums}

      {:noreply,
       assign(socket, %{
         item: artist,
         artist_albums_group: album_group,
         page: page,
         per_page: limit,
         page_title: gettext("Artist details for %{name}", %{name: artist.name})
       })}
    else
      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  defp handle_album_details(%{"album_id" => album_id}, _url, socket) do
    socket = assign(socket, :page_title, gettext("Album details"))

    case spotify_session().get_album(socket.assigns.session_id, album_id) do
      {:ok, album} ->
        {:noreply,
         assign(socket,
           item: album,
           page_title: gettext("Album details for %{name}", %{name: album.name})
         )}

      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  defp handle_show_details(%{"show_id" => show_id}, _url, socket) do
    socket = assign(socket, :page_title, gettext("Show details"))

    with {:ok, show} <- spotify_session().get_show(socket.assigns.session_id, show_id),
         {:ok, episodes} <- spotify_session().get_episodes(socket.assigns.session_id, show_id) do
      show = %{show | episodes: episodes}

      {:noreply,
       assign(socket,
         item: show,
         page_title: gettext("Show details for %{name}", %{name: show.name})
       )}
    else
      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  defp handle_episode_details(_params, _url, socket) do
    socket = assign(socket, :page_title, gettext("Episode details"))
    {:noreply, socket}
  end

  defp parse_type("track"), do: :track
  defp parse_type("album"), do: :album
  defp parse_type("artist"), do: :artist
  defp parse_type("episode"), do: :episode
  defp parse_type("show"), do: :show

  defp parse_album_group("all"), do: :all
  defp parse_album_group("album"), do: :album
  defp parse_album_group("single"), do: :single
  defp parse_album_group("appears_on"), do: :appears_on
  defp parse_album_group("compilation"), do: :compilation

  defp handle_spotify_session_result(:ok, socket), do: {:noreply, socket}

  defp handle_spotify_session_result({:error, 404}, socket) do
    {:noreply, put_flash(socket, :error, gettext("No available devices"))}
  end

  defp handle_spotify_session_result({:error, reason}, socket) do
    error_message_part_1 = gettext("If connected Spotify account is non-premium, can't play/listen/control playback. This is how we have empathic moments with our hearing-impaired fellows. Each of us have some privileges that are not easy to share.", %{reason: inspect(reason)})
    error_message_part_2 = gettext("It just syncs quite well. And hey, as is, this is a platform intended to demand performances, you'll feel them eventually, in the future, that's our promise. ;)", %{reason: inspect(reason)})

    # TODO:// put them in diff paragraphs
    {:noreply, put_flash(socket, :info, error_message_part_1 <> error_message_part_2)}

  end

  @suggestions_playlist_name "Release Radar"
  defp get_suggestions_playlist(session_id) do
    with {:ok, results} <-
           spotify_session().search(session_id, @suggestions_playlist_name,
             types: [:playlist],
             limit: 1
           ),
         simplified_playlist when is_struct(simplified_playlist) <-
           get_in(results, [:playlists, :items, Access.at(0)]) do
      spotify_session().get_playlist(session_id, simplified_playlist.id)
    else
      nil -> {:error, :not_present}
      error -> error
    end
  end

  @top_tracks_limit 16

  defp get_top_tracks(session_id, time_range) do
    opts = [limit: @top_tracks_limit, time_range: time_range]
    spotify_session().top_tracks(session_id, opts)
  end

  defp get_recommendations(session_id, tracks) do
    artist_ids =
      tracks
      |> Track.artist_ids()
      |> Enum.shuffle()
      |> Enum.take(5)

    spotify_session().get_recommendations_from_artists(session_id, artist_ids)
  end

  defp set_volume(volume_percent, socket) do
    case spotify_session().set_volume(socket.assigns.session_id, volume_percent) do
      :ok ->
        {:noreply, socket}

      error ->
        handle_spotify_session_result(error, socket)
    end
  end

  defp generate_player_id do
    "tune-" <> Tune.PlayerName.random_slug()
  end
end
