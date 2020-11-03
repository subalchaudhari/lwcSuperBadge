import { LightningElement,api, wire ,track} from 'lwc';
import {publish,MessageContext} from 'lightning/messageService';
import{getRecord} from 'lightning/uiRecordApi';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';

const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT = 'Ship it!';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';

const columns = [
  { label: 'Name', fieldName: 'Name', editable: true },
  { label: 'Length', fieldName: 'Length__c', type: 'number', editable: true },
  { label: 'Price', fieldName: 'Price__c', type: 'currency', editable: true },
  { label: 'Description', fieldName: 'Description__c', type: 'text', editable: true },
  
];
export default class BoatSearchResults extends LightningElement {
  @track 
  selectedBoatId;
  columns = columns;
  @track
  boatTypeId = '';
  boats;
  @track
  isLoading = false;
  
  // wired message context
  @wire(MessageContext)
  messageContext;
  // wired getBoats method
  @wire(getBoats,{boatTypeId: '$boatTypeId'}) 
  wiredBoats(result) {
      if(result.data){
         this.boats = result.data; 
      }
   }
  
  // public function that updates the existing boatTypeId property
  // uses notifyLoading
  @api
  searchBoats(boatTypeId) {
      this.boatTypeId = boatTypeId;
      notifyLoading(true);
      //alert('Selected Boat Type Id: '+boatTypeId);
   }
  
  // this public function must refresh the boats asynchronously
  // uses notifyLoading
  refresh() { }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(event) { 
    this.selectedBoatId = event.detail.boatId;
    sendMessageService(this.selectedBoatId);
  }
  
  // Publishes the selected boat Id on the BoatMC.
  sendMessageService(boatId) { 
    // explicitly pass boatId to the parameter recordId
    const message = {
      recordId : boatId
    };
    publish(this.messageContext,BOATMC,message);
  }
  
  // The handleSave method must save the changes in the Boat Editor
  // passing the updated fields from draftValues to the 
  // Apex method updateBoatList(Object data).
  // Show a toast message with the title
  // clear lightning-datatable draft values
  handleSave(event) {
    // notify loading
    const updatedFields = event.detail.draftValues;
    // Update the records via Apex
    updateBoatList({data: updatedFields})
    .then(() => {})
    .catch(error => {})
    .finally(() => {});
  }
  // Check the current value of isLoading before dispatching the doneloading or loading custom event
  notifyLoading(isLoading) { 
      if(isLoading){
          this.dispatchEvent('loading',{
              detail : isLoading
          });
      }else{
        this.dispatchEvent('doneloading',{
            detail : isLoading
        });
      }
  }
}