defmodule SumupIntegration.EventTest do
  use SumupIntegration.RepoCase

  alias SumupIntegration.Event

  describe "delete_by_id/1" do
    setup do
      events = [
        insert!(:event, name: "Event A"),
        insert!(:event, name: "Event B"),
        insert!(:event, name: "Event C")
      ]

      %{events: events}
    end

    test "deletes event by singular id", %{events: events} do
      [eventA, eventB, eventC] = events

      {1, nil} = Event.delete_by_id(eventA.id)

      assert [
               ^eventB,
               ^eventC
             ] = Event.get_all()
    end

    test "deletes event by multiple ids", %{events: events} do
      [eventA, eventB, eventC] = events

      {2, nil} = Event.delete_by_id([eventA.id, eventB.id])

      assert [
               ^eventC
             ] = Event.get_all()
    end
  end
end
