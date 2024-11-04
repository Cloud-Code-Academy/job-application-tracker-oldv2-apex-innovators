trigger EventTrigger on Event (before insert, before update) {
    List<Event> newMeetings = Trigger.new;

    EventHelper.validateNoOverlapAndFetchJobPosition(newMeetings);

    if (Trigger.isInsert || Trigger.isUpdate) {
        EventHelper.sendUpcomingEventEmails(newMeetings);
    }
}

