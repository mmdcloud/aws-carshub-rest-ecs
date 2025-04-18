import { Test, TestingModule } from '@nestjs/testing';
import { VehicleModelsController } from './vehicle-models.controller';
import { VehicleModelsService } from './vehicle-models.service';

describe('VehicleModelsController', () => {
  let controller: VehicleModelsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VehicleModelsController],
      providers: [VehicleModelsService],
    }).compile();

    controller = module.get<VehicleModelsController>(VehicleModelsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
