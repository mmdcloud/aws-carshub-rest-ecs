import { Test, TestingModule } from '@nestjs/testing';
import { VehicleOwnersService } from './vehicle-owners.service';

describe('VehicleOwnersService', () => {
  let service: VehicleOwnersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [VehicleOwnersService],
    }).compile();

    service = module.get<VehicleOwnersService>(VehicleOwnersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
