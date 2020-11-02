import { LightningElement, wire,track } from 'lwc';
import getBoatTypes from '@salesforce/apex/BoatDataService.getBoatTypes';
// import getBoatTypes from the BoatDataService => getBoatTypes method';
export default class BoatSearchForm extends LightningElement {
    selectedBoatTypeId = '';
    
    // Private
    error = undefined;
    
    // Needs explicit track due to nested data    
    searchOptions = [];
    
    // Wire a custom Apex method
    @wire(getBoatTypes)
      boatTypes({ error, data }) {
        console.log('Apex call:' + data +'--error--'+error);
      if (data) {
        this.searchOptions = data.map(type => {
            return {'label': type.Name,'value': type.Id}
        });
        this.searchOptions.unshift({ label: 'All Types', value: '' });
      } else if (error) {
        this.searchOptions = undefined;
        this.error = error;
      }
    }
    
    // Fires event that the search option has changed.
    // passes boatTypeId (value of this.selectedBoatTypeId) in the detail
    handleSearchOptionChange(event) {
      // Create the const searchEvent
      // searchEvent must be the new custom event search
      this.selectedBoatTypeId = event.detail.value;
      const searchEvent = new CustomEvent('search',{
        detail: this.selectedBoatTypeId
      });
      this.dispatchEvent(searchEvent);
    }
  }