defmodule RestApi.Router do
  alias RestApi.JSONUtils, as: JSON
  # Bring Plug.Router module into scope
  use Plug.Router

  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "OK")
  end

  get "/knockknock" do
    case Mongo.command(:mongo, ping: 1) do
      {:ok, _res} -> send_resp(conn, 200, "Who's there?")
      {:error, _err} -> send_resp(conn, 500, "Somthing went wromng")
    end
  end

  get "/posts" do
    posts =
      Mongo.find(:mongo, "Posts", %{})
      |> Enum.map(&JSON.normaliseMongoId/1)
      |> Enum.to_list()
      |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, posts)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
