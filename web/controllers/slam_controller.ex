defmodule Healthlocker.SlamController do
  use Healthlocker.Web, :controller
  alias Healthlocker.Slam.CarerConnection
  alias Healthlocker.{Carer, Repo, User}

  def new(conn, _param) do
    changeset = CarerConnection.changeset(%CarerConnection{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"carer_connection" => params}) do
    update_params = if params["nhs_number"] do
      params
      |> Map.update!("nhs_number", &(String.split(&1, " ")
      |> List.to_string))
    else
      params
    end

    changeset = CarerConnection.changeset(%CarerConnection{}, update_params)

    name_changeset = User.name_changeset(conn.assigns.current_user, %{first_name: update_params["first_name"], last_name: update_params["last_name"]})

    if changeset.valid? do
      slam_id = Ecto.Changeset.get_field(changeset, :epjs_patient_id)

      query = from u in User, where: u.slam_id == ^slam_id
      service_user = Repo.one(query)

      if service_user do
        with {:ok, _user} <- Repo.update(name_changeset),
             {:ok, _carer} <- Repo.insert(%Carer{carer: conn.assigns.current_user, caring: service_user}) do
               conn
               |> put_flash(:info, "Account connected with SLaM")
               |> redirect(to: account_path(conn, :index))
        else
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Something went wrong")
            |> render("new.html", changeset: changeset)
       end
      end
    else
      conn
      |> put_flash(:error, "Your Healthlocker account could not be linked with your SLaM health record. Please check your details are correct and try again.")
      |> render("new.html", changeset: changeset)
    end
  end
end
