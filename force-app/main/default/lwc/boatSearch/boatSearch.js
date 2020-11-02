import { LightningElement,api } from 'lwc';

export default class BoatSearch extends LightningElement {
    @api isLoading = false;
    selectedboattype ='';

    createNewBoat(){
        alert('Create New Boat');
    }

    handleLoading(){
        this.isLoading = true;
    }

    handleDoneLoading(){
        this.isLoading = false;
    }

    handleSearch(event){
        this.selectedboattype = event.detail;
        //alert(this.selectedboattype );
    }
}