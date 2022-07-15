# Prerequisites 

- Pull the code from the Aprimo Connect GitHub 
- Permissions to create new Aprimo client registrations 
- Permissions to deploy code to the Salesforce instance 
- Permissions to access the ‘Edit Page’ functionality on Salesforce record pages 
- Permission to access the Remote Site Settings in Salesforce Setup 

 ## Instructions

1) Download the LWC and Classes folders from the github repo 
2) In the “aprimocollections.js” file replace the value of the “tenant” variable with your specific Aprimo environment name 
3) In the “AprimoCollectionsConnector.cls” file replace the “aprimoTenant” variable with your specific Aprimo environment name 
4) Go to your Aprimo administration settings and configure a new Aprimo registration  
   - The secret is non-recoverable. So do not forget it. Make sure the authorization flow is set to Client Credentials 
5) In the “AprimoCollectionsConnector.cls” file replace the “aprimoClientId” and “aprimoClientSecret” with the appropriate value from your new Aprimo client registration 
6) In the “AprimoCollectionsConnector.cls” file alter the collections ids in the stageNameToCollectionIds to reflect collections that exist in your Aprimo environment 
7) If this configuration is not what you are looking for, this document will detail where and how to change configuration later on 
8) Deploy the following files: 

- aprimocollections.html 
- aprimocollections.js 
- aprimocollections.js-meta.xml 
- AprimoCollectionsConnector.cls 
- AprimoCollectionsConnector.cls-meta.xml 
- Navigate to an Opportunity object in Salesforce 

9) Enter the ‘Edit Page’ functionality  
10) Search “Aprimo” and drag the new component onto the page 
11) Navigate to the Salesforce Setup > Security > Remote Site Settings 
- Whitelist your Aprimo order download url EX: https://[your environment].dam.aprimo.com 
- Whitelist your Aprimo access token url EX: https://[your environment].aprimo.com 

## Configuration Options

### How to use different Salesforce Objects
Navigate to the aprimocollections.js file. You define which Salesforce object to monitor in the @wire decorated function. 

![wireFunction](https://user-images.githubusercontent.com/51798256/179279743-2f9b01ec-7656-4f16-9038-c34e6a8450f1.png) 

When a record page is changed in Salesforce the “wiredFunc” will receive an object containing data on the fields defined in the fields attribute. In the above screenshot that is the Opportunity’s StageName field and an Opportunity custom field called Aprimo_Collections_Custom_Field__c. This fields array can contain either a single or multiple fields, including custom fields. If the connector needs to be configured with the Account object’s Industry field, you would set the fields array to [‘Account.Industry’] and the same thing for other Salesforce objects.

The getCollectionId() function in AprimoCollectionsConnector.cls is also relevant in this configuration. 

![image](https://user-images.githubusercontent.com/51798256/179281129-ac188434-2d4c-4f2b-a59b-4660744954ae.png)

The wired function will call this function to query Salesforce to get the data of the relevant metadata fields. If this need to be changed to support the Account object it may look like the screenshot below. 
![image](https://user-images.githubusercontent.com/51798256/179281222-6da3bc55-b40c-4a16-ba74-33442091262a.png)

### How to change Collection IDs

Navigate to the AprimoCollectionsConnector.cls file. This class contains the Map object that associates Salesforce data to Aprimo collection IDs. 

![image](https://user-images.githubusercontent.com/51798256/179282648-5a184b2d-3146-4638-ab4f-ea0d94c653bf.png)


Set the values appropriate to your configuration. If the connector is going to base the collection off of an Account’s Industry field, then the Map object would look something more like this: 

![image](https://user-images.githubusercontent.com/51798256/179282702-1011544e-bda8-4544-922b-360692439e07.png)

### How to change selection logic
The login for determining which collection will be selected for surfacing is decided in the @wire decorated function in aprimocollections.js as well as the getCollectionId() function in AprimoCollectionsConnector.cls 

@wire
![image](https://user-images.githubusercontent.com/51798256/179282838-a72a561f-8e2e-4aa9-a9c1-effe92e2680e.png)


getCollectionId()
![image](https://user-images.githubusercontent.com/51798256/179282866-0838c991-c156-43b9-8697-38f88b2a9741.png)


If your configuration required more advanced selection logic that login will be placed in these 2 functions. 
