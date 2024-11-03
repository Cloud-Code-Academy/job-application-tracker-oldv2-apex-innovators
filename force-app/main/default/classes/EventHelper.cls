public class EventHelper {

    public static void validateNoOverlapAndFetchJobPosition(List<Event> newMeetings) {
        Map<Id, String> jobPositionMap = new Map<Id, String>();
        Map<Id, String> companyNameMap = new Map<Id, String>();
        Set<Id> jobAppIds = new Set<Id>();
    
        // Gather Job Application IDs from new meetings
        for (Event meeting : newMeetings) {
            if (meeting.WhatId != null) {
                jobAppIds.add(meeting.WhatId);
            }
        }
    
        // Query Job Applications related to those IDs
        Map<Id, Job_Application__c> jobApplications = new Map<Id, Job_Application__c>(
            [SELECT Id, Job_Position__c, Company_Name__c FROM Job_Application__c WHERE Id IN :jobAppIds]
        );
    
        // Map job position and company name to each event
        for (Event meeting : newMeetings) {
            if (meeting.WhatId != null && jobApplications.containsKey(meeting.WhatId)) {
                jobPositionMap.put(meeting.Id, jobApplications.get(meeting.WhatId).Job_Position__c);
                companyNameMap.put(meeting.Id, jobApplications.get(meeting.WhatId).Company_Name__c);
            }
        }
    
        // Prepare new meeting times in minutes
        Map<Id, Map<String, Long>> newMeetingTimesInMinutes = new Map<Id, Map<String, Long>>();
        for (Event meeting : newMeetings) {
            Map<String, Long> times = new Map<String, Long>();
            times.put('start', convertToMinutes(meeting.StartDateTime));
            times.put('end', convertToMinutes(meeting.EndDateTime));
            newMeetingTimesInMinutes.put(meeting.Id, times);
        }
    
        // Fetch existing meetings
        List<Event> existingMeetings = [SELECT Id, StartDateTime, EndDateTime, Type
                                         FROM Event
                                         WHERE StartDateTime < :Datetime.now().addDays(30)
                                         AND (Type = 'Phone Screen' OR Type = 'Interview')];
    
        // Check for overlaps
        for (Event newMeeting : newMeetings) {
            Long newStart = newMeetingTimesInMinutes.get(newMeeting.Id).get('start');
            Long newEnd = newMeetingTimesInMinutes.get(newMeeting.Id).get('end');
    
            for (Event existingMeeting : existingMeetings) {
                // Skip the same event
                if (existingMeeting.Id == newMeeting.Id) {
                    continue;
                }
    
                Long existingStart = convertToMinutes(existingMeeting.StartDateTime);
                Long existingEnd = convertToMinutes(existingMeeting.EndDateTime);
    
                // Check for overlap condition
                if ((newStart < existingEnd) && (newEnd > existingStart)) {
                    // Prepare the error message
                    String jobPosition = jobPositionMap.containsKey(newMeeting.Id) ? jobPositionMap.get(newMeeting.Id) : 'N/A';
                    newMeeting.addError('This interview for the position ' + jobPosition + 
                        ' overlaps with an existing meeting. Please check your Calendar!');
                    break; // Exit the loop after adding the error
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
                List<Job_Application__c> jobApps = [
                    SELECT Job_Position__c, Company_Name__c, Company_Name__r.Name 
                    FROM Job_Application__c 
                    WHERE Id = :meeting.WhatId
                ];

                if (!jobApps.isEmpty()) {
                    Job_Application__c jobApp = jobApps[0]; 
                    jobPosition = jobApp.Job_Position__c != null ? jobApp.Job_Position__c : 'N/A';
                    accountName = jobApp.Company_Name__r != null ? jobApp.Company_Name__r.Name : 'N/A'; 
                }
            }


            List<User> users = [SELECT Email FROM User WHERE Id = :meeting.OwnerId];

            String recipientEmail = 'default@example.com'; // Use a default email in case the user is not found
                if (!users.isEmpty()) {
                    recipientEmail = users[0].Email; 
                }

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
