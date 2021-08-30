import { LightningElement, api } from 'lwc';
import getAprimoRecordDownloadUrl from '@salesforce/apex/AprimoContentSelector.getAprimoRecordDownloadUrl';
import getAprimoOrderStatus from '@salesforce/apex/AprimoContentSelector.getAprimoOrderStatus';
import createAttachment from '@salesforce/apex/AprimoContentSelector.createAttachment';


export default class Aprimocontentselector extends LightningElement {
    @api recordId;

    aprimoAssetUrl = "";
    tenantUrl = "https://{{tenant}}.dam.aprimo.com";
    selectorOptions = {
            title: 'Select File',
            description: 'Select the file to import.',
            limitingSearchExpression: "Classification.Id = ''",
            accept: 'Select',
            select: 'single'
        };

    tenant = "";
    encodedOptions = window.btoa(JSON.stringify(this.selectorOptions));
    
    
    constructor()
    {
        super();
        
        
        window.addEventListener('message', this.handleMessageEvent, false);
    }
    
    handleMessageEvent = (event) => {
        console.log(event);
        // Ensure only messages from the Aprimo Content Selector are handled.
        if (event.origin !== this.tenantUrl) {
            console.log("event.origin did not equal tenantUrl");
            return
        }
        if (event.data.result === 'cancel') {

        } 
        else 
        {
            const ids = event.data.selection.map((selection) => selection.id)
            console.log(ids);
            getAprimoRecordDownloadUrl({aprimoRecordId: ids[0]})
                .then(data => {
                    var timeoutID = setTimeout(getOrderStatus, 1000, data, this.recordId);
                })
        }

    }
    openSelector(event) {
        
        let aprimoContentSelectorUrl = this.tenantUrl + "/dam/selectcontent#options=" + this.encodedOptions;
        let params = `scrollbars=no,resizable=no,status=no,location=no,toolbar=no,menubar=no, width=1000,height=600,left=100,top=100`;
        window.open(aprimoContentSelectorUrl, 'selector', params);
    }

    GetRecordsCallback(data) {
        this.aprimoAssetUrl = data;

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
                alert("Download Failed. Please contact an admin");
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