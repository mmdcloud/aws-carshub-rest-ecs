import { Inject, Injectable } from '@nestjs/common';
import { UpdateExtraServiceDto } from './dto/update-extra-service.dto';
import { ExtraService } from './entities/extra-service.entity';

@Injectable()
export class ExtraServicesService {
  constructor(
    @Inject('EXTRA_SERVICES_REPOSITORY')
    private extraServicesRepository: typeof ExtraService
  ) { }
  async create(createExtraServiceDto): Promise<ExtraService> {
    var service = new ExtraService(createExtraServiceDto);
    return await service.save();
  }

  async findAll(): Promise<ExtraService[]> {
    return this.extraServicesRepository.findAll<ExtraService>();
  }

  async findOne(id: number): Promise<ExtraService> {
    return this.extraServicesRepository.findByPk<ExtraService>(id);
  }

  async update(id: number, updateExtraServiceDto: UpdateExtraServiceDto) {
    return `This action updates a #${id} extraService`;
  }

  async remove(id: number): Promise<number> {
    return this.extraServicesRepository.destroy({ where: { id: id } });
  }
}
