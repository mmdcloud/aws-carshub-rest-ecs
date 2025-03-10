import { Module } from '@nestjs/common';
import { VehicleOwnersService } from './vehicle-owners.service';
import { VehicleOwnersController } from './vehicle-owners.controller';
import { vehicleOwnersProviders } from './vehicle-owners.providers';

@Module({
  controllers: [VehicleOwnersController],
  providers: [VehicleOwnersService, ...vehicleOwnersProviders],
})
export class VehicleOwnersModule { }
