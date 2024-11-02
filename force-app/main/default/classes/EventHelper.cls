public class EventHelper {

    public static void validateNoOverlapAndFetchJobPosition(List<Event> newMeetings) {
        Map<Id, String> jobPositionMap = new Map<Id, String>();
        Map<Id, String> companyNameMap = new Map<Id, String>();
        Set<Id> jobAppIds = new Set<Id>();

        for (Event meeting : newMeetings) {
            if (meeting.WhatId != null) {
                jobAppIds.add(meeting.WhatId);
            }
        }

        Map<Id, Job_Application__c> jobApplications = new Map<Id, Job_Application__c>(
            [SELECT Id, Job_Position__c, Company_Name__c FROM Job_Application__c WHERE Id IN :jobAppIds]
        );

        // map job position and company name to each event
        for (Event meeting : newMeetings) {
            if (meeting.WhatId != null && jobApplications.containsKey(meeting.WhatId)) {
                jobPositionMap.put(meeting.Id, jobApplications.get(meeting.WhatId).Job_Position__c);
                companyNameMap.put(meeting.Id, jobApplications.get(meeting.WhatId).Company_Name__c);
            }
        }

        Map<Id, Map<String, Long>> newMeetingTimesInMinutes = new Map<Id, Map<String, Long>>();
        for (Event meeting : newMeetings) {
            Map<String, Long> times = new Map<String, Long>();
            times.put('start', convertToMinutes(meeting.StartDateTime));
            times.put('end', convertToMinutes(meeting.EndDateTime));
            newMeetingTimesInMinutes.put(meeting.Id, times);
        }

        List<Event> existingMeetings = [SELECT Id, StartDateTime, EndDateTime, Type
                                        FROM Event
                                        WHERE StartDateTime < :Datetime.now().addDays(30)
                                        AND (Type = 'Phone Screen' OR Type = 'Interview')];

        for (Event newMeeting : newMeetings) {
            Long newStart = newMeetingTimesInMinutes.get(newMeeting.Id).get('start');
            Long newEnd = newMeetingTimesInMinutes.get(newMeeting.Id).get('end');

            for (Event existingMeeting : existingMeetings) {
                if (existingMeeting.Id == newMeeting.Id) {
                    continue;
                }

                Long existingStart = convertToMinutes(existingMeeting.StartDateTime);
                Long existingEnd = convertToMinutes(existingMeeting.EndDateTime);

                if ((newStart < existingEnd) && (newEnd > existingStart)) {
                    String jobPosition = jobPositionMap.containsKey(newMeeting.Id) ? jobPositionMap.get(newMeeting.Id) : 'N/A';
                    newMeeting.addError('This interview for the position ' + jobPosition + 
                        ' overlaps with an existing meeting. Please check your Calendar!');
                    break;
                }
            }
        }
    }

    public static void sendUpcomingEventEmails(List<Event> newMeetings) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    // Prepare emails for events happening within 24 hours
    for (Event meeting : newMeetings) {
        if (meeting.StartDateTime != null && meeting.StartDateTime < Datetime.now().addHours(24)) {

            // Retrieve job details if available
            String jobPosition = 'N/A';
            String accountName = 'N/A'; 

            if (meeting.WhatId != null) {
                Job_Application__c jobApp = [
                    SELECT Job_Position__c, Company_Name__c, Company_Name__r.Name 
                    FROM Job_Application__c 
                    WHERE Id = :meeting.WhatId LIMIT 1
                ];
                jobPosition = jobApp.Job_Position__c != null ? jobApp.Job_Position__c : 'N/A';
                accountName = jobApp.Company_Name__r != null ? jobApp.Company_Name__r.Name : 'N/A'; 
            }

            User owner = [SELECT Email FROM User WHERE Id = :meeting.OwnerId LIMIT 1]; // benjaminpierre1@gmail not getting emails, but other gmail is, register new org with benisworking1
            String recipientEmail = owner.Email;
            String eventType = meeting.Type;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { recipientEmail }); 
            email.setSubject('Upcoming Interview Reminder');
            email.setPlainTextBody(
                'This is a reminder for your upcoming ' + eventType + ' for the ' + jobPosition +
                ' position with ' + accountName + ', scheduled on ' + meeting.StartDateTime.format() + '.'
            );

            emails.add(email);
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}

    public static Long convertToMinutes(Datetime dt) {
        Long epochMillis = dt.getTime();
        return epochMillis / 60000;
    }
}
