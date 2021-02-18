defmodule TuneWeb.OnlineConcertDemandLive.Index do
  use TuneWeb, :live_view

  alias Tune.Demands
  alias Tune.Demands.OnlineConcertDemand

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :online_concert_demands, list_online_concert_demands())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Online concert demand")
    |> assign(:online_concert_demand, Demands.get_online_concert_demand!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Online concert demand")
    |> assign(:online_concert_demand, %OnlineConcertDemand{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Online concert demands")
    |> assign(:online_concert_demand, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    online_concert_demand = Demands.get_online_concert_demand!(id)
    {:ok, _} = Demands.delete_online_concert_demand(online_concert_demand)

    {:noreply, assign(socket, :online_concert_demands, list_online_concert_demands())}
  end

  defp list_online_concert_demands do
    Demands.list_online_concert_demands()
  end
end
