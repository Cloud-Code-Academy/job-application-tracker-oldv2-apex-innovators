trigger EventTrigger on Event (before insert, before update, before delete) {
    List<Event> newMeetings = Trigger.new;
    EventHelper.validateNoOverlap(newMeetings);
}