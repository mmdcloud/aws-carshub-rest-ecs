import { Test, TestingModule } from '@nestjs/testing';
import { VehicleModelsService } from './vehicle-models.service';

describe('VehicleModelsService', () => {
  let service: VehicleModelsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [VehicleModelsService],
    }).compile();

    service = module.get<VehicleModelsService>(VehicleModelsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
