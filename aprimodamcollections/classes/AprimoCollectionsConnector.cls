public with sharing class AprimoCollectionsConnector {

    // Auth Variables
    private static string aprimoTenant = 'productstrategy1';
    private static string aprimoClientId = 'RN8G5ECT-RN8G';
    private static string aprimoClientSecret = 'aprimo123';

    // Stage Collection ID Map
    private static Map<String, String> salesforceDataToCollectionIds = new Map<String, String>{
        'Prospecting' => '20ae20d93dcb40d4a3e6ace5013ff94a',
        'Qualification' => '5df80084a2164ba38f13ace501408b8c'
    };

    public AprimoCollectionsConnector() {
        
  
    }

    private static Map<String, Object> getAprimoAccessToken() {
        // Make a POST request to Aprimo to get an access token
        String strResponse = null;
        map<String, Object> mapAccessTokenRequestJsonData = new map<String, Object>();
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('https://' + aprimoTenant + '.aprimo.com/login/connect/token');
        
        httpRequest.setMethod('POST');
        String payload = 'grant_type=client_credentials&scope=api&client_id='+aprimoClientId+'&client_secret='+aprimoClientSecret;
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpRequest.setHeader('Content-Length', String.valueOf(payload.length()));
        HttpRequest.setBody(payload);
        
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            
            if(httpResponse.getStatusCode() == 200)
            {   System.debug('Access Token request returned 200');
                strResponse = httpResponse.getBody();
            }
            else
            {
                System.debug('Access Token request did not return 200');
                throw new CalloutException(httpResponse.getBody());
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }
        
        
        if(String.isNotBlank(strResponse))
        {
            mapAccessTokenRequestJsonData = (map<String, Object>)JSON.deserializeUntyped(strResponse);
            System.debug('mapAccessTokenRequestJsonData ===> '+mapAccessTokenRequestJsonData);
        }
        
        if(!mapAccessTokenRequestJsonData.isEmpty())
        {
            return mapAccessTokenRequestJsonData;
        }
        else
        {
            return null;
        }
        
    }

    @AuraEnabled(cacheable=false)
    public static String getCollectionId(string salesforceRecordid)
    {
        string result = [
            SELECT StageName
        	FROM Opportunity
        	WHERE Id =: salesforceRecordid
        ].StageName;
        
        return salesforceDataToCollectionIds.get(result);
    }
    @AuraEnabled(cacheable=false)
    public static List<Object> getAprimoRecordsFromCollection(String collectionId)
    {
        String aprimoToken = (String)getAprimoAccessToken().get('access_token');
        return searchAprimoForRecords(collectionId, aprimoToken);
    }

    private static List<Object> searchAprimoForRecords(String collectionId, String aprimoToken)
    {
        String strResponse = null;
        String aprimoCDNUrl = null;
        Integer currPage = 1;
        Integer pageSize = 50;
        Integer totalCount;
        List<Object> records = new List<Object>();
        if(String.isNotBlank(aprimoToken))
        {
            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(searchDAMRequest(collectionId, aprimoToken, currPage, pageSize));
            records.addAll((List<Object>)fullResponse.get('items'));
            totalCount = (Integer)fullResponse.get('totalCount');
            System.debug(records.size());
            currPage++;
        }
      
        while(records.size() < totalCount)
        {
            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(searchDAMRequest(collectionId, aprimoToken, currPage, pageSize));
            records.addAll((List<Object>)fullResponse.get('items'));
            System.debug(records.size());
            currPage++;
        }
        return records;
    }

    private static String searchDAMRequest(String collectionId, String aprimoToken, Integer currPage, Integer pageSize)
    {
        String strResponse = null;
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('https://' + aprimoTenant + '.dam.aprimo.com/api/core/search/records');
        
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Authorization', 'Bearer ' + aprimoToken);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Content-Length', '0'); 
        httpRequest.setHeader('API-VERSION', '1');
        httpRequest.setHeader('select-record', 'title, preview');
        httpRequest.setHeader('page', String.valueOf(currPage));
        httpRequest.setHeader('pagesize', String.valueOf(pageSize));
        
        httpRequest.setBody('{"searchExpression": { "expression": "Collection(' + collectionId + ')" }, "logRequest": true}');
        
        try
        {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            
            if(httpResponse.getStatusCode() == 200)
            {
                System.debug('Search records request status code is 200');
                strResponse = httpResponse.getBody();
            }
            else
            {
                System.debug('Search records request status code is NOT 200');
                throw new CalloutException(httpResponse.getBody());
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }

        return strResponse;
        
    }
}
