import { Test, TestingModule } from '@nestjs/testing';
import { VehicleOwnersController } from './vehicle-owners.controller';
import { VehicleOwnersService } from './vehicle-owners.service';

describe('VehicleOwnersController', () => {
  let controller: VehicleOwnersController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VehicleOwnersController],
      providers: [VehicleOwnersService],
    }).compile();

    controller = module.get<VehicleOwnersController>(VehicleOwnersController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
