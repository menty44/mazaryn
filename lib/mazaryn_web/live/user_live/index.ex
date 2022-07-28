defmodule MazarynWeb.UserLive.Index do
  use MazarynWeb, :live_view

  import MazarynWeb.Live.Helper
  import Logger
  alias Core.UserClient, as: UserClient
  alias Account.Users
  alias Home.Post

  @impl true
  def mount(_params, %{"user_id" => email} = _session, socket) do
    post_changeset = Post.changeset(%Post{})
    Logger.info(socket: socket.assigns)

    socket =
      socket
      |> assign(user_id: email)
      |> assign(post_changeset: post_changeset)
      |> assign(user: user_info(email))

    {:ok, socket}
  end

  @impl true
  def mount(_params, %{"session_uuid" => session_uuid} = _session, socket) do
    post_changeset = Post.changeset(%Post{})
    email = get_user_id(session_uuid)
    Logger.info(socket: socket.assigns)

    socket =
      socket
      |> assign(user_id: email)
      |> assign(post_changeset: post_changeset)
      |> assign(user: user_info(email))

    {:ok, socket}
  end

  defp user_info(email) do
    Users.one_by_email(email)
  end

  @impl true
  def handle_event("follow_user", %{"username" => username}, socket) do
    username = UserClient.getting_user(username)
    UserClient.follow(socket.assigns.user, username)

    {:noreply, assign(socket, :follow, username)}
  end

  @impl true
  def handle_event("unfollow_user", %{"username" => username}, socket) do
    username = UserClient.getting_user(username)
    UserClient.unfollow(socket.assigns.user, username)

    {:noreply, assign(socket, :unfollow, username)}
  end

  def handle_event("block_user", %{"username" => username}, socket) do
    username = UserClient.getting_user(username)
    UserClient.block(socket.assigns.user, username)

    {:noreply, assign(socket, :block, username)}
  end

  def handle_event("unblock_user", %{"username" => username}, socket) do
    username = UserClient.getting_user(username)
    UserClient.unblock(socket.assigns.user, username)

    {:noreply, assign(socket, :unblock, username)}
  end

  def handle_event("delete_user", %{"username" => username}, socket) do
    username = UserClient.getting_user(username)
    UserClient.delete_user(username)

    {:noreply, assign(socket, :delete, username)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    # Logger.info(socket: socket.assigns)
    {:noreply, socket}
  end
end
