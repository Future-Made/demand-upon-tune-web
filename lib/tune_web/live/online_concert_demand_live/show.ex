defmodule TuneWeb.OnlineConcertDemandLive.Show do
  use TuneWeb, :live_view

  alias Tune.Demands

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:online_concert_demand, Demands.get_online_concert_demand!(id))}
  end

  defp page_title(:show), do: "Show Online concert demand"
  defp page_title(:edit), do: "Edit Online concert demand"
end
