public class EventHelper {
    
    public static void validateNoOverlap(List<Event> newMeetings) {
        // convert each new meeting start and end times to minutes
        Map<Id, Map<String, Long>> newMeetingTimesInMinutes = new Map<Id, Map<String, Long>>();
        for (Event meeting : newMeetings) {
            Map<String, Long> times = new Map<String, Long>();
            times.put('start', convertToMinutes(meeting.StartDateTime));
            times.put('end', convertToMinutes(meeting.EndDateTime));
            newMeetingTimesInMinutes.put(meeting.Id, times);
        }

        // query and convert start and end times to minutes
        List<Event> existingMeetings = [SELECT Id, StartDateTime, EndDateTime
                                        FROM Event
                                        WHERE StartDateTime < :Datetime.now().addDays(30)]; 

        for (Event newMeeting : newMeetings) {
            Long newStart = newMeetingTimesInMinutes.get(newMeeting.Id).get('start');
            Long newEnd = newMeetingTimesInMinutes.get(newMeeting.Id).get('end');
            
            for (Event existingMeeting : existingMeetings) {
                Long existingStart = convertToMinutes(existingMeeting.StartDateTime);
                Long existingEnd = convertToMinutes(existingMeeting.EndDateTime);
                
                // check for overlap based on minutes 
                if ((newStart < existingEnd) && (newEnd > existingStart)) {
                    newMeeting.addError('This interview meeting overlaps with an existing meeting. Please check your Calendar!');
                    break;
                }
            }
        }
    }
    
    // Helper method to convert DateTime to minutes 
    public static Long convertToMinutes(Datetime dt) {
        Long epochMillis = dt.getTime(); 
        return epochMillis / 60000; 
    }
}
