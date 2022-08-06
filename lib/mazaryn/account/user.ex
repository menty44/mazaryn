defmodule Account.User do
  @moduledoc """
  Embedded schema to represent Account.User
  """
  use Ecto.Schema

  import Ecto.Changeset


  def new_posts(posts) do
    posts
  end

  def new(users) when is_list(users) do
    for user <- users, do: new(user)
  end

  def new(
        {_user, id, username, password, email, media, post, saved_posts, following, follower, blocked,
         other_info, private, date_created, date_updated}
      ) do
    struct(Account.User, %{
      id: id,
      username: username,
      password: password,
      email: email,
      media: media,
      post: post,
      saved_posts: new_posts(saved_posts),
      following: Account.User.new(following),
      follower: Account.User.new(follower),
      blocked: Account.User.new(blocked),
      other_info: other_info,
      private: private,
      date_created: date_created,
      date_updated: date_updated
    })
  end

  embedded_schema do
    field(:username, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:private, :boolean)
    field(:other_info, {:array, :string})
    field(:media, {:array, :string})
    field(:date_created, :utc_datetime)
    field(:date_updated, :utc_datetime)


    # TODO: ADD to mnesia
    field(:avatar_url, :string)
    field(:country, :string)

    has_many(:posts, Mazaryn.Post)
    has_many(:following, Account.User)
    has_many(:follower, Account.User)
    has_many(:blocked, Account.User)
    has_many(:saved_posts, Home.Post)
    has_many(:notifications, Home.Notification)
  end

  @required_attrs [
    :username,
    :email,
    :password
  ]

  def erl_changeset(
        {:user, username, id, password, email, media, posts, following, follower, blocked,
         saved_posts, other_info, private, date_created, date_updated}
      ) do
    %__MODULE__{}
    |> changeset(%{
      username: username,
      id: id,
      password: password,
      email: email,
      media: media,
      posts: posts,
      following: following,
      follower: follower,
      blocked: blocked,
      saved_posts: saved_posts,
      other_info: other_info,
      private: private,
      date_created: date_created,
      date_updated: date_updated
    })
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password,
      min: 8,
      max: 20,
      message: "Password must be between 8 and 20 characters"
    )
    |> create_password_hash()
  end

  def create_password_hash(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def create_password_hash(%Ecto.Changeset{} = changeset) do
    password_hash =
      changeset
      |> Ecto.Changeset.get_field(:password)
      |> :erlpass.hash()

    changeset
    |> Ecto.Changeset.put_change(:password, password_hash)
  end
end
