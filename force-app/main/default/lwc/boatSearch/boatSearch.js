import { LightningElement,api } from 'lwc';
import { NavigationMixin  } from 'lightning/navigation';

export default class BoatSearch extends LightningElement {
    @api isLoading = false;
    selectedboattype ='';

    createNewBoat(){
       this[NavigationMixin.Navigate]({
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Boat__c',
            actionName: 'new'
        }
       });
    }

    handleLoading(){
        this.isLoading = true;
    }

    handleDoneLoading(){
        this.isLoading = false;
    }

    handleSearch(event){
        this.selectedboattype = event.detail.boatTypeId;
        console.log('after event: selected boat Type: '+ this.selectedboattype );
        //alert(this.selectedboattype );
        //this.selectedboattype = event.detail
        this.template.querySelector('c-boat-search-results').searchBoats(event.detail.boatTypeId);
    }
}