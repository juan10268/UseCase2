import { LightningElement, api, wire, track} from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableProducts from '@salesforce/apex/OrderProducts.getAllOrderItems';
import getProducts from '@salesforce/apex/OrderProducts.getProducts';
import insertOrUpdateNewProduct from '@salesforce/apex/OrderProducts.insertOrUpdateNewProduct';
import isActiveOrder from '@salesforce/apex/OrderProducts.isOrderActive';
import activateOrder from '@salesforce/apex/OrderProducts.activateOrder';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency', sortable: true },
    { label: 'Quantity', fieldName: 'Quantity', type: 'number', sortable: true },
    { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency', sortable: true }
];

export default class OrderProducts extends LightningElement {
    columns = columns;
    @api recordId;
    @track isShowingCombobox = false;
    @track isActive;
    @track products;
    @track itemsList;
    @track error;
    @track wiredOrderItems = [];

    @wire(getAvailableProducts, {idOrder: '$recordId'}) availableItemsList(result){
        this.wiredOrderItems = result;
        if(result.data){
            this.getOrganizeOrderItems(result.data);
            this.error = undefined;
        }else if(result.error){
            this.error = result.error;
            this.itemsList = [];
        }
    }

    connectedCallback(){
        isActiveOrder({idOrder: this.recordId}).then(result => {
            this.isActive = result;
            this.error = null;
        }).catch((error) => {
            this.error = error;
            this.itemsList = null;
        });
        getProducts().then(result => {
            let productOptions = [];
            this.products = result;
            this.products.forEach(product =>{
                productOptions.push({label: product.Name, value: product.Id});
            });
            this.products = productOptions;
            this.error = null;
        }).catch((error) => {
            this.error = error;
            this.products = null;
        });        
    }
    
    getOrganizeOrderItems(data){
        let orderItems = [];
        for(var keySet in data){            
            orderItems.push(this.buildOrderItemObject(data[keySet]));
        }
        this.itemsList = orderItems;
        this.error = null;
    }

    setOrderActive(){
        activateOrder({idOrder: this.recordId}).then(result => {
            this.isActive = (!this.isActive);
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.isShowingCombobox = false;
            this.error = null;
        }).catch((error) => {
            this.error = error;
        });        
    }

    addOrUpdateProducts(event){
        let idProduct = event.detail.value;
        let data = this.itemsList;
        let idOrderItem = '';
        for(var key in data){
            if(data[key].Product2Id === idProduct){
                idOrderItem = data[key].Id;
                break;
            }
        }
        insertOrUpdateNewProduct({idProduct: idProduct, idOrder: this.recordId, idOrderItem: idOrderItem}).then(result => {
            if(idOrderItem !== ''){
                this.showNotification('Successful Operation', 'The Product was updated');
            }else{
                this.showNotification('Successful Operation', 'The Product was inserted');
            }
            this.showProductOptions();
            refreshApex(this.wiredOrderItems);
            this.error = null;
        }).catch((error) => {
            this.error = error;
        });
    }    

    buildOrderItemObject(orderResult){
        let orderItem = {};
        orderItem.Id = orderResult.Id;
        orderItem.Product2Id = orderResult.Product2Id;
        orderItem.UnitPrice = orderResult.UnitPrice;
        orderItem.TotalPrice = orderResult.TotalPrice;
        orderItem.Quantity = orderResult.Quantity;
        orderItem.PricebookEntry = orderResult.PricebookEntry;
        orderItem.Name = (orderItem.Name !== undefined)? orderItem.Name: orderResult.Product2.Name;
        return orderItem;
    }

    showProductOptions(){
        this.isShowingCombobox = (!this.isShowingCombobox);
    }

    showNotification(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}