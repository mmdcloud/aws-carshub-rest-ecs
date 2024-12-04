import { Test, TestingModule } from '@nestjs/testing';
import { ExtraServicesController } from './extra-services.controller';
import { ExtraServicesService } from './extra-services.service';

describe('ExtraServicesController', () => {
  let controller: ExtraServicesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExtraServicesController],
      providers: [ExtraServicesService],
    }).compile();

    controller = module.get<ExtraServicesController>(ExtraServicesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
