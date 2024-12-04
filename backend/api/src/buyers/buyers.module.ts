import { Module } from '@nestjs/common';
import { BuyersService } from './buyers.service';
import { BuyersController } from './buyers.controller';
import { buyersProviders } from './buyers.providers';

@Module({
  controllers: [BuyersController],
  providers: [BuyersService, ...buyersProviders],
})
export class BuyersModule { }
