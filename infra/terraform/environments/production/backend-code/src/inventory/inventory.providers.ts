import { InventoryImage } from './entities/inventory-image.entity';
import { Inventory } from './entities/inventory.entity';

export const inventoryProviders = [
    {
        provide: 'INVENTORY_REPOSITORY',
        useValue: Inventory,
    },
    {
        provide: 'INVENTORY_IMAGES_REPOSITORY',
        useValue: InventoryImage,
    },
];