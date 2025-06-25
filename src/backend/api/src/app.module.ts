import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { VehicleModelsModule } from './vehicle-models/vehicle-models.module';
import { BrandsModule } from './brands/brands.module';
import { InventoryModule } from './inventory/inventory.module';
import { OrdersModule } from './orders/orders.module';
import { UsersModule } from './users/users.module';
import { VehicleOwnersModule } from './vehicle-owners/vehicle-owners.module';
import { ExtraServicesModule } from './extra-services/extra-services.module';
import { BuyersModule } from './buyers/buyers.module';
import { databaseProviders } from './database.providers';
import { DashboardModule } from './dashboard/dashboard.module';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot(),
    VehicleModelsModule, BrandsModule, InventoryModule, OrdersModule, UsersModule, VehicleOwnersModule, ExtraServicesModule, BuyersModule, DashboardModule],
  controllers: [AppController],
  providers: [AppService, ...databaseProviders],
})
export class AppModule { }
