defmodule ShareCircleWeb.FamilySetupLive do
  @moduledoc """
  Shown to authenticated users who have no family context.
  Lets them create a new family or pick from families they already belong to.
  """

  use ShareCircleWeb, :live_view

  alias ShareCircle.Families

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    memberships = Families.list_families_for_user(scope)

    {:ok,
     socket
     |> assign(:memberships, memberships)
     |> assign(:tab, if(memberships == [], do: :create, else: :pick))
     |> assign(:form, to_form(%{"name" => "", "slug" => "", "timezone" => "UTC"}, as: "family"))}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_existing_atom(tab))}
  end

  def handle_event("create_family", %{"family" => params}, socket) do
    case Families.create_family(socket.assigns.current_scope, params) do
      {:ok, {family, _membership}} ->
        {:noreply, push_navigate(socket, to: ~p"/families/#{family.id}/feed")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: "family"))}
    end
  end

  def handle_event("select_family", %{"id" => family_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/families/#{family_id}/feed")}
  end
end
