import { Module } from '@nestjs/common';
import { BrandsService } from './brands.service';
import { BrandsController } from './brands.controller';
import { brandsProviders } from './brands.providers';

@Module({
  controllers: [BrandsController],
  providers: [BrandsService, ...brandsProviders],
})
export class BrandsModule { }
