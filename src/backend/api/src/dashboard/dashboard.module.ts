import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { buyersProviders } from 'src/buyers/buyers.providers';
import { ordersProviders } from 'src/orders/orders.providers';
import { inventoryProviders } from 'src/inventory/inventory.providers';
import { brandsProviders } from 'src/brands/brands.providers';
import { vehicleOwnersProviders } from 'src/vehicle-owners/vehicle-owners.providers';
import { vehicleModelsProviders } from 'src/vehicle-models/vehicle-model.providers';

@Module({
  controllers: [DashboardController],
  providers: [DashboardService,...buyersProviders,...ordersProviders,...inventoryProviders,...brandsProviders,...vehicleModelsProviders,...vehicleOwnersProviders],
})
export class DashboardModule {}
