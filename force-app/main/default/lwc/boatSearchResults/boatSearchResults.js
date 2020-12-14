import { LightningElement,api, wire ,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {publish,MessageContext} from 'lightning/messageService';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';
import { refreshApex } from '@salesforce/apex';

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
  error = undefined;
  @track draftValues = [];
  
  // wired message context
  @wire(MessageContext)
  messageContext;
  // wired getBoats method
  @wire(getBoats,{boatTypeId: '$boatTypeId'}) 
  wiredBoats(result) {
      if(result.data){
         this.boats = result.data; 
      }else{
        this.error = result.error;
      }
      this.isLoading = false;
      this.notifyLoading(this.isLoading);
   }
  
  // public function that updates the existing boatTypeId property
  // uses notifyLoading
  @api
  searchBoats(boatTypeId) {
    this.isLoading =true;
    this.notifyLoading(this.isLoading);
    this.boatTypeId = boatTypeId;      
      //alert('Selected Boat Type Id: '+boatTypeId);
   }
  
  // this public function must refresh the boats asynchronously
  // uses notifyLoading
  @api
  async refresh() { 
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    await refreshApex(this.boats);
    this.isLoading = false;
    this.notifyLoading(this.isLoading); 
  }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(event) { 
    this.selectedBoatId = event.detail.boatId;    
    this.sendMessageService(this.selectedBoatId);
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
    this.notifyLoading(true);
    const updatedFields = event.detail.draftValues;
    // Update the records via Apex
    updateBoatList({data: updatedFields})
    .then(() => {
      const showSuccessMsg = new ShowToastEvent({
        title: SUCCESS_TITLE,
        message: MESSAGE_SHIP_IT,
        variant: SUCCESS_VARIANT
      });
      this.dispatchEvent(showSuccessMsg);
      this.draftValues = [];
      return this.refresh();
    })
    .catch(error => {
      const CONST_ERROR = error;
      const showErrorMsg = new ShowToastEvent({
        title: ERROR_TITLE,
        message: CONST_ERROR,
        variant: ERROR_VARIANT
      });
      this.dispatchEvent(showErrorMsg);
      this.notifyLoading(false);
    })
    .finally(() => {
      this.draftValues = [] ;
    });
  }
  // Check the current value of isLoading before dispatching the doneloading or loading custom event
  notifyLoading(isLoading) { 
      if(isLoading){
         /* this.dispatchEvent('loading',{
              detail : isLoading
          }); */
          this.dispatchEvent(new CustomEvent('loading'));
      }else{
        /*this.dispatchEvent('doneloading',{
            detail : isLoading
        }); */
        this.dispatchEvent(new CustomEvent('doneloading'));
      }
  }
}