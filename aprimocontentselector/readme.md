## Installation Instruction 

 

### Prerequisites 

- Download the code from the Aprimo Connect GitHub 
- Permissions to create new Aprimo client registrations 
- Permissions to deploy code to the Salesforce instance 
- Permissions to access the ‘Edit Page’ functionality on Salesforce record pages 

### Instructions

1) Download the LWC and Classes folders from the github repo 
2) In the “aprimocontentselector.js” file replace the value of the “tenantUrl” variable with your specific Aprimo environment DAM url. EX: https://myenvironment.dam.aprimo.com 
3) In the “aprimocontentselector.js” file replace the value of “tenant” variable with your specific Aprimo environment name. EX: “myenvironment” 
4) In the “AprimoContentSelector.cls” file replace the “aprimoTenant” variable with your specific Aprimo environment name. EX: “myenvironment” 
5) Go to your Aprimo administration settings and configure a new Aprimo registration  
6) The secret is non-recoverable. So do not forget it. Make sure the authorization flow is set to Client Credentials 
![AprimoRegistration](https://user-images.githubusercontent.com/51798256/179263426-0b718517-5ffd-451b-9334-a65bc9511503.png)
7) In the “AprimoContentSelector.cls” file replace the “aprimoClientId” and “aprimoClientSecret” with the appropriate value from your new Aprimo client registration 
8) Deploy the following files: 

- aprimocontentselector.html 
- aprimocontentselector.js 
- aprimocontentselector.js-meta.xml 
- AprimoContentSelector.cls 
- AprimoCollectionsConnector.cls-meta.xml

9) Navigate to an Opportunity object in Salesforce 
10) Enter the ‘Edit Page’ functionality 
11) Search “Aprimo” and drag the new component onto the page 
