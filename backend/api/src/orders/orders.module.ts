import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { ordersProviders } from './orders.providers';
import { extraServicesProviders } from 'src/extra-services/extra-service.providers';
import { inventoryProviders } from 'src/inventory/inventory.providers';

@Module({
  controllers: [OrdersController],
  providers: [OrdersService, ...ordersProviders,...inventoryProviders,...extraServicesProviders],
})
export class OrdersModule { }
