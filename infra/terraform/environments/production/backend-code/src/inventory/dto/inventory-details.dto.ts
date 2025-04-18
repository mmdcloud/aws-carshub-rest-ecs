import { InventoryImage } from "../entities/inventory-image.entity";
import { Inventory } from "../entities/inventory.entity";

export class InventoryDetailsDto {
    imageData:InventoryImage[];
    inventoryData:Inventory;
    documentData:InventoryImage[];
}
