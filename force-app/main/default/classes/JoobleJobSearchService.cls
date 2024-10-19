public with sharing class JoobleJobSearchService {

    private static final String baseUrl = 'https://jooble.org/api';
    private statick final String API_KEY = '01733b5c-8194-4642-94bf-1b7a34ca2f67'
    
    public static List<JobBoardResult> searchJobs(String keywords, String location) {
        HttpRequest req = new HttpRequest();
        
    }
}