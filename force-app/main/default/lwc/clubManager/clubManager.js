import { LightningElement, track, wire } from 'lwc';
import createClub from '@salesforce/apex/ClubController.createClub';
import getAllClubs from '@salesforce/apex/ClubController.getAllClubs';
import deleteClub from '@salesforce/apex/ClubController.deleteClub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ClubManager extends LightningElement {
    clubName = '';
    clubs = [];

    wiredClubs;
    
    columns = [
        { label: 'Club Name', fieldName: 'Name', type: 'text' },
        {
            type: 'button',
            typeAttributes: { label: 'Delete', name: 'delete', variant: 'destructive' }
        }
    ];

    // Fetch all clubs
    @wire(getAllClubs)
    wiredGetClubs(result) {
        this.wiredClubs = result;
        if (result.data) {
            this.clubs = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading clubs', 'error');
        }
    }

    // Handle input for club name
    handleNameChange(event) {
        this.clubName = event.target.value;
    }

    // button click
    async handleAddClub() {
        if (!this.clubName) {
            this.showToast('Validation Error', 'Please enter a club name', 'warning');
            return;
        }

        try {
            await createClub({ name: this.clubName });
            this.showToast('Success', 'Club added successfully!', 'success');
            this.clubName = '';

            // Refresh the wire to reload the latest clubs
            await refreshApex(this.wiredClubs);
        } catch (error) {
            console.error('Error creating club:', error);
            this.showToast('Error', error.body?.message || 'Error creating club', 'error');
        }
    }


    // Delete buttons
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'delete') {
            this.deleteClubRecord(row.Id);
        }
    }

    // Delete a club record
    async deleteClubRecord(clubId) {
        try {
            await deleteClub({ clubId });
            this.showToast('Deleted', 'Club deleted successfully', 'success');
            await refreshApex(this.wiredClubs);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Utility Toast
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
