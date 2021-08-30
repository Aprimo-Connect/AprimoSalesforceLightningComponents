public with sharing class AprimoContentSelector {

    public class OrderStatusResponse
    {
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String url {get; set;}
        public void OrderStatusResponse()
        {

        }
    }
        
    // Auth Variables
    private static string aprimoTenant = '';
    private static string aprimoClientId = '';
    private static string aprimoClientSecret = '';

    public AprimoContentSelector() {

    }

    private static map<String, Object> getAprimoAccessToken() {
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

    @AuraEnabled
    public static String getAprimoRecordDownloadUrl(String aprimoRecordId)
    {
     	// Get Access Token
     	// Make request to aprimo to place publicCDN order
     	// Recursively check order status until delivered files are ready  
     	String aprimoBearerToken = (String)getAprimoAccessToken().get('access_token'); 
		
        String strResponse = null;
        String retVal = null;
        if(String.isNotBlank(aprimoBearerToken))
        {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('https://' + aprimoTenant + '.dam.aprimo.com/api/core/orders');
            
            httpRequest.setMethod('POST');
            httpRequest.setHeader('Authorization', 'Bearer ' + aprimoBearerToken);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Length', '0'); 
            httpRequest.setHeader('API-VERSION', '1');
            
             httpRequest.setBody('{ "type": "download", "targets": [{ "recordId": "' + aprimoRecordId + '", "targetTypes":["Document"], "assetType": "LatestVersionOfMasterFile" }] }');
            
            try
            {
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                
                if(httpResponse.getStatusCode() == 201)
                {
                    strResponse = httpResponse.getBody();
                }
                else
                {
                    System.debug('httpResponse status code is NOT 201');
                    throw new CalloutException(httpResponse.getBody());
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
            
        }
        
        if(String.isNotBlank(strResponse))
        {
            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);

            if(fullResponse.get('status') == 'Pending' || fullResponse.get('status') == 'Success')
            {
                // return the order Id to get used later
                retVal = (String)fullResponse.get('id');
            }
            else 
            {
                retVal = 'Failure';
                // Failure - return an error
            }
        }
        
      return retVal;
        
      
    }

    @AuraEnabled
    public static String getAprimoOrderStatus(string orderId)
    {

        String aprimoBearerToken = (String)getAprimoAccessToken().get('access_token');

        String strResponse = null;
        String aprimoCDNUrl = null;
        if(String.isNotBlank(aprimoBearerToken))
        {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('https://' + aprimoTenant + '.dam.aprimo.com/api/core/order/' + orderId);
            
            httpRequest.setMethod('GET');
            httpRequest.setHeader('Authorization', 'Bearer ' + aprimoBearerToken);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Length', '0'); 
            httpRequest.setHeader('API-VERSION', '1');
            
            try
            {
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                
                if(httpResponse.getStatusCode() == 200)
                {
                    System.debug('httpResponse status code is 200');
                    strResponse = httpResponse.getBody();
                    System.debug(strResponse);
                }
                else
                {
                    System.debug('httpResponse status code is NOT 201');
                    throw new CalloutException(httpResponse.getBody());
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        OrderStatusResponse retVal = new OrderStatusResponse();
        if(String.isNotBlank(strResponse))
        {
            Map<String, Object> fullResponse = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
            
             if(fullResponse.get('status') != 'Success')
             { 
                 retVal.status = (String)fullResponse.get('status');
             }
             else if(fullResponse.get('status') == 'Success') {
                List<Object> deliveredFiles = (List<Object>)fullResponse.get('deliveredFiles');
                retVal.url = (String)deliveredFiles[0];
             }
             else {
                 // Failure
                 retVal.status = 'Failure';
             }
            
        }

        return JSON.serialize(retVal);
    }

    @AuraEnabled
    public static void createAttachment(String downloadUrl, String salesforceRecordId)
    {
        
        // Get blob image
        HttpRequest req = new HttpRequest();
        req.setEndpoint(downloadUrl);
        req.setMethod('GET');
        Http binding = new Http();
        HttpResponse res = binding.send(req);
        // response will be a 301 Moved Permanently response from Aprimo. The Location header will contain the url to actually get the file binary.
        downloadUrl = res.getHeader('Location');

        req.setEndpoint(downloadUrl);
        req.setMethod('GET');
        binding = new Http();
        res = binding.send(req);
        
        Blob blobImage = res.getBodyAsBlob();
        List<String> splitCdnUrl = downloadUrl.split('\\?');
        splitCdnUrl = splitCdnUrl[0].split('/');
        String filename = splitCdnUrl.get(splitCdnUrl.size() - 1);
        filename = filename.replace('%20', ' ');
        
        ContentVersion cv = createContentVersion(blobImage, filename);
        ContentDocumentLink cdLnk = createContentDocumentLink(cv.Id, salesforceRecordId);
        
    }
    private static ContentVersion createContentVersion(Blob blobImage, String filename)
    {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        // If ContentDocumentId is left blank, the system will automatically create a 
        //cv.ContentDocumentId = contentDocumentId;
        cv.VersionData = blobImage;
        cv.Title = filename;
        cv.PathOnClient = filename;
        
        try
        {
        	insert(cv);
            return cv;
        }
        catch(DMLException e) 
        {
          System.debug(e);
          return null;
    	}
        
    }
    private static ContentDocumentLink createContentDocumentLink(String contentVersionId, String salesforceRecordid)
    {
        ContentDocumentLink cdLnk = new ContentDocumentLink();
        cdLnk.ContentDocumentId = [
              SELECT ContentDocumentId 
              FROM ContentVersion 
              WHERE Id =: contentVersionId
            ].ContentDocumentId;
        cdLnk.LinkedEntityId = salesforceRecordid;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdLnk.ShareType = 'V';
        try {
          insert(cdLnk);
          return cdLnk;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }
}