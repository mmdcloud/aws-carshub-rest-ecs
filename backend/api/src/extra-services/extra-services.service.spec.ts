import { Test, TestingModule } from '@nestjs/testing';
import { ExtraServicesService } from './extra-services.service';

describe('ExtraServicesService', () => {
  let service: ExtraServicesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ExtraServicesService],
    }).compile();

    service = module.get<ExtraServicesService>(ExtraServicesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
