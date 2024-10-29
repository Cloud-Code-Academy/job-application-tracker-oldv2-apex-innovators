public with sharing class JoobleJobSearchController { 
    @AuraEnabled
    public static Map<String, Object> searchJobs(String keyword, String location, Integer pageNumber, Integer pageSize) {
        String apiKey = API_Config__c.getInstance().Jooble_API__c;
        String endpoint = 'https://jooble.org/api/' + apiKey;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(20000);

        Map<String, Object> requestMap = new Map<String, Object>{
            'keywords' => keyword,
            'location' => location,
            'page' => String.valueOf(pageNumber), 
            'resultonpage' => pageSize 
        };
        
        req.setBody(JSON.serialize(requestMap));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResults = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Integer totalCount = (Integer) jsonResults.get('totalCount');
            List<Object> jobsList = (List<Object>) jsonResults.get('jobs');

            List<Job> jobs = new List<Job>();
            
            for (Object obj : jobsList) {
                Map<String, Object> jobJson = (Map<String, Object>) obj;
                jobs.add(createJobFromJson(jobJson)); 
            }

            return new Map<String, Object>{
                'jobs' => jobs,
                'totalCount' => totalCount 
            };
        } else {
            throw new AuraHandledException('Failed to retrieve jobs: ' + res.getStatusCode());
        }
    }

    // Helper method to map each job JSON to Job object
    private static Job createJobFromJson(Map<String, Object> jobJson) {
        Job job = new Job();
        job.id = String.valueOf(jobJson.get('id'));
        job.title = (String) jobJson.get('title');
        job.location = (String) jobJson.get('location');
        job.snippet = (String) jobJson.get('snippet');
        job.salary = (String) jobJson.get('salary');
        job.type = (String) jobJson.get('type');
        job.link = (String) jobJson.get('link');
        job.company = (String) jobJson.get('company');
        
        String rawDate = (String) jobJson.get('updated'); 
        if (String.isNotBlank(rawDate)) {
            try {
                DateTime dt = DateTime.valueOfGmt(rawDate.replace('T', ' '));
                job.updated = dt.format('MMMM d, yyyy');
            } catch (Exception e) {
                job.updated = rawDate; // Fallback to original value if parsing fails
            }
        } else {
            job.updated = 'Date not available';
        }
        
        return job;
    }
    
    public class Job {
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String salary { get; set; }
        @AuraEnabled public String snippet { get; set; }
        @AuraEnabled public String company { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String location { get; set; }
        @AuraEnabled public String updated { get; set; }
        @AuraEnabled public String id { get; set; }
        }
    
        @AuraEnabled
        public static Id createJobApplication(Job jobApp) {
            System.debug('Starting createJobApplication');
            Set<String> existingJoobleExternalIds = new Set<String>();

            for (Job_Application__c job : [SELECT JoobleExternalId__c FROM Job_Application__c]) {
                existingJoobleExternalIds.add(job.JoobleExternalId__c);
            }

            System.debug('Existing JoobleExternalIds: ' + existingJoobleExternalIds);

            if (existingJoobleExternalIds.contains(jobApp.id)) {
                System.debug('Duplicate job detected with ID: ' + jobApp.id);
                throw new AuraHandledException('This job is already saved!');
            }

            try {
                List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :jobApp.company LIMIT 1];
                Id accountId;

                if (existingAccounts.isEmpty()) {
                    Account newAccount = new Account(Name = jobApp.company);
                    insert newAccount;
                    accountId = newAccount.Id;
                    System.debug('New account created with ID: ' + accountId);
                } else {
                    accountId = existingAccounts[0].Id;
                    System.debug('Using existing account with ID: ' + accountId);
                }

                Job_Application__c newJobApp = new Job_Application__c(
                    Job_Position__c = jobApp.title,
                    URL__c = jobApp.link,
                    Description__c = jobApp.snippet,
                    Location__c = jobApp.location,
                    Date_Posted__c = formatDateString(jobApp.updated),
                    Job_Application_Status__c = 'Saved',
                    Job_Source__c = 'Jooble Job Board',
                    JoobleExternalId__c = jobApp.id,
                    Company_Name__c = accountId
                );

                insert newJobApp;
                System.debug('Job Application created with ID: ' + newJobApp.Id);
                return newJobApp.Id;

            } catch(Exception e) {
                System.debug('Exception caught in createJobApplication: ' + e.getMessage());
                throw new AuraHandledException('Error creating job application: ' + e.getMessage());
            }
        }


    private static String formatDateString(String dateStr) {
        if (String.isBlank(dateStr)) {
            return Date.today().format();
        }
        
        try {
            DateTime dt = DateTime.valueOfGmt(dateStr);
            return dt.format('yyyy-MM-dd');
        } catch (Exception e) {
            return Date.today().format();
        }
    }
}   


