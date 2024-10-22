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

        // Prepare request body
        String requestBody = JSON.serialize(new Map<String, Object>{
            'keywords' => keyword,
            'location' => location
        });
        req.setBody(requestBody); 

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (System.CalloutException e) {
            throw new AuraHandledException('HTTP callout failed: ' + e.getMessage());
        }

        System.debug('Response Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody()); 

        if (res.getStatusCode() == 200) {
            Map<String, Object> jsonResults;
            try {
                jsonResults = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            } catch (Exception e) {
                throw new AuraHandledException('Error deserializing response: ' + e.getMessage());
            }

            Integer totalCount = (Integer) jsonResults.get('totalCount'); 
            List<Object> jobsList; // Change to List<Object>

            // Ensure jobs are present in the response
            if (jsonResults.containsKey('jobs')) {
                jobsList = (List<Object>) jsonResults.get('jobs'); // Cast to List<Object>
            } else {
                throw new AuraHandledException('Jobs not found in response: ' + res.getBody());
            }

            List<Job> jobs = new List<Job>();

            // Loop through the list of job objects
            for (Object obj : jobsList) {
                Map<String, Object> jobJson = (Map<String, Object>) obj; // Cast to Map<String, Object>

                Job job = new Job();
                job.datePosted = (String) jobJson.get('datecreatedfrom');
                job.title = (String) jobJson.get('title');
                job.location = (String) jobJson.get('location');
                job.snippet = (String) jobJson.get('snippet');
                job.salary = (String) jobJson.get('salary');
                job.source = (String) jobJson.get('source'); // Optional: handle this if needed
                job.type = (String) jobJson.get('type'); // Optional: handle this if needed
                job.link = (String) jobJson.get('link'); // Optional: handle this if needed
                job.company = (String) jobJson.get('company'); // Optional: handle this if needed
                jobs.add(job);
            }

            // Return jobs and total count for pagination
            Map<String, Object> result = new Map<String, Object>();
            result.put('jobs', jobs);
            result.put('totalCount', totalCount);
            return result;
        } else {
            throw new AuraHandledException('Failed to retrieve jobs: ' + res.getBody());
        }
    }

    public class Job {
        @AuraEnabled public String title;
        @AuraEnabled public String location;
        @AuraEnabled public String snippet;
        @AuraEnabled public String salary;
        @AuraEnabled public String source;
        @AuraEnabled public String type;
        @AuraEnabled public String link;
        @AuraEnabled public String company;
        @AuraEnabled public String datePosted;
    }
}
