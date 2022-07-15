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
