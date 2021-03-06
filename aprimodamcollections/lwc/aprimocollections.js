import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCollectionId from '@salesforce/apex/AprimoCollectionsConnector.getCollectionId';
import getAprimoRecordsFromCollection from '@salesforce/apex/AprimoCollectionsConnector.getAprimoRecordsFromCollection';
import getAprimoRecordDownloadUrl from '@salesforce/apex/AprimoCollectionsConnector.getAprimoRecordDownloadUrl';
import createAttachment from '@salesforce/apex/AprimoCollectionsConnector.createAttachment';
import getAprimoOrderStatus from '@salesforce/apex/AprimoCollectionsConnector.getAprimoOrderStatus';


class OrderStatusResponse{
    constructor()
    {
        this.status = '';
        this.url = '';
    }
}

export default class Aprimocollections extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.StageName'] })
    wiredFunc({ error, data }) {
        // The @wire function is being used as a change handler
        // wiredFunc will run when the record page is saved, so logic will need to include checking to see if any
        // of the relevant fields were effected. The data object will contain this info
        getCollectionId({salesforceRecordid: this.recordId})
        .then(stageCollectionData => {
            getAprimoRecordsFromCollection({collectionId: stageCollectionData})
            .then(aprimoRecords => {
                this.records = aprimoRecords;
            })
        })
        .catch(event => {
            console.log(event);
        });
    };

    // The records variable will be set in the wiredFunc and will contain a List of Objects
    records;
    // Tenant is the unqiue name of your Aprimo instance
    tenant = "productstrategy1";

    constructor()
    {
        super();
    }


    // The function to run when an Aprimo asset is clicked in the Salesforce UI
    openAprimo(event)
    {
        window.open("https://" + this.tenant + ".dam.aprimo.com/dam/contentitems/" + event.target.dataset.id);
    }
    
    downloadToAttachments(event)
    {
        const aprimoId = event.target.dataset.id;
        console.log("assetId: " + aprimoId);
        getAprimoRecordDownloadUrl({aprimoRecordId: aprimoId})
            .then(data => {
                var timeoutID = setTimeout(getOrderStatus, 1000, data, this.recordId);
            });
    }
}

function getOrderStatus(aprimoOrderId, salesforceId)
{
    
    getAprimoOrderStatus({orderId: aprimoOrderId})
        .then(data => {
            var responseObj = JSON.parse(data);
            if(responseObj.status == 'Pending' || responseObj.status == "Executing")
            {
                // Wait for a few seconds. 
                setTimeout(getOrderStatus, 1000, aprimoOrderId, salesforceId );
            }
            else if(responseObj.status == "Failed" || responseObj.status == "Failure")
            {
                alert("Download Failed. Please contact and admin");
                return;
            }
            else
            {
                // Success
                createAttachment({downloadUrl: responseObj.url, salesforceRecordId: salesforceId})
                .then(data => {
                    // Reload the page
                    window.location.reload(); 

                })
            }
            
        });
        
   
   
}


