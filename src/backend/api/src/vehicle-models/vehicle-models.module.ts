import { Module } from '@nestjs/common';
import { VehicleModelsService } from './vehicle-models.service';
import { VehicleModelsController } from './vehicle-models.controller';
import { vehicleModelsProviders } from './vehicle-model.providers';

@Module({
  controllers: [VehicleModelsController],
  providers: [VehicleModelsService, ...vehicleModelsProviders],
})
export class VehicleModelsModule { }