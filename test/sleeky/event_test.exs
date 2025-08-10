defmodule Sleeky.EventTest do
  use ExUnit.Case
  doctest Sleeky.Event

  alias Blogs.Accounts.Events.UserRegistered

  describe "Event DSL metadata" do
    test "returns correct version" do
      assert UserRegistered.version() == 1
    end

    test "returns correct feature" do
      assert UserRegistered.feature() == Blogs.Accounts
    end

    test "returns correct name" do
      assert UserRegistered.name() == Blogs.Accounts.Events.UserRegistered
    end

    test "returns field definitions" do
      fields = UserRegistered.fields()

      assert length(fields) == 4

      # Check user_id field
      user_id_field = Enum.find(fields, &(&1.name == :user_id))
      assert user_id_field.type == :id
      assert user_id_field.required == true

      # Check email field
      email_field = Enum.find(fields, &(&1.name == :email))
      assert email_field.type == :string
      assert email_field.required == true

      # Check registered_at field
      registered_at_field = Enum.find(fields, &(&1.name == :registered_at))
      assert registered_at_field.type == :datetime
      assert registered_at_field.required == true

      # Check username field (optional)
      username_field = Enum.find(fields, &(&1.name == :username))
      assert username_field.type == :string
      assert username_field.required == false
    end
  end

  describe "Ecto schema integration" do
    test "generates correct schema fields" do
      fields = UserRegistered.__schema__(:fields)
      assert :user_id in fields
      assert :email in fields
      assert :registered_at in fields
      assert :username in fields
    end

    test "maps datetime type correctly to utc_datetime" do
      assert UserRegistered.__schema__(:type, :registered_at) == :utc_datetime
    end

    test "creates empty struct" do
      empty_struct = struct(UserRegistered)
      assert empty_struct.user_id == nil
      assert empty_struct.email == nil
      assert empty_struct.registered_at == nil
      assert empty_struct.username == nil
    end
  end

  describe "event creation with new/1" do
    test "creates event with valid required data" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      params = %{
        user_id: 123,
        email: "test@example.com",
        registered_at: now
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == 123
      assert event.email == "test@example.com"
      assert event.registered_at == now
      assert event.username == nil
    end

    test "creates event with all fields including optional" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      params = %{
        user_id: 456,
        email: "user@example.com",
        registered_at: now,
        username: "testuser"
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == 456
      assert event.email == "user@example.com"
      assert event.registered_at == now
      assert event.username == "testuser"
    end

    test "accepts string keys in parameters" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      params = %{
        "user_id" => 789,
        "email" => "string@example.com",
        "registered_at" => now
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == 789
      assert event.email == "string@example.com"
      assert event.registered_at == now
    end

    test "handles keyword list parameters" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      params = [
        user_id: 101,
        email: "keyword@example.com",
        registered_at: now
      ]

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == 101
      assert event.email == "keyword@example.com"
      assert event.registered_at == now
    end
  end

  describe "event validation" do
    test "fails when required user_id is missing" do
      params = %{
        email: "test@example.com",
        registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      {:error, changeset} = UserRegistered.new(params)

      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:user_id]
    end

    test "fails when required email is missing" do
      params = %{
        user_id: 123,
        registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      {:error, changeset} = UserRegistered.new(params)

      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:email]
    end

    test "fails when required registered_at is missing" do
      params = %{
        user_id: 123,
        email: "test@example.com"
      }

      {:error, changeset} = UserRegistered.new(params)

      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:registered_at]
    end

    test "fails when multiple required fields are missing" do
      params = %{username: "optional_field"}

      {:error, changeset} = UserRegistered.new(params)

      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:user_id]
      assert {"can't be blank", _} = changeset.errors[:email]
      assert {"can't be blank", _} = changeset.errors[:registered_at]
    end

    test "succeeds when optional fields are missing" do
      params = %{
        user_id: 123,
        email: "test@example.com",
        registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.username == nil
    end

    test "ignores unknown fields" do
      params = %{
        user_id: 123,
        email: "test@example.com",
        registered_at: DateTime.utc_now() |> DateTime.truncate(:second),
        unknown_field: "ignored"
      }

      {:ok, event} = UserRegistered.new(params)

      assert event.user_id == 123
      assert event.email == "test@example.com"
      refute Map.has_key?(event, :unknown_field)
    end
  end

  describe "JSON decoding" do
    test "decodes valid JSON to event struct" do
      json = ~s({
        "user_id": 123,
        "email": "json@example.com",
        "registered_at": "2023-01-01T12:00:00Z"
      })

      {:ok, event} = UserRegistered.decode(json)

      assert event.user_id == 123
      assert event.email == "json@example.com"
      assert event.registered_at == ~U[2023-01-01 12:00:00Z]
    end

    test "decodes JSON with optional fields" do
      json = ~s({
        "user_id": 456,
        "email": "optional@example.com",
        "registered_at": "2023-02-01T12:00:00Z",
        "username": "jsonuser"
      })

      {:ok, event} = UserRegistered.decode(json)

      assert event.user_id == 456
      assert event.email == "optional@example.com"
      assert event.registered_at == ~U[2023-02-01 12:00:00Z]
      assert event.username == "jsonuser"
    end

    test "fails to decode JSON missing required fields" do
      json = ~s({"user_id": 123})

      {:error, changeset} = UserRegistered.decode(json)

      refute changeset.valid?
      assert {"can't be blank", _} = changeset.errors[:email]
      assert {"can't be blank", _} = changeset.errors[:registered_at]
    end

    test "fails to decode invalid JSON" do
      invalid_json = ~s({"user_id": 123, "email":})

      {:error, _} = UserRegistered.decode(invalid_json)
    end

    test "handles JSON with extra fields gracefully" do
      json = ~s({
        "user_id": 789,
        "email": "extra@example.com",
        "registered_at": "2023-03-01T12:00:00Z",
        "extra_field": "ignored"
      })

      {:ok, event} = UserRegistered.decode(json)

      assert event.user_id == 789
      assert event.email == "extra@example.com"
      assert event.registered_at == ~U[2023-03-01 12:00:00Z]
    end
  end

  describe "Event module functions" do
    test "Sleeky.Event.new/2 works with event module" do
      params = %{
        user_id: 999,
        email: "central@example.com",
        registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      {:ok, event} = Sleeky.Event.new(UserRegistered, params)

      assert event.user_id == 999
      assert event.email == "central@example.com"
    end

    test "Sleeky.Event.decode/2 works with event module" do
      json = ~s({
        "user_id": 888,
        "email": "central_decode@example.com",
        "registered_at": "2023-04-01T12:00:00Z"
      })

      {:ok, event} = Sleeky.Event.decode(UserRegistered, json)

      assert event.user_id == 888
      assert event.email == "central_decode@example.com"
      assert event.registered_at == ~U[2023-04-01 12:00:00Z]
    end
  end

  describe "JSON encoding with Jason.Encoder" do
    test "encodes event to JSON string" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 123,
          email: "encode@example.com",
          registered_at: now
        })

      json = Jason.encode!(event)
      parsed = Jason.decode!(json)

      assert parsed["user_id"] == 123
      assert parsed["email"] == "encode@example.com"
      assert parsed["registered_at"] == DateTime.to_iso8601(now)
      assert parsed["username"] == nil
    end

    test "encodes event with all fields including optional" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 456,
          email: "full@example.com",
          registered_at: now,
          username: "fulluser"
        })

      json = Jason.encode!(event)
      parsed = Jason.decode!(json)

      assert parsed["user_id"] == 456
      assert parsed["email"] == "full@example.com"
      assert parsed["registered_at"] == DateTime.to_iso8601(now)
      assert parsed["username"] == "fulluser"
    end

    test "encodes only defined fields (no internal Ecto fields)" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 789,
          email: "fields@example.com",
          registered_at: now
        })

      json = Jason.encode!(event)
      parsed = Jason.decode!(json)

      # Should only contain the defined fields
      expected_fields = ["user_id", "email", "registered_at", "username"]
      actual_fields = Map.keys(parsed)

      assert length(actual_fields) == length(expected_fields)

      Enum.each(expected_fields, fn field ->
        assert field in actual_fields
      end)

      # Should not contain internal Ecto fields
      refute "__struct__" in actual_fields
      refute "__meta__" in actual_fields
    end

    test "handles datetime formatting correctly" do
      # Test specific datetime to ensure consistent formatting
      datetime = ~U[2023-05-15 14:30:45Z]

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 999,
          email: "datetime@example.com",
          registered_at: datetime
        })

      json = Jason.encode!(event)
      parsed = Jason.decode!(json)

      assert parsed["registered_at"] == "2023-05-15T14:30:45Z"
    end

    test "encodes with Jason.encode/1 returning tuple" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 111,
          email: "tuple@example.com",
          registered_at: now
        })

      {:ok, json} = Jason.encode(event)
      parsed = Jason.decode!(json)

      assert parsed["user_id"] == 111
      assert parsed["email"] == "tuple@example.com"
    end

    test "round-trip encoding and decoding preserves data" do
      original_data = %{
        user_id: 555,
        email: "roundtrip@example.com",
        registered_at: ~U[2023-06-01 10:15:30Z],
        username: "roundtripuser"
      }

      # Create event from original data
      {:ok, original_event} = UserRegistered.new(original_data)

      # Encode to JSON
      json = Jason.encode!(original_event)

      # Decode back to event
      {:ok, decoded_event} = UserRegistered.decode(json)

      # Compare field by field
      assert decoded_event.user_id == original_event.user_id
      assert decoded_event.email == original_event.email
      assert decoded_event.registered_at == original_event.registered_at
      assert decoded_event.username == original_event.username
    end

    test "encodes null values for optional fields correctly" do
      {:ok, event} =
        UserRegistered.new(%{
          user_id: 777,
          email: "null@example.com",
          registered_at: ~U[2023-07-01 12:00:00Z]
          # username intentionally omitted
        })

      json = Jason.encode!(event)
      parsed = Jason.decode!(json)

      assert parsed["username"] == nil
      # Key exists but value is null
      assert Map.has_key?(parsed, "username")
    end

    test "encoded JSON can be pretty printed" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event} =
        UserRegistered.new(%{
          user_id: 888,
          email: "pretty@example.com",
          registered_at: now,
          username: "prettyuser"
        })

      pretty_json = Jason.encode!(event, pretty: true)

      # Should contain newlines and indentation
      assert String.contains?(pretty_json, "\n")
      assert String.contains?(pretty_json, "  ")

      # Should still be valid JSON
      parsed = Jason.decode!(pretty_json)
      assert parsed["user_id"] == 888
      assert parsed["email"] == "pretty@example.com"
    end

    test "can encode list of events" do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      {:ok, event1} =
        UserRegistered.new(%{
          user_id: 100,
          email: "list1@example.com",
          registered_at: now
        })

      {:ok, event2} =
        UserRegistered.new(%{
          user_id: 200,
          email: "list2@example.com",
          registered_at: now,
          username: "listuser2"
        })

      events = [event1, event2]
      json = Jason.encode!(events)
      parsed = Jason.decode!(json)

      assert length(parsed) == 2
      assert Enum.at(parsed, 0)["user_id"] == 100
      assert Enum.at(parsed, 0)["email"] == "list1@example.com"
      assert Enum.at(parsed, 1)["user_id"] == 200
      assert Enum.at(parsed, 1)["username"] == "listuser2"
    end
  end

  describe "struct properties" do
    test "event struct has correct module name" do
      {:ok, event} =
        UserRegistered.new(%{
          user_id: 1,
          email: "struct@example.com",
          registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      assert event.__struct__ == Blogs.Accounts.Events.UserRegistered
    end

    test "can pattern match on event struct" do
      {:ok, event} =
        UserRegistered.new(%{
          user_id: 1,
          email: "pattern@example.com",
          registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      assert %UserRegistered{user_id: 1, email: "pattern@example.com"} = event
    end

    test "can update event struct" do
      {:ok, event} =
        UserRegistered.new(%{
          user_id: 1,
          email: "update@example.com",
          registered_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      updated_event = %{event | username: "updated_username"}
      assert updated_event.username == "updated_username"
      assert updated_event.email == "update@example.com"
    end
  end
end
