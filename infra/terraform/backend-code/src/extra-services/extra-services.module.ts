import { Module } from '@nestjs/common';
import { ExtraServicesService } from './extra-services.service';
import { ExtraServicesController } from './extra-services.controller';
import { extraServicesProviders } from './extra-service.providers';

@Module({
  controllers: [ExtraServicesController],
  providers: [ExtraServicesService, ...extraServicesProviders],
})
export class ExtraServicesModule { }
