import { LightningElement,api,track } from 'lwc';
import { NavigationMixin  } from 'lightning/navigation';

export default class BoatSearch extends NavigationMixin(LightningElement) {
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
        alert('after event: selected boat Type: '+ this.selectedboattype );
        //alert(this.selectedboattype );
        //this.selectedboattype = event.detail
        this.template.querySelector('c-boat-search-results').searchBoats(this.selectedboattype);
    }
}